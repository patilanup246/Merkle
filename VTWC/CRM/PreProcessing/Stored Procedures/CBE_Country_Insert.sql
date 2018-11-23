CREATE PROCEDURE [PreProcessing].[CBE_Country_Insert]
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

	;WITH CTE_Country AS (
	              SELECT a.[ID]
				        ,a.[Code]
                        ,a.[Name]
                        ,a.[Date_Created]
                        ,a.[Date_Modified]
                        ,a.[Is_Active]
				        ,ROW_NUMBER() OVER (partition by [Code] ORDER BY a.[Date_Modified] DESC
						                                                ,a.[CreatedDateETL] DESC) RANKING
                  FROM   [PreProcessing].[CBE_Country] a
				  WHERE  a.DataImportDetailID = @dataimportdetailid
	              AND    a.ProcessedInd = 0)

    SELECT *
	INTO #tmp_Country
	FROM CTE_Country
	WHERE Ranking = 1

	--Countries in [Reference].[Country] but not in #tmp_Country are to be treated as expired references

	UPDATE a
	SET  ValidityEndDate        = GETDATE()
	    ,ArchivedInd            = 1
		,LastModifiedDate       = GETDATE()
    FROM [Reference].[Country] a
	LEFT JOIN #tmp_Country     b ON a.Code = b.Code
	WHERE a.InformationSourceID = @informationsourceid
	AND   a.ArchivedInd = 0
	AND   b.Code IS NULL

    --update existing records 

	UPDATE b
	SET    Name                   = [dbo].[Proper_Case] (a.Name)
		  ,SourceModifiedDate     = a.Date_Modified
		  ,ArchivedInd            = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
		  ,LastModifiedDate       = GETDATE()
	FROM #tmp_Country a
	INNER JOIN [Reference].[Country] b ON b.Code                 = a.Code
	                                   AND b.InformationSourceID = @informationsourceid
                                       AND b.ArchivedInd         = 0

	--Update process records

    UPDATE a
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM [PreProcessing].[CBE_Country] a
	INNER JOIN [Reference].[Country]   b ON  b.Code                = b.Code
	                                     AND b.InformationSourceID = @informationsourceid
    WHERE a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

	--Now for new records

    INSERT INTO [Reference].[Country]
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
		   ,[ValidityEndDate])
    SELECT  [dbo].[Proper_Case] (a.Name)
           ,NULL
           ,GETDATE()
		   ,@userid
		   ,GETDATE()
		   ,@userid
		   ,CASE WHEN a.[Is_Active] = 1 THEN 0 ELSE 1 END
		   ,a.[Date_Created]
		   ,a.[Date_Modified]
		   ,@informationsourceid
           ,a.[Code]
		   ,a.[Date_Created]
		   ,@maxvalidityend
    FROM #tmp_Country a 
	LEFT JOIN [Reference].[Country] b ON  a.Code = b.Code
	                                  AND b.InformationSourceID = @informationsourceid
									  AND b.ArchivedInd = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	WHERE b.Code IS NULL
	AND   a.Is_Active = 1

	--Update process records

    UPDATE a
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM [PreProcessing].[CBE_Country] a
	INNER JOIN [Reference].[Country]   b ON  b.Code                = b.Code
	                                     AND b.InformationSourceID = @informationsourceid
    WHERE a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[CBE_Country]
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[CBE_Country]
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