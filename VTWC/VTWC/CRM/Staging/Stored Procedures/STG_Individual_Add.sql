	CREATE PROCEDURE [Staging].[STG_Individual_Add]
		@userid                 INTEGER,   
		@informationsourceid    INTEGER,
		@sourcecreateddate      DATETIME,
		@sourcemodifieddate     DATETIME,
		@archivedind            BIT              = 0,
		@salutation             NVARCHAR(64)     = NULL,
		@firstname              NVARCHAR(64)     = NULL,
		@middlename             NVARCHAR(64)     = NULL,
		@lastname               NVARCHAR(64)     = NULL,
		@datefirstpurchase      DATETIME         = NULL,
		@individualid           INTEGER OUTPUT
	AS
	BEGIN
		SET NOCOUNT ON;

		DECLARE @spname                        NVARCHAR(256)
		DECLARE @logtimingidnew                INTEGER
		DECLARE @logmessage                    NVARCHAR(MAX)

		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

		SET @logmessage = '@userid = '                       +  ISNULL(CAST(@userid AS NVARCHAR(256)),'NULL') +
						  ', @informationsourceid = '        +  ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
						  ', @individualid = '               +  ISNULL(CAST(@individualid AS NVARCHAR(256)),'NULL') +
						  ', @sourcemodifieddate = '         +  ISNULL(CAST(@sourcemodifieddate AS NVARCHAR(256)),'NULL') +
						  ', @archivedind = '                +  ISNULL(CAST(@archivedind AS NVARCHAR(256)),'NULL') 
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
											  @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'DEBUG',
											  @messagetypecd   = 'Invalid Lookup'

		INSERT INTO [Staging].[STG_Individual]
		           ([CreatedDate]
		           ,[CreatedBy]
		           ,[LastModifiedDate]
		           ,[LastModifiedBy]
		           ,[ArchivedInd]
		           ,[SourceCreatedDate]
		           ,[SourceModifiedDate]
		           ,[InformationSourceID]
		           ,[Salutation]
		           ,[FirstName]
		           ,[MiddleName]
		           ,[LastName]
		           ,[DateFirstPurchase])
		     VALUES
		           (GETDATE()
		           ,@userid 
		           ,GETDATE()
		           ,@userid 
		           ,0
		           ,@sourcecreateddate
		           ,@sourcemodifieddate
		           ,@informationsourceid
		           ,@salutation
		           ,@firstname
		           ,@middlename
		           ,@lastname
		           ,@datefirstpurchase)

		SELECT @individualid = SCOPE_IDENTITY()

		RETURN @@rowcount;
	END