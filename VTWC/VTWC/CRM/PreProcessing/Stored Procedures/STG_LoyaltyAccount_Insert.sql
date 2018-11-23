
CREATE PROCEDURE [PreProcessing].[STG_LoyaltyAccount_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Delta - MSD'

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END

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

	--CBE allows mulitple loyalty schemes per provider to support validation. Create temp table to manage support this

	SELECT a.LoyaltyProgrammeTypeID
		  ,b.Value AS SchemeName
	INTO #tmp_LoyaltyProgrammeType
    FROM Reference.LoyaltyProgrammeType a
    CROSS APPLY [Staging].[SplitStringToTable] (a.ExtReference,',') AS b

--Now add new loyalty accounts

    ;WITH CTE AS (
    SELECT b.LoyaltyProgrammeTypeID
          ,a.out_loyaltycardnumber
          ,Staging.SetUKTime(a.CreatedOn) as CreatedOn
          ,Staging.SetUKTime(a.ModifiedOn) as ModifiedOn
          ,ROW_NUMBER() OVER (partition by a.out_loyaltycardnumber,a.out_loyaltycardnumber order by a.CreatedOn) Ranking
    FROM [PreProcessing].[MSD_LoyaltyProgrammeMembership] a
	INNER JOIN #tmp_LoyaltyProgrammeType b ON b.SchemeName = a.out_loyaltytype
	INNER JOIN [Staging].[STG_KeyMapping] c ON a.out_customerId = c.MSDID
	LEFT JOIN  [Staging].[STG_LoyaltyAccount] d ON d.LoyaltyProgrammeTypeID = b.LoyaltyProgrammeTypeID AND d.LoyaltyReference = a.out_loyaltycardnumber
	WHERE d.LoyaltyAccountID IS NULL
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
		  ,LoyaltyProgrammeTypeID
		  ,out_loyaltycardnumber
		  ,@informationsourceid
		  ,CreatedOn
		  ,ModifiedOn
    FROM CTE
    WHERE Ranking = 1

--Update any matching records - only field of value that will changes is the SourceModified Date

    UPDATE a
	SET SourceModifiedDate  = Staging.SetUKTime(b.ModifiedOn),
	    InformationSourceID = @informationsourceid,
	    LastModifiedDate    = GETDATE(),
		LastModifiedBy      = @userid
	FROM [Staging].[STG_LoyaltyAccount] a,
	     [PreProcessing].[MSD_LoyaltyProgrammeMembership] b,
		 #tmp_LoyaltyProgrammeType c
	WHERE a.LoyaltyReference = b.out_loyaltycardnumber
	AND   a.LoyaltyProgrammeTypeID = c.LoyaltyProgrammeTypeID
	AND   c.SchemeName = b.out_loyaltytype
	AND   b.DataImportDetailID = @dataimportdetailid
	AND   b.ProcessedInd = 0

	--Now update the LoyaltyAccount to Cuustomer Relationships

	EXEC [PreProcessing].[STG_CustomerLoyaltyAccount_Insert] @userid = 0,
	                                                         @dataimportdetailid = @dataimportdetailid

--Mark those which have been processed

    UPDATE a
	SET   ProcessedInd = 1
	FROM [PreProcessing].[MSD_LoyaltyProgrammeMembership] a,
		 [Staging].[STG_LoyaltyAccount] b,
		 #tmp_LoyaltyProgrammeType c
	WHERE a.out_loyaltycardnumber = b.LoyaltyReference
	AND   b.LoyaltyProgrammeTypeID = c.LoyaltyProgrammeTypeID
	AND   c.SchemeName = a.out_loyaltytype
	AND   b.SourceModifiedDate  = Staging.SetUKTime(a.ModifiedOn)
	AND   a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

    UPDATE a
	SET   ProcessedInd = 1
	FROM [PreProcessing].[MSD_LoyaltyProgrammeMembership] a,
		 [Staging].[STG_LoyaltyAccount] b,
		 #tmp_LoyaltyProgrammeType c,
		 [Staging].[STG_CustomerLoyaltyAccount] d,
		 [Staging].[STG_keyMapping] e
	WHERE a.out_loyaltycardnumber = b.LoyaltyReference
	AND   a.out_loyaltytype = c.SchemeName
    AND   CAST(a.out_loyaltymembershipId AS NVARCHAR(256)) = d.ExtReference
	AND   a.out_customerId = e.MSDID
	AND   b.LoyaltyProgrammeTypeID = c.LoyaltyProgrammeTypeID
	AND   d.LoyaltyAccountID = b.LoyaltyAccountID
	AND   e.CustomerID = d.CustomerID
	AND   a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

--log audit information

 	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.MSD_LoyaltyProgrammeMembership
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.MSD_LoyaltyProgrammeMembership
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

    SELECT @now = GETDATE()

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