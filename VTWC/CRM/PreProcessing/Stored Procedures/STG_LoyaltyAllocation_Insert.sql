
CREATE PROCEDURE [PreProcessing].[STG_LoyaltyAllocation_Insert]
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
    DECLARE @loyaltystatusid        INTEGER

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

	SELECT @loyaltystatusid = LoyaltyStatusID
	FROM   [Reference].[LoyaltyStatus]
	WHERE  Name = 'Confirmed'

	IF @informationsourceid IS NULL OR @loyaltystatusid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid options: ' + 
		                  '@informationsourceid = ' + ISNULL(@informationsourceid,'NULL') +
						  ', @loyaltystatusid = '   + ISNULL(@loyaltystatusid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
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

	INSERT INTO [Staging].[STG_LoyaltyAllocation]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[LoyaltyStatusID]
           ,[LoyaltyAccountID]
           ,[SalesTransactionID]
		   ,[SalesTransactionDate]
           ,[SalesDetailID]
           ,[LoyaltyXChangeRateID]
           ,[QualifyingSalesAmount]
           ,[LoyaltyCurrencyAmount]
           ,[InformationSourceID]
           ,[ExtReference])
     SELECT a.[out_offerid]
           ,a.[out_description]
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,Staging.SetUKTime(a.CreatedOn)
		   ,Staging.SetUKTime(a.ModifiedOn)
		   ,@loyaltystatusid
		   ,d.LoyaltyAccountID
		   ,b.SalesTransactionID
		   ,b.SalesTransactionDate
		   ,NULL
		   ,NULL
		   ,b.SalesAmountRail
		   ,a.out_noofpoints
		   ,@informationsourceid
		   ,CAST(a.out_loyaltyprogrammeid AS NVARCHAR(256))
    FROM PreProcessing.MSD_LoyaltyProgramme a
	INNER JOIN Staging.STG_SalesTransaction b       ON b.ExtReference = CAST(a.out_loyaltybookingId AS NVARCHAR(256))
	INNER JOIN Staging.STG_KeyMapping c             ON a.out_loyaltycustomerId = c.MSDID
	INNER JOIN Staging.STG_CustomerLoyaltyAccount d ON b.CustomerID = d.CustomerID
	LEFT JOIN  [Staging].[STG_LoyaltyAllocation] e  ON e.SalesTransactionID = b.SalesTransactionID
	WHERE e.LoyaltyAllocationID IS NULL
	AND   a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0
	AND   b.SalesTransactionDate BETWEEN d.StartDate AND ISNULL(d.EndDate,GETDATE())

--Mark those which have been processed

    UPDATE a
    SET   ProcessedInd = 1
	FROM PreProcessing.MSD_LoyaltyProgramme a,
	     Staging.STG_LoyaltyAllocation b
	WHERE b.ExtReference = CAST(a.out_loyaltyprogrammeid AS NVARCHAR(256))
	AND   a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

--log audit information

 	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.MSD_LoyaltyProgramme
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.MSD_LoyaltyProgramme
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