CREATE PROCEDURE [PreProcessing].[CBE_CustomerLoyalty_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid      INTEGER

	DECLARE @now                      DATETIME
	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)
	DECLARE @successcountimport       INTEGER = 0
	DECLARE @errorcountimport         INTEGER = 0

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

    --CBE allows mulitple loyalty schemes per provider to support validation. Create temp table to manage support this

	SELECT a.LoyaltyProgrammeTypeID
		  ,b.Value AS SchemeName
	INTO #tmp_LoyaltyProgrammeType
    FROM Reference.LoyaltyProgrammeType a
    CROSS APPLY [Staging].[SplitStringToTable] (a.ExtReference,',') AS b

    --Add new Loyalty References to table Staging.STG_LoyaltyAccount

	;WITH CTE_LoyaltyAccounts AS (
    SELECT TOP 999999999
		   a.Scheme_Name
          ,a.Loyalty_Card_Number
          ,a.Date_Created
          ,a.Date_Modified
          ,ROW_NUMBER() OVER (partition by a.Loyalty_Card_Number order by a.Date_Created) Ranking
    FROM [PreProcessing].[CBE_CustomerLoyalty] a WITH (NOLOCK)
	INNER JOIN #tmp_LoyaltyProgrammeType       b WITH (NOLOCK) ON b.SchemeName                = a.Scheme_Name
	LEFT JOIN  [Staging].[STG_LoyaltyAccount]  c WITH (NOLOCK) ON c.LoyaltyReference          = a.[Loyalty_Card_Number]
	                                               AND c.LoyaltyProgrammeTypeID = b.LoyaltyProgrammeTypeID
	WHERE c.LoyaltyAccountID IS NULL
	AND   a.ProcessedInd = 0
	AND   a.DataImportDetailID = @dataimportdetailid)

	INSERT INTO [Staging].[STG_LoyaltyAccount]
          ([Name]
          ,[Description]
          ,[CreatedDate]
          ,[CreatedBy]
          ,[LastModifiedDate]
          ,[LastModifiedBy]
          ,[ArchivedInd]
          ,[LoyaltyProgrammeTypeID]
          ,[LoyaltyReference]
          ,[InformationSourceID]
          ,[SourceCreatedDate]
          ,[SourceModifiedDate])
   	SELECT NULL
          ,NULL
          ,GETDATE()
          ,@userid
          ,GETDATE()
          ,@userid
          ,0
		  ,b.LoyaltyProgrammeTypeID
		  ,Loyalty_Card_Number
		  ,@informationsourceid
		  ,Date_Created
		  ,Date_Modified
    FROM CTE_LoyaltyAccounts a WITH (NOLOCK)
	INNER JOIN #tmp_LoyaltyProgrammeType b WITH (NOLOCK) ON a.Scheme_Name = b.[SchemeName]
    WHERE a.Ranking = 1

	--Update ProcessedInd for those new entries

    UPDATE a
	SET ProcessedInd = 1
	   ,LastModifiedDateETL = GETDATE()
    FROM [PreProcessing].[CBE_CustomerLoyalty] a
	INNER JOIN #tmp_LoyaltyProgrammeType c              ON a.Scheme_Name = c.[SchemeName]
    INNER JOIN [Staging].[STG_LoyaltyAccount] d         ON a.Loyalty_Card_Number = d.LoyaltyReference 
	                                                    AND d.LoyaltyProgrammeTypeID = c.LoyaltyProgrammeTypeID
	WHERE a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

	--logging

	SELECT @recordcount = COUNT(1)
	FROM  [PreProcessing].[CBE_CustomerLoyalty] WITH (NOLOCK)
	WHERE DataImportDetailID  = @dataimportdetailid

	SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_CustomerLoyalty WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_CustomerLoyalty WITH (NOLOCK)
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid
	
	
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