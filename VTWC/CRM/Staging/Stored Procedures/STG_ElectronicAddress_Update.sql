
/*===========================================================================================
Name:			Staging.STG_ElectronicAddress_Update
Purpose:		Inserts customer electronic address(email,mobile), name and address key into table Staging.STG_ElectronicAddress
Parameters:		@userid - The key for the user executing the proc.
				@informationsourceid - The key for information source 
				@customerid - The CRM customer key 	
				@individualid - CRM Indiviual/Prospect key 		
				@sourcemodifieddate - date when source record was modified
				@address - Unparsed electonic address/ namad key 
				@parsedaddress - parsed electonic address/ namad key 
				@parsedind - parsed indicator
				@parsedscore  - parsed score
				@addresstypeid - The key for the address type
				@archivedind - archived flag
				@primaryind - primary indicator flag
				@recordcount - count of records inserted 
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-01	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Staging.STG_ElectronicAddress_Update
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_ElectronicAddress_Update]
(
	@userid                 INTEGER       = 0,   
	@informationsourceid    INTEGER,
	@customerid             INTEGER       = NULL,
	@individualid           INTEGER       = NULL,
	@sourcemodifeddate      DATETIME,
	@address                NVARCHAR(256),
	@parsedaddress          NVARCHAR(256) = NULL,
	@parsedind              BIT           = 0,
	@parsedscore            INTEGER       = 0,
	@addresstypeid          INTEGER,
	@archivedind            BIT           = 0,
	@primaryind             INT           = 1,
	@DebugPrint	            INTEGER	      = 0,
	@PkgExecKey	            INTEGER	      =-1,
	@DebugRecordset         INTEGER	      = 0,
	@recordcount            INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	
	DECLARE @AddressInsert                 INT = 1

	DECLARE @spid	INTEGER	= @@SPID
	DECLARE @spname  SYSNAME = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
	DECLARE @dbname  SYSNAME = DB_NAME()
	DECLARE @Rows	INTEGER = 0
	DECLARE @ProcName NVARCHAR(50)
	DECLARE @StepName NVARCHAR(50)

	DECLARE  @ErrorMsg		NVARCHAR(MAX)
	DECLARE  @ErrorNum		INTEGER
	DECLARE  @ErrorSeverity	 NVARCHAR(255)
	DECLARE  @ErrorState NVARCHAR(255)

	--EXEC dbo.uspAuditAddAudit
	--	 @AuditType='PROCESS START'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SET @ProcName = 'Staging.STG_ElectronicAddress_Update'

    --Change the current, if the primary address is changed
	IF (@archivedind = 0)
	BEGIN

	   --EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Archive current electronic address'
    --                    ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		-- Archive current electronic address
		UPDATE [Staging].[STG_ElectronicAddress]
		SET    PrimaryInd       = 0,
			   ArchivedInd      = 1,
			   LastModifiedBy   = @userid,
			   LastModifiedDate = GETDATE(),
			   SourceChangeDate = @sourcemodifeddate
		WHERE  AddressTypeID    = @addresstypeid
		AND (
				(CustomerID     = @customerid)
				OR (IndividualID = @individualid)
			)
		AND  PrimaryInd       = 1

		 --EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Archive current electronic address'
   --                     ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint
	END

	-- if electronic address already exists, set the primary flag
	IF EXISTS(SELECT *
				FROM [Staging].[STG_ElectronicAddress]
				WHERE  AddressTypeID    = @addresstypeid
				AND (
						(CustomerID = @customerid)
						OR (IndividualID	= @individualid)
					)
				AND ParsedAddress = @parsedaddress)
		BEGIN
			
			SET @AddressInsert = 0 

			--EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Set primary flag to current for existing electronic address'
   --                     ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

			UPDATE [Staging].[STG_ElectronicAddress]
			SET    PrimaryInd       = @primaryind,
				   ArchivedInd      = @archivedind,
				   LastModifiedBy   = @userid,
				   LastModifiedDate = GETDATE(),
				   SourceChangeDate = @sourcemodifeddate
			WHERE  AddressTypeID    = @addresstypeid
			AND (
					(CustomerID = @customerid)
				OR (IndividualID = @individualid)
			)
			AND ParsedAddress = @parsedaddress

			--EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Set primary flag to current for existing electronic address'
   --                     ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint
		END

	--Add the new record, if the electronic doesn't exists
	IF (@AddressInsert = 1)
		BEGIN
		
			--EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert electronic address'
   --                     ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

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
				   ,[CustomerID]
				   ,[IndividualID]
				   ,[HashedAddress])
			 VALUES
				   (GETDATE()
				   ,@userid
				   ,GETDATE()
				   ,@userid
				   ,@archivedind
				   ,@informationsourceid
				   ,@sourcemodifeddate
				   ,@address
				   ,@primaryind
				   ,@addresstypeid
				   ,@parsedaddress
				   ,@parsedind
				   ,@parsedscore
				   ,@customerid
				   ,@individualid
				   ,Staging.[VT_HASH](lower(@parsedaddress)))

			--EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert electronic address'
   --                     ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint
		END

	SELECT @recordcount = @@ROWCOUNT

	-- End auditting
	--EXEC dbo.uspAuditAddAudit
	--	 @AuditType='PROCESS END'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid,@Rows = @Rows, @PrintToScreen=@DebugPrint

	RETURN 
END