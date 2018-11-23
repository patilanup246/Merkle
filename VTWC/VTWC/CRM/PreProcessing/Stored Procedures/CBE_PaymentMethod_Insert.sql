CREATE PROCEDURE [PreProcessing].[CBE_PaymentMethod_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	DECLARE @maxvalidityend         DATETIME

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

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

    --Get configuration settings

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'CBE'

	SELECT @maxvalidityend = CAST([Reference].[Configuration_GetSetting] ('Operations','Maximum Validity End Date') AS DATETIME)

	IF @informationsourceid IS NULL OR @maxvalidityend IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid or @maxvalidityend; ' +
		                  '@informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') + 
						  '@maxvalidityend = '      + ISNULL(CAST(@maxvalidityend AS NVARCHAR(256)),'NULL') 
		
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

    --It is possible for CBE to mutiple changes during a batch window. Only require the latest information. Create temporary table to avoid multiple
	--CTE being created for each step

	;WITH CTE_PaymentMethod AS (
	              SELECT a.[ID]
				        ,a.[Code]
                        ,a.[Description]
                        ,a.[Valid_From]
                        ,a.[Valid_To]
                        ,a.[SDCI_Record_Type]
                        ,a.[Priority_Mask_Value]
                        ,a.[Date_Created]
                        ,a.[Date_Modified]
                        ,a.[Is_Active]
                        ,a.[MOP]
                        ,a.[Max_Payments_Count]
                        ,ROW_NUMBER() OVER (partition by [Code] ORDER BY a.[Date_Modified] DESC
						                                                ,a.[CreatedDateETL] DESC) RANKING
                  FROM   [PreProcessing].[CBE_PaymentMethod] a
				  WHERE  a.DataImportDetailID = @dataimportdetailid
	              AND    a.ProcessedInd = 0)

    SELECT *
	INTO #tmp_PaymentMethod
	FROM CTE_PaymentMethod

	--Payment Methods in [Reference].[PaymentMethod] but not in #tmp_PaymentMethod are to be treated as expired references

	UPDATE a
	SET  ValidityEndDate        = GETDATE()
	    ,ArchivedInd            = 1
		,LastModifiedDate       = GETDATE()
    FROM [Reference].[PaymentMethod] a
	LEFT JOIN #tmp_PaymentMethod     b ON a.Code = b.Code
	WHERE a.InformationSourceID = @informationsourceid
	AND   a.ArchivedInd = 0
	AND   b.Code IS NULL

    --update existing active records 

	UPDATE [Reference].[PaymentMethod]
	SET    Name                   = a.Description
	      ,Description            = a.Description
		  ,ValidityStartDate      = a.Valid_From
		  ,ValidityEndDate        = a.Valid_To
		  ,SDCIRecordType         = a.SDCI_Record_Type
		  ,PriorityMaskValue      = a.Priority_Mask_Value
		  ,MOP                    = a.MOP
		  ,MaxPaymentsCount       = a.Max_Payments_Count
		  ,SourceModifiedDate     = a.Date_Modified
		  ,ArchivedInd            = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
		  ,LastModifiedDate       = GETDATE()
	FROM #tmp_PaymentMethod a
	INNER JOIN [Reference].[PaymentMethod] b ON  b.Code                = a.Code
	                                         AND b.InformationSourceID = @informationsourceid
										     AND b.ArchivedInd         = 0

	--Update process records

    UPDATE b
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM [Reference].[PaymentMethod] a
	INNER JOIN  [PreProcessing].[CBE_PaymentMethod] b ON a.Code = b.Code
	                                                  AND a.InformationSourceID = @informationsourceid
    WHERE b.DataImportDetailID = @dataimportdetailid
	AND   b.ProcessedInd = 0

	--Now for new records

    INSERT INTO [Reference].[PaymentMethod]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[InformationSourceID]
           ,[Code]
		   ,[ValidityStartDate]
		   ,[ValidityEndDate]
		   ,[SDCIRecordType]
           ,[PriorityMaskValue]
           ,[MOP]
           ,[MaxPaymentsCount]
           ,[ExtReference])
    SELECT  [dbo].[Proper_Case] (a.Description)
           ,a.Description
           ,GETDATE()
		   ,@userid
		   ,GETDATE()
		   ,@userid
		   ,CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
		   ,a.Date_Created
		   ,a.Date_Modified
		   ,@informationsourceid
           ,a.Code
		   ,ISNULL(a.Valid_From,a.Date_Created)
		   ,ISNULL(a.Valid_To,@maxvalidityend)
		   ,a.SDCI_Record_Type
		   ,a.Priority_Mask_Value
		   ,a.MOP
		   ,a.Max_Payments_Count
		   ,a.Code
    FROM #tmp_PaymentMethod a 
	LEFT JOIN [Reference].[PaymentMethod] b ON a.Code = b.Code
	                                     AND b.InformationSourceID = @informationsourceid
										 AND b.ArchivedInd = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	WHERE b.Code IS NULL
    AND   a.Is_Active = 1

	--Update process records

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Reference].[PaymentMethod] a
	INNER JOIN [PreProcessing].[CBE_PaymentMethod] b ON  a.Code = b.Code
	                                                 AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[CBE_PaymentMethod]
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[CBE_PaymentMethod]
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