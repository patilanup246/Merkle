CREATE PROCEDURE [Production].[Individual_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @addresstypidemail        INTEGER
	DECLARE @addresstypidmobile       INTEGER
	DECLARE @defaultoptinleisure      INTEGER

	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @addresstypidemail = AddressTypeID
    FROM [Reference].[AddressType]
    WHERE Name = 'Email'

	SELECT @addresstypidmobile = AddressTypeID
    FROM [Reference].[AddressType]
    WHERE Name = 'Mobile'

	IF @addresstypidemail IS NULL OR @addresstypidmobile IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid Country or Address Types;' +
		                  ' @addresstypidemail = '   + ISNULL(@addresstypidemail,'NULL') + 
		                  ', @addresstypidmobile = ' + ISNULL(@addresstypidemail,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    
	    RETURN
	END

	SELECT @defaultoptinleisure = SubscriptionTypeID
	FROM   [Reference].[SubscriptionType]
	WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Leisure Subscription Type')

	IF @defaultoptinleisure IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid reference data; ' +
		                  ' @defaultoptinleisure = '   + ISNULL(@defaultoptinleisure,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

    INSERT INTO [Production].[Individual]
           ([IndividualID]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[InformationSourceID]
           ,[ValidEmailInd]
           ,[ValidMobileInd]
           ,[OptInLeisureInd]
           ,[OptInCorporateInd]
           ,[CountryID]
           ,[IsOrganisationInd]
		   ,[IsStaffInd]
		   ,[IsBlackListInd]
		   ,[IsCorporateInd]
		   ,[IsTMCInd]
           ,[Salutation]
           ,[FirstName]
           ,[MiddleName]
           ,[LastName]
           ,[EmailAddress]
           ,[MobileNumber]
           ,[PostalArea]
           ,[PostalDistrict]
		   ,[DateRegistered]
           ,[DateFirstPurchaseAny]
           ,[DateLastPurchaseAny])
    SELECT a.IndividualID
           ,NULL
           ,a.CreatedDate
           ,a.CreatedBy
           ,a.LastModifiedDate
           ,a.LastModifiedBy
           ,0
           ,a.InformationSourceID
           ,0                --<ValidEmailInd, bit,>
           ,0                --<ValidMobileInd, bit,>
           ,0                --<OptInLeisureInd, bit,>
           ,0                --<OptInCorporateInd, bit,>
           ,-99
           ,0
		   ,a.IsStaffInd
		   ,a.IsBlackListInd
		   ,a.IsCorporateInd
		   ,a.IsTMCInd
           ,a.Salutation
           ,a.FirstName
           ,a.MiddleName
           ,a.LastName
           ,isnull(b.ParsedAddress,b.Address)
           ,isnull(c.ParsedAddress,c.Address)
           ,NULL
           ,NULL
           ,a.SourceCreatedDate
           ,a.DateFirstPurchase
           ,a.DateLastPurchase
	FROM Staging.STG_Individual a
	LEFT OUTER JOIN Staging.STG_ElectronicAddress b ON a.IndividualID = b.IndividualID AND b.AddressTypeID = @addresstypidemail AND b.PrimaryInd = 1 AND b.ArchivedInd = 0
	LEFT OUTER JOIN Staging.STG_ElectronicAddress c ON a.IndividualID = c.IndividualID AND c.AddressTypeID = @addresstypidmobile AND c.PrimaryInd = 1 AND c.ArchivedInd = 0
	
	SELECT @recordcount = @@ROWCOUNT

--Validity flags for email and mobile numbers

    UPDATE a
	SET   ValidEmailInd = CASE ParsedScore WHEN 100 THEN 1 ELSE 0 END
	FROM  [Production].[Individual] a,
	      [Staging].[STG_ElectronicAddress] b
    WHERE  a.IndividualID = b.IndividualID
	AND    b.PrimaryInd = 1
	AND    b.AddressTypeID = @addresstypidemail

	UPDATE a
	SET   ValidMobileInd = CASE ParsedScore WHEN 100 THEN 1 ELSE 0 END
	FROM  [Production].[Individual] a,
	      [Staging].[STG_ElectronicAddress] b
    WHERE  a.IndividualID = b.IndividualID
	AND    b.PrimaryInd = 1
	AND    b.AddressTypeID = @addresstypidmobile

--Optin Flags - use email as the default channel

   --General Marketing Flag (Email)
   UPDATE a
	SET   OptInLeisureInd = b.Value
	FROM  [Production].[Individual] a
	      inner join [Staging].[STG_IndividualPreference] b on a.IndividualID=b.individualID
		  inner join [Reference].[Preference] c on b.PreferenceID=c.PreferenceID and c.Name='General Marketing Opt-In'
		  inner join [Reference].[Channel] d on d.ChannelID=b.ChannelID and d.Name='Email'

   --DfT Optin
	UPDATE a
	SET   OptInCorporateInd = b.value
	FROM  [Production].[Individual] a
	      inner join [Staging].[STG_IndividualPreference] b on a.IndividualID=b.individualID
		  inner join [Reference].[Preference] c on b.PreferenceID=c.PreferenceID and c.Name='DFT Opt-In'
		  inner join [Reference].[Channel] d on d.ChannelID=b.ChannelID and d.Name='None'

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END