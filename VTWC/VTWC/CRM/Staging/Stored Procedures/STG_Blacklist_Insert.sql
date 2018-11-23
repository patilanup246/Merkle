CREATE PROCEDURE [Staging].[STG_Blacklist_Insert]
(
	@userid                INTEGER       = 0,
	@informationsourceid   INTEGER,
	@address               NVARCHAR(256),
	@parsedaddress         NVARCHAR(256) = NULL,
	@parsedind             BIT           = 0,
	@parsedscore           INTEGER       = 0,
	@addresstypeid         INTEGER,
	@archivedind           BIT           = 0,
	@blacklistid           INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    SET @logmessage = '@userid = '                +  ISNULL(CAST(@userid AS NVARCHAR(256)),'NULL') +
	                  ', @informationsourceid = ' +  ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
        			  ', @archivedind = '         +  ISNULL(CAST(@archivedind AS NVARCHAR(256)),'NULL') +
        			  ', @address = '             +  ISNULL(@address,'NULL') + 
        			  ', @addresstypeid = '       +  ISNULL(CAST(@addresstypeid AS NVARCHAR(256)),'NULL')

    
    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
                                          @logsource       = @spname,
                                          @logmessage      = @logmessage,
                                          @logmessagelevel = 'DEBUG',
                                          @messagetypecd   = 'Invalid Lookup'

    INSERT INTO [Staging].[STG_Blacklist]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[Address]
           ,[AddressTypeID]
           ,[ParsedAddress]
           ,[InformationSourceID])
    VALUES (GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,@archivedind
           ,@address
           ,@addresstypeid
           ,@parsedaddress
           ,@informationsourceid)    

    SET @blacklistid = SCOPE_IDENTITY()

	--UPDATE a
	--SET  IsBlackListInd = 1
	--FROM Staging.STG_Customer a,
	--     Staging.STG_ElectronicAddress b,
	--	 Staging.STG_Blacklist c
 --   WHERE a.CustomerID = b.CustomerID
	--AND   b.Address = c.Address
	--AND   b.AddressTypeID = c.AddressTypeID
	--AND   b.Address = @address
	--AND   c.ArchivedInd = 0

	--UPDATE a
	--SET  IsBlackListInd = 1
	--FROM Staging.STG_Individual a,
	--     Staging.STG_ElectronicAddress b,
	--	 Staging.STG_Blacklist c
 --   WHERE a.IndividualID = b.IndividualID
	--AND   b.Address = c.Address
	--AND   b.AddressTypeID = c.AddressTypeID
	--AND   b.Address = @address
	--AND   c.ArchivedInd = 0

	RETURN
END