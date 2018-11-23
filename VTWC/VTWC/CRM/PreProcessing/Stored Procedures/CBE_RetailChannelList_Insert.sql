CREATE PROCEDURE [PreProcessing].[CBE_RetailChannelList_Insert]
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

	;WITH CTE_RetailChannelList AS (
	              SELECT a.[CBE_RetailChannelListID]
                        ,a.[ID]
                        ,a.[Code]
                        ,a.[Name]
                        ,a.[Date_Created]
                        ,a.[Date_Modified]
                        ,a.[Is_Active]
                        ,ROW_NUMBER() OVER (partition by [Code] ORDER BY a.[Date_Modified] DESC
						                                                ,a.[CreatedDateETL] DESC) RANKING
				  FROM [PreProcessing].[CBE_RetailChannelList] a
    			  WHERE  a.DataImportDetailID = @dataimportdetailid
	              AND    a.ProcessedInd = 0)

    SELECT *
	INTO #tmp_RetailChannelList
	FROM CTE_RetailChannelList

	--Retail Channels in [Reference].[RetailChannel] but not in #tmp_RetailChannelList are to be treated as expired references

	UPDATE a
	SET  ValidityEndDate        = GETDATE()
	    ,ArchivedInd            = 1
		,LastModifiedDate       = GETDATE()
    FROM [Reference].[RetailChannel] a
	LEFT JOIN #tmp_RetailChannelList b ON a.Code = b.Code
	WHERE a.InformationSourceID = @informationsourceid
	AND a.ArchivedInd = 0
	AND b.Code IS NULL

    --update existing active records 

    UPDATE [Reference].[RetailChannel]
    SET [Name]               = a.Name
       ,[LastModifiedDate]   = GETDATE()
       ,[LastModifiedBy]     = @userid
       ,[ArchivedInd]        = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
       ,[ValidityEndDate]    = CASE WHEN a.Is_Active = 1 THEN b.ValidityEndDate ELSE a.Date_Modified END
       ,[SourceModifiedDate] = Date_Modified
	FROM #tmp_RetailChannelList a
	INNER JOIN [Reference].[RetailChannel] b ON b.Code = a.Code
	                                         AND b.InformationSourceID = @informationsourceid
										     AND b.ArchivedInd = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END

	--Update process records

    UPDATE b
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM [Reference].[RetailChannel] a
	INNER JOIN  [PreProcessing].[CBE_RetailChannelList] b ON a.Code = b.Code
	                                                      AND a.InformationSourceID = @informationsourceid
    WHERE b.DataImportDetailID = @dataimportdetailid
	AND   b.ProcessedInd = 0

	--Now for new records

    INSERT INTO  [Reference].[RetailChannel]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[ValidityStartDate]
           ,[ValidityEndDate]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[InformationSourceID]
           ,[ExtReference]
           ,[Code])
    SELECT  a.Name
           ,'Source from CBE'
           ,GETDATE()
		   ,@userid
		   ,GETDATE()
		   ,@userid
		   ,CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
           ,a.Date_Created
		   ,CASE WHEN a.Is_Active = 0 THEN GETDATE() ELSE @maxvalidityend END 
		   ,a.Date_Created
		   ,a.Date_Modified
		   ,@informationsourceid
           ,a.Code
           ,a.Code
    FROM #tmp_RetailChannelList a 
	LEFT JOIN [Reference].[RetailChannel] b ON a.Code = b.Code
	                                     AND b.InformationSourceID = @informationsourceid
										 AND b.ArchivedInd = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	WHERE b.Code IS NULL

	--Update process records

    UPDATE b
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM [Reference].[RetailChannel] a
	INNER JOIN  [PreProcessing].[CBE_RetailChannelList] b ON a.Code = b.Code
	                                                      AND a.InformationSourceID = @informationsourceid
    WHERE b.DataImportDetailID = @dataimportdetailid
	AND   b.ProcessedInd = 0


	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[CBE_RetailChannelList]
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[CBE_RetailChannelList]
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