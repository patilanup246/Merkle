CREATE PROCEDURE [PreProcessing].[CBE_FulfilmentMethod_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER

	DECLARE @now                    DATETIME
	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)
	DECLARE @successcountimport    INTEGER       = 0
	DECLARE @errorcountimport      INTEGER       = 0

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @now = GETDATE()

	SELECT @recordcount = COUNT(1)
	FROM [PreProcessing].[CBE_FulfilmentType]
	WHERE  DataImportDetailID = @dataimportdetailid
	
    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

    --Get configuration settings

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'CBE'

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL')
		
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

	;WITH CTE_FulfilmentMethod AS (
	              SELECT [CBE_FulfilmentTypeID]
                        ,[ID]
                        ,[Fulfilment_Type]
                        ,CAST(([Charge] / 100) AS decimal(14,2)) AS [Charge] 
                        ,[Description]
                        ,[Date_Created]
                        ,[Date_Modified]
                        ,[Is_Active]
                        ,[Display_Name]
                        ,[Effective_Date_From]
                        ,[Effective_Date_To]
                        ,[Is_Active_Charge]
                        ,[Date_Created_Charge]
                        ,[Date_Modified_Charge],
						ROW_NUMBER() OVER (partition by [Fulfilment_Type]
						                               ,[Charge] ORDER BY [Date_Modified] DESC
						                                                 ,[CBE_FulfilmentTypeID] DESC) RANKING
                  FROM   [PreProcessing].[CBE_FulfilmentType]
				  WHERE  DataImportDetailID = @dataimportdetailid
	              AND    ProcessedInd = 0)

    --Copy data into local temp table to save on network traffic

	SELECT *
	INTO #tmp_FulfilmentMethod
	FROM CTE_FulfilmentMethod
	WHERE RANKING = 1

    --Methods in [Reference].[FulfilmentMethod] but not in #tmp_FulfilmentMethod are to be treated as expired references. Match on charge too

	UPDATE a
	SET  ValidityEndDate        = GETDATE()
	    ,ArchivedInd            = 1
		,LastModifiedDate       = GETDATE()
    FROM [Reference].[FulfilmentMethod] a
	LEFT JOIN #tmp_FulfilmentMethod     b ON b.Fulfilment_Type = a.Name
	                                        AND a.Charge = b.Charge
	WHERE a.InformationSourceID = @informationsourceid
	AND a.ArchivedInd = 0
	AND b.Fulfilment_Type IS NULL

	--Now for changes

	UPDATE a
    SET [Description]        = b.Description
       ,[LastModifiedDate]   = GETDATE()
       ,[LastModifiedBy]     = @userid
       ,[ArchivedInd]        = CASE WHEN b.Is_Active = 1 THEN 0 ELSE 1 END
       ,[ExtReference]       = b.Fulfilment_Type
       ,[DisplayName]        = b.Display_Name
       ,[SourceModifiedDate] = b.Date_Modified_Charge
       ,[ValidityStartDate]  = b.Effective_Date_From
       ,[ValidityEndDate]    = b.Effective_Date_To
    FROM [Reference].[FulfilmentMethod] a
	INNER JOIN #tmp_FulfilmentMethod     b ON b.Fulfilment_Type = a.Name
	                                        AND a.Charge = b.Charge
	WHERE a.InformationSourceID = @informationsourceid
    AND   a.ArchivedInd = 0

	--Update processed records

    UPDATE a
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM  PreProcessing.CBE_FulfilmentType a
	INNER JOIN [Reference].[FulfilmentMethod] b ON b.Name = a.Fulfilment_Type 
	                                               AND b.InformationSourceID = @informationsourceid
												   AND CAST((a.[Charge] / 100) AS decimal(14,2)) = b.Charge
												   AND b.ArchivedInd = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
    WHERE a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

	--Now for new charges

    INSERT INTO [Reference].[FulfilmentMethod]
        (Name,
		Description,
		CreatedDate,
		CreatedBy,
		LastModifiedDate,
		LastModifiedBy,
		ArchivedInd,
		SourceCreatedDate,
		SourceModifiedDate,
		InformationSourceId,
		DisplayName,
		Charge,
		ExtReference,
		ValidityStartDate,
		ValidityEndDate)
    SELECT  a.Fulfilment_Type,
			a.Description,	
			GETDATE(),
			@userid,
			GETDATE(),
			@userid,
			CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END,
			a.Date_Created_Charge,
			a.Date_Modified_Charge,
			@informationsourceid,
			a.Display_Name,
			a.Charge,
			a.Fulfilment_Type,
			a.Effective_Date_From,
			a.Effective_Date_To
    FROM #tmp_FulfilmentMethod a
	LEFT JOIN Reference.FulfilmentMethod b ON b.ExtReference = a.Fulfilment_Type
	                                          AND a.Charge   = b.Charge
											  AND b.InformationSourceID = @informationsourceid
											  AND b.ArchivedInd = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	WHERE	b.ExtReference IS NULL 
	AND     a.Is_Active = 1

	--Update processed records

    UPDATE a
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM  PreProcessing.CBE_FulfilmentType a
	INNER JOIN [Reference].[FulfilmentMethod] b ON b.Name = a.Fulfilment_Type 
	                                               AND b.InformationSourceID = @informationsourceid
												   AND CAST((a.[Charge] / 100) AS decimal(14,2)) = b.Charge
												   AND b.ArchivedInd = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
    WHERE a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_FulfilmentType
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_FulfilmentType
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid
	
	SELECT @recordcount = @successcountimport + @errorcountimport

	
    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = NULL,
	                                            @endtimeimport         = @now,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = @successcountimport,
	                                            @errorcountimport      = @errorcountimport


    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END