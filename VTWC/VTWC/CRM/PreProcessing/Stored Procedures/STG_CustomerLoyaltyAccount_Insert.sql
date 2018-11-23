
CREATE PROCEDURE [PreProcessing].[STG_CustomerLoyaltyAccount_Insert]
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


	
--Now add new loyalty account to customer relationships

	INSERT INTO [Staging].[STG_CustomerLoyaltyAccount]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[CustomerID]
           ,[LoyaltyAccountID]
           ,[StartDate]
           ,[EndDate]
		   ,[InformationSourceID]
		   ,[ExtReference])
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,c.CustomerID
           ,b.LoyaltyAccountID
           ,Staging.SetUKTime(a.out_loyaltystartdate) as out_loyaltystartdate
		   ,Staging.SetUKTime(a.out_loyaltyenddate) as out_loyaltyenddate
		   ,@informationsourceid
		   ,CAST(a.out_loyaltymembershipId AS NVARCHAR(256))
    FROM [PreProcessing].[MSD_LoyaltyProgrammeMembership] a
	INNER JOIN [Staging].[STG_LoyaltyAccount] b     ON a.out_loyaltycardnumber = b.LoyaltyReference
	INNER JOIN [Staging].[STG_keyMapping] c         ON a.out_customerId = c.MSDID
	INNER JOIN [Reference].[LoyaltyProgrammeType] d ON a.out_loyaltytype =  d.ExtReference AND b.LoyaltyProgrammeTypeID = d.LoyaltyProgrammeTypeID
	LEFT JOIN [Staging].[STG_CustomerLoyaltyAccount] e ON e.CustomerID = c.CustomerID and e.LoyaltyAccountID = b.LoyaltyAccountID 
	WHERE e.CustomerLoyaltyAccountID IS NULL
	AND   a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0


--Update any matching records - only field of value that will change is the EndDate, i.e. loyalty account is no longer being used by that customer

    UPDATE a
	SET EndDate  = Staging.SetUKTime(e.out_loyaltyenddate),
	    InformationSourceID = @informationsourceid,
	    LastModifiedDate    = GETDATE(),
		LastModifiedBy      = @userid
	FROM [Staging].[STG_CustomerLoyaltyAccount] a,
	     [Staging].[STG_LoyaltyAccount] b,
		 [Reference].[LoyaltyProgrammeType] c,
		 [Staging].[STG_keyMapping] d,
		 [PreProcessing].[MSD_LoyaltyProgrammeMembership] e
	WHERE a.LoyaltyAccountID = b.LoyaltyAccountID
	AND   b.LoyaltyProgrammeTypeID = c.LoyaltyProgrammeTypeID
	AND   a.CustomerID = d.CustomerID
	AND   d.MSDID = e.out_customerId
	AND   CAST(e.out_loyaltymembershipId AS NVARCHAR(256)) = a.ExtReference
	AND   c.ExtReference = e.out_loyaltytype
	AND   e.DataImportDetailID = @dataimportdetailid
	AND   e.ProcessedInd = 0

    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END