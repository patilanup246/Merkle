USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_Prospect_Electronic_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_Prospect_Electronic_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;
	
	/**********************************************************************************
	**  Date: 10-08-2016                                                             **
	**                                                                               **
	**  Amendment to support processing of additionl Zeta Prospects:                 **
	**  1. To reference field Migration.Zeta_Prospect.FinalMigrateInd to only load   **
	**     new prospect information.                                                 **
	**                                                                               **
	**********************************************************************************/

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
    WHERE Name = 'Legacy - Zeta'

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
		   ,a.CreatedDate
           ,@informationsourceid
           ,RTRIM(LTRIM(a.EMailAddress))
           ,1
           ,0
		   ,0
           ,0
           ,b.IndividualID
           ,NULL
           ,@addresstypidemail
           ,NULL
    FROM Migration.Zeta_Prospect a
	INNER JOIN Staging.STG_KeyMapping c ON CAST(a.ZetaCustomerID AS NVARCHAR(256)) = c.ZetaCustomerID
	INNER JOIN Staging.STG_Individual b ON b.IndividualID = c.IndividualID 
    LEFT JOIN Staging.STG_ElectronicAddress d ON b.IndividualID = d.IndividualID AND d.AddressTypeID = @addresstypidemail
	WHERE d.IndividualID IS NULL
	AND   a.EMailAddress IS NOT NULL
	AND   a.FinalMigrateInd = 1
 
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
		   ,a.CreatedDate
           ,@informationsourceid
           ,RTRIM(LTRIM(a.MobileNumber))
           ,1
           ,0
           ,0
		   ,0
           ,b.IndividualID
           ,NULL
           ,@addresstypidmobile
           ,NULL
    FROM Migration.Zeta_Prospect a
	INNER JOIN Staging.STG_KeyMapping c ON CAST(a.ZetaCustomerID AS NVARCHAR(256)) = c.ZetaCustomerID
	INNER JOIN Staging.STG_Individual b ON b.IndividualID = c.IndividualID 
    LEFT JOIN Staging.STG_ElectronicAddress d ON b.IndividualID = d.IndividualID AND d.AddressTypeID = @addresstypidmobile
	WHERE d.IndividualID IS NULL
	AND   a.FinalMigrateInd = 1
	AND   a.MobileNumber IS NOT NULL
	AND   LEN(a.MobileNumber) > 5


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
