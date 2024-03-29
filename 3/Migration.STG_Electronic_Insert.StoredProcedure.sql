USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_Electronic_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_Electronic_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	DECLARE @addresstypidemail      INTEGER
	DECLARE @addresstypidmobile     INTEGER
	
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

	SELECT @addresstypidemail = AddressTypeID
    FROM [Reference].[AddressType]
    WHERE Name = 'Email'

	SELECT @addresstypidmobile = AddressTypeID
    FROM [Reference].[AddressType]
    WHERE Name = 'Mobile'

	IF @addresstypidemail IS NULL OR @addresstypidmobile IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid Address Types;@addresstypidemail = ' + ISNULL(@addresstypidemail,'NULL') + 
		                  ', @addresstypidmobile = ' + ISNULL(@addresstypidemail,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    
	    RETURN
	END

	--Email Address

	INSERT INTO [Staging].[STG_ElectronicAddress]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SourceChangeDate]
           ,[InformationSourceID]
           ,[Address]
           ,[PrimaryInd]
           ,[UsedInCommunicationInd]
           ,[ParsedInd]
		   ,[ParsedScore]
           ,[IndividualID]
           ,[CustomerID]
           ,[AddressTypeID]
           ,[ParsedAddress])
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,a.ModifiedOn
           ,@informationsourceid
           ,RTRIM(LTRIM(a.EMailAddress1))
           ,1
           ,0
		   ,0
           ,0
           ,NULL
           ,b.CustomerID
           ,@addresstypidemail
           ,NULL
    FROM Migration.MSD_Contact a,
	     Staging.STG_Customer b,
		 Staging.STG_KeyMapping c
	WHERE a.ContactId = c.MSDID
	AND   b.CustomerID = c.CustomerID
	AND   a.EMailAddress1 IS NOT NULL

	SELECT @recordcount = @@ROWCOUNT

	--Add Mobile Phone

	INSERT INTO [Staging].[STG_ElectronicAddress]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[SourceChangeDate]
           ,[InformationSourceID]
           ,[Address]
           ,[PrimaryInd]
           ,[UsedInCommunicationInd]
           ,[ParsedInd]
		   ,[ParsedScore]
           ,[IndividualID]
           ,[CustomerID]
           ,[AddressTypeID]
           ,[ParsedAddress])
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,a.ModifiedOn
           ,@informationsourceid
           ,RTRIM(LTRIM(a.MobilePhone))
           ,1
           ,0
           ,0
		   ,0
           ,NULL
           ,b.CustomerID
           ,@addresstypidmobile
           ,NULL
    FROM Migration.MSD_Contact a,
	     Staging.STG_Customer b,
		 Staging.STG_KeyMapping c
	WHERE a.ContactId = c.MSDID
	AND   b.CustomerID = c.CustomerID
	AND   a.MobilePhone IS NOT NULL

	SELECT @recordcount = @recordcount + @@ROWCOUNT
	
	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END











GO
