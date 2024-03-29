USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_LoyaltyAccount_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_LoyaltyAccount_Insert]
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

	;WITH CTE AS (
    SELECT b.LoyaltyProgrammeTypeID
          ,a.out_loyaltycardnumber
          ,a.CreatedOn
          ,a.ModifiedOn
          ,ROW_NUMBER() OVER (partition by a.out_loyaltycardnumber,a.out_loyaltycardnumber order by a.CreatedOn) Ranking
    FROM Migration.MSD_LoyaltyProgrammeMembership a,
	     Reference.LoyaltyProgrammeType b,
		 Staging.STG_KeyMapping c
	WHERE a.out_customerId = c.MSDID
	AND   b.ExtReference = a.out_loyaltytype)

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
