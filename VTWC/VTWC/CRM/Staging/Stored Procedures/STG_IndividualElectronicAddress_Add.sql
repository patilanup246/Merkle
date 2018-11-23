CREATE PROCEDURE [Staging].[STG_IndividualElectronicAddress_Add]
(
	@userid                 INTEGER       = 0,   
	@informationsourceid    INTEGER,
	@individualid           INTEGER       = NULL,
	@sourcemodifeddate      DATETIME,
	@address                NVARCHAR(256),
	@parsedaddress          NVARCHAR(256) = NULL,
	@parsedind              BIT           = 0,
	@parsedscore            INTEGER       = 0,
	@addresstypeid          INTEGER,
	@archivedind            BIT           = 0,
	@electronicaddressid   INTEGER OUTPUT
)
AS

BEGIN
    SET NOCOUNT ON;

	DECLARE @spname                        NVARCHAR(256)
	DECLARE @logtimingidnew                INTEGER
	DECLARE @logmessage                    NVARCHAR(MAX)
  DECLARE @lowercaseaddress              NVARCHAR(256) = lower(@address)
	DECLARE @vEncrytpedAddress             NVARCHAR(MAX) = Staging.[VT_HASH](@lowercaseaddress)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    SET @logmessage = '@userid = '              +  ISNULL(CAST(@userid AS NVARCHAR(256)),'NULL') +
	                  ', @informationsourceid = ' +  ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
        					  ', @individualid = '        +  ISNULL(CAST(@individualid AS NVARCHAR(256)),'NULL') +
        					  ', @sourcemodifeddate = '   +  ISNULL(CAST(@sourcemodifeddate AS NVARCHAR(256)),'NULL') +
        					  ', @archivedind = '         +  ISNULL(CAST(@archivedind AS NVARCHAR(256)),'NULL') +
        					  ', @address = '             +  ISNULL(@address,'NULL') + 
        					  ', @addresstypeid = '       +  ISNULL(CAST(@addresstypeid AS NVARCHAR(256)),'NULL')


	    
    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
                                          @logsource       = @spname,
                                          @logmessage      = @logmessage,
                                          @logmessagelevel = 'DEBUG',
                                          @messagetypecd   = 'Invalid Lookup'

    -- Archiving previous record
    UPDATE [Staging].[STG_ElectronicAddress]
       SET ArchivedInd = 1, 
           LastModifiedDate = GETDATE(),
           LastModifiedBy = @userid
     WHERE IndividualID = @individualid
	   AND [HashedAddress] = @vEncrytpedAddress
	   and ArchivedInd = 0

    --Add the new record
    INSERT INTO [Staging].[STG_ElectronicAddress]
      ([CreatedDate]
      ,[CreatedBy]
      ,[LastModifiedDate]
      ,[LastModifiedBy]
      ,[ArchivedInd]
      ,[InformationSourceID]
      ,[SourceChangeDate]
      ,[Address]
      ,[PrimaryInd]
      ,[AddressTypeID]
      ,[ParsedAddress]
      ,[ParsedInd]
      ,[ParsedScore]
      ,[IndividualID]
      ,[HashedAddress])
    VALUES
      (GETDATE()
      ,@userid
      ,GETDATE()
      ,@userid
      ,0
      ,@informationsourceid
      ,@sourcemodifeddate
      ,@lowercaseaddress
      ,1
      ,@addresstypeid
      ,@parsedaddress
      ,@parsedind
      ,@parsedscore
      ,@individualid
      ,Staging.[VT_HASH](@lowercaseaddress))

    SET @electronicaddressid = SCOPE_IDENTITY()

	RETURN @@ROWCOUNT
END