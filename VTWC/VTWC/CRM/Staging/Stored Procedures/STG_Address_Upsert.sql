
/*===========================================================================================
Name:			Staging.STG_Address_Upsert
Purpose:		Insert/Update new customer address into table Staging.STG_Address
Parameters:		@customerid - The CRM customer key 		
				@sourcecreateddate - date when source record was created
				@sourcemodifieddate - date when source record was modified
				@companyname - customer company name 
				@addressline1 - customer address line1
				@addressline2 - customer address line2
				@addressline3 - customer address line3
				@addressline4 - customer address line4
				@addressline5 - customer address line5
				@postcode - customer post code
				@country - customer country
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-01	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Staging.STG_Address_Upsert
=================================================================================================*/

  CREATE PROCEDURE [Staging].[STG_Address_Upsert] 
     @customerid     int,         
	 @SourceCreatedDate datetime   = NULL,
	 @SourceModifiedDate datetime  = NULL,
	 @companyname    nvarchar(100) = NULL,
     @address1       nvarchar(512) = NULL,
     @address2       nvarchar(512) = NULL,
     @address3       nvarchar(512) = NULL,
     @address4       nvarchar(512) = NULL,
     @address5       nvarchar(512) = NULL,
     @postcode       nvarchar(512) = NULL,
     @country        nvarchar(512) = NULL,	 
	 @DebugPrint	 INTEGER	   = 0,
	 @PkgExecKey	 INTEGER	   =-1,
	 @DebugRecordset INTEGER	   = 0
  ----------------------------------------
  AS 
  BEGIN

  
   SET NOCOUNT ON;

   DECLARE @userid                 INTEGER = 0

   DECLARE @CreatedDate datetime        = GETDATE()
   DECLARE @LastModifiedDate datetime   = GETDATE()

   DECLARE @ArchivedInd int             = 0
   DECLARE @PrimaryInd int              = 1
   DECLARE @AddressTypeID int           

   DECLARE @countryID int;
   DECLARE @InformationSourceID int 

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

	SET @ProcName = 'Staging.STG_Address_Upsert'

   -- TrainLine is the InformationSource 
   SET @StepName = 'check if information source id exists';

   SELECT @InformationSourceID = InformationSourceID
   FROM Reference.InformationSource
   WHERE Name = 'TrainLine'
   AND ArchivedInd = 0

  
   IF @@ROWCOUNT = 0
     BEGIN	  
      SET @ErrorMsg = 'Unable to find the specified Informaion Source (TrainLine)';

	  EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey;

	  THROW 51403, @ErrorMsg,1;	       
     END   

	-- Contact Address
	SET @StepName = 'check if contact address type id exists';

	SELECT @AddressTypeID = AddressTypeID
	FROM Reference.AddressType
	WHERE [Name] = 'Contact'	
	
	IF @@ROWCOUNT = 0
     BEGIN	   
	   SET @ErrorMsg = 'Unable to find the specified Address Type (Contact)';

	   EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey;

       THROW 51403, @ErrorMsg,1;
     END   

   -- Getting Country ID from Country Name
   SET @StepName = 'check if country id exists';
   SELECT @countryID = CountryID
   FROM Reference.Country C
   WHERE C.Name = @country;

   IF @@ROWCOUNT = 0
     BEGIN
	   SET @ErrorMsg = 'Unable to find the specified country ('+@country+')';

	   EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey;

	   THROW 51403, @ErrorMsg,1;
     END      
	
	SET @StepName = 'Insert/Update customer address';

	BEGIN TRY   		

		--EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert/Update customer address'
  --                      ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		MERGE Staging.STG_Address AS TRGT
		USING (SELECT @CreatedDate as createddate, @userid as userid, @LastModifiedDate as lastmodifieddate
				,@ArchivedInd as archivedind, @InformationSourceID as informationsourceid,@SourceCreateDDate as sourcecreatedate
				,@SourceModifiedDate as sourcemodifieddate, @companyname as companyname, @address1 as address1
				,@address2 as address2, @address3 as address3, @address4 as address4, @address5 as address5
				,@postcode as postcode, @CountryID as countryid, @PrimaryInd as primaryind, @AddressTypeID as addresstype
				,@CustomerID as customerid) AS SRC
		ON TRGT.CustomerID		= SRC.customerid
		AND ISNULL(TRGT.companyname, '')	= ISNULL(SRC.companyname, '')
		AND ISNULL(TRGT.addressline1, '')	= ISNULL(SRC.address1, '')
		AND ISNULL(TRGT.addressline2, '')	= ISNULL(SRC.address2, '')
		AND ISNULL(TRGT.addressline3, '')	= ISNULL(SRC.address3, '')
		AND ISNULL(TRGT.addressline4, '')	= ISNULL(SRC.address4, '')
		AND ISNULL(TRGT.addressline5, '')	= ISNULL(SRC.address5, '')
		AND ISNULL(TRGT.postalcode, '')		= ISNULL(SRC.postcode, '')
		AND ISNULL(TRGT.countryid, 0)		= ISNULL(SRC.countryid, 0)
		WHEN NOT MATCHED THEN
		-- Inserting new Customer Contact Address Information
		INSERT (CreatedDate, CreatedBy, LastModifiedDate, LastModifiedBy, ArchivedInd
				,InformationSourceID, SourceCreatedDate, SourceModifiedDate, CompanyName
				,AddressLine1, AddressLine2, AddressLine3, AddressLine4, AddressLine5
				,PostalCode, CountryID, PrimaryInd, AddressTypeID, CustomerID)
		VALUES
				(@CreatedDate, @userid, @LastModifiedDate, @userid, @ArchivedInd, @InformationSourceID
				,@SourceCreateDDate, @SourceModifiedDate, companyname, address1, address2, address3
				,address4, address5, postcode, @CountryID, @PrimaryInd, @AddressTypeID,CustomerID)
		WHEN MATCHED 
			AND TRGT.PrimaryInd =0
			THEN
				UPDATE 
				SET [PrimaryInd] = 1
					,[LastModifiedDate] = @LastModifiedDate;


		;WITH CuotmerPrimaryAddress AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY LastModifiedDate Desc) AS ROW_RANK
			FROM Staging.STG_Address
			WHERE CustomerID =@customerid
			AND PrimaryInd = 1
		)
		UPDATE c 
		SET PrimaryInd = 0 
		FROM CuotmerPrimaryAddress c
		WHERE ROW_RANK > 1;

		--EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert/Update customer address'
  --                      ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	-- End auditting
	--EXEC dbo.uspAuditAddAudit
	--	 @AuditType='PROCESS END'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid, @PrintToScreen=@DebugPrint
 END