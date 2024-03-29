USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_LoyaltyAllocation_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_LoyaltyAllocation_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	DECLARE @loyaltystatusid        INTEGER
	DECLARE @now                    DATETIME

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = [Reference].[Configuration_GetSetting] ('Migration','MSD Source')

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
		   ,a.CreatedOn
		   ,a.ModifiedOn
		   ,@loyaltystatusid
		   ,d.LoyaltyAccountID
		   ,b.SalesTransactionID
		   ,b.SalesTransactionDate
		   ,NULL
		   ,NULL
		   ,b.SalesAmountRail
		   ,a.out_noofpoints
		   ,@informationsourceid
		   ,CAST(a.out_loyaltybookingId AS NVARCHAR(256))
    FROM Migration.MSD_LoyaltyProgramme a,
	     Staging.STG_SalesTransaction b,
		 Staging.STG_KeyMapping c,
		 Staging.STG_CustomerLoyaltyAccount d
	WHERE a.out_loyaltycustomerId = c.MSDID
	AND   b.ExtReference = CAST(a.out_loyaltybookingId AS NVARCHAR(256))
	AND   b.CustomerID = c.CustomerID
	AND   b.CustomerID = d.CustomerID
	AND   b.SalesTransactionDate BETWEEN d.StartDate AND ISNULL(d.EndDate,@now)
	
	
	SELECT @recordcount = @@ROWCOUNT

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END



GO
