USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_Customer_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_Customer_Insert]
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

    INSERT INTO [Staging].[STG_Customer]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[MSDID]
           ,[SourceCreatedDate]
		   ,[SourceModifiedDate]
           ,[Salutation]
           ,[FirstName]
           ,[LastName]
		   ,[InformationSourceID]
		   ,[DateFirstPurchase])
    SELECT GETDATE()
	       ,@userid
		   ,GETDATE()
		   ,@userid
		   ,0
		   ,ContactID
		   ,CreatedOn
		   ,ModifiedOn
		   ,Salutation
		   ,FirstName
		   ,LastName
		   ,@informationsourceid
		   ,out_datefirstpurchased
    FROM   Migration.MSD_Contact
	WHERE  MigrateInd = 1

	SELECT @recordcount = @@ROWCOUNT
	
	UPDATE a
	SET  CustomerID = b.CustomerID 
	FROM Staging.STG_KeyMapping a,
	     Staging.STG_Customer b
	WHERE a.MSDID = b.MSDID

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END











GO
