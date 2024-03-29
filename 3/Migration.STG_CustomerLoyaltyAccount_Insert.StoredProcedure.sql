USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_CustomerLoyaltyAccount_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_CustomerLoyaltyAccount_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	
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

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END
	
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
           ,a.out_loyaltystartdate
		   ,a.out_loyaltyenddate
		   ,@informationsourceid
		   ,CAST(a.out_loyaltymembershipId AS NVARCHAR(256))
    FROM [Migration].[MSD_LoyaltyProgrammeMembership] a,
	     [Staging].[STG_LoyaltyAccount] b,
	     [Staging].[STG_keyMapping] c, 
	     [Reference].[LoyaltyProgrammeType] d
    WHERE a.out_loyaltycardnumber = b.LoyaltyReference
	AND   a.out_customerId = c.MSDID
	AND   a.out_loyaltytype =  d.ExtReference
	AND b.LoyaltyProgrammeTypeID = d.LoyaltyProgrammeTypeID

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
