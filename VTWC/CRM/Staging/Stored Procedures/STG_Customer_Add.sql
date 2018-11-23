/*===========================================================================================
Name:			Staging.STG_Customer_Add
Purpose:		Insert new customer record into tables Staging.STG_Customer,  Staging.STG_KeyMapping
                ,Staging.STG_Address
Parameters:		@userid - The key for the user executing the proc.
				@informationsourceid - The key for information source 				
				@sourcecreateddate - date when source record was created
				@sourcemodifieddate - date when source record was modified
				@archivedind - flag to represent record is active or archived
				@salutation - customer title
				@firstname - customer firstname 
				@lastname - customer lastname 
				@datefirstpurchase - date when first purchase made
				@datelastpurchase - date when last purchase made 
				@tcscustomerid - business key
				@ispersonind - Flag to identify customer is a person
				@dateofbirth - customer date of birth
				@companyname - customer company name 
				@addressline1 - customer address line1
				@addressline2 - customer address line2
				@addressline3 - customer address line3
				@addressline4 - customer address line4
				@addressline5 - customer address line5
				@postcode - customer post code
				@country - customer country
				@neareststation - nearest station for customer 
				@vtsegment
				@accountstatus
				@regchannel  
				@regoriginatingsystemtype 
				@firstcalltrandate  
				@firstinttrandate      
				@firstmobapptrandate      
				@firstmobwebtrandate             
				@experianhouseholdincome           
				@experianageband                 
				@DebugPrint						  
				@PkgExecKey						 
				@DebugRecordset					   
				@customerid                        
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-01	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Staging.STG_Customer_Add
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_Customer_Add]
(
	@userid                            INTEGER          = 0,   
	@informationsourceid               INTEGER,
	@sourcecreateddate                 DATETIME,
	@sourcemodifieddate                DATETIME,
	@archivedind                       BIT              = 0,
	@salutation                        NVARCHAR(64)     = NULL,
	@firstname                         NVARCHAR(64)     = NULL,
	@lastname                          NVARCHAR(64)     = NULL,
	@datefirstpurchase                 DATETIME         = NULL,
	@datelastpurchase                  DATETIME         = NULL,
	@tcscustomerid                     INTEGER          = NULL,	
	@ispersonind                       BIT              = 1,
	@dateofbirth                       DATETIME,
	@companyname                       NVARCHAR(100)     = NULL,
	@addressline1					   NVARCHAR(512)     = NULL,
	@addressline2	                   NVARCHAR(512)     = NULL,
	@addressline3					   NVARCHAR(512)     = NULL,
	@addressline4	                   NVARCHAR(512)     = NULL,
	@addressline5	                   NVARCHAR(512)     = NULL,
	@postcode	                       NVARCHAR(100)     = NULL,
	@country	                       NVARCHAR(100)     = NULL,
	@neareststation                    NVARCHAR(5)       = NULL,
	@vtsegment                         INT               = NULL,
	@accountstatus                     NVARCHAR(25)      = NULL,
	@regchannel                        NVARCHAR(20)      = NULL,
	@regoriginatingsystemtype          NVARCHAR(20)      = NULL,
	@firstcalltrandate                 DATETIME          = NULL,
	@firstinttrandate                  DATETIME          = NULL,
	@firstmobapptrandate               DATETIME          = NULL,
	@firstmobwebtrandate               DATETIME          = NULL,
	@experianhouseholdincome           NVARCHAR(20)      = NULL,
	@experianageband                   NVARCHAR(10)      = NULL,
	@DebugPrint						   INTEGER			 = 0,
	@PkgExecKey						   INTEGER			 = -1,
	@DebugRecordset					   INTEGER			 = 0,
	@customerid                        INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @IsParentInd  INT = 1

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

	-- Start auditting
	--EXEC dbo.uspAuditAddAudit
	--		@AuditType='PROCESS START'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SELECT @dateofbirth = CASE WHEN YEAR(@dateofbirth) = 1899 THEN NULL ELSE @dateofbirth END 

	SET @ProcName = 'Staging.STG_Customer_Add'

	BEGIN TRY
		BEGIN TRAN

		--EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Perform Insert to Staging.STG_Customer'
  --                      ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		INSERT INTO [Staging].[STG_Customer]
			   ([CreatedDate]
			   ,[CreatedBy]
			   ,[LastModifiedDate]
			   ,[LastModifiedBy]
			   ,[ArchivedInd]
			   ,[SourceCreatedDate]
			   ,[SourceModifiedDate]
			   ,[Salutation]
			   ,[FirstName]
			   ,[LastName]
			   ,[InformationSourceID]
			   ,[DateFirstPurchase]
			   ,[DateLastPurchase]
			   ,[IsPersonInd]
			   ,[DateOfBirth]          
			   ,[NearestStation]
			   ,[VTSegment]
			   ,[AccountStatus]
			   ,[RegChannel]
			   ,[RegOriginatingSystemType]
			   ,[FirstCallTranDate]
			   ,[FirstIntTranDate]
			   ,[FirstMobAppTranDate]
			   ,[FirstMobWebTranDate]
			   ,[ExperianHouseholdIncome]
			   ,[ExperianAgeBand]
			   )
		VALUES( GETDATE()
			   ,@userid
			   ,GETDATE()
			   ,@userid
			   ,@archivedind
			   ,@sourcecreateddate
			   ,@sourcemodifieddate
			   ,@salutation
			   ,@firstname
			   ,@lastname
			   ,@informationsourceid
			   ,@datefirstpurchase
			   ,@datelastpurchase
			   ,@ispersonind
			   ,@dateofbirth          
			   ,@neareststation
			   ,@vtsegment
			   ,@accountstatus
			   ,@regchannel
			   ,@regoriginatingsystemtype
			   ,@firstcalltrandate
			   ,@firstinttrandate
			   ,@firstmobapptrandate
			   ,@firstmobwebtrandate
			   ,@experianhouseholdincome
			   ,@experianageband)

		SELECT @customerid = SCOPE_IDENTITY()

		SET @rows = @@rowcount

		--EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Prepare Customer Keys'
  --                  ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
		
		--EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Perform Insert to Staging.STG_KeyMapping'
  --                      ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		INSERT INTO [Staging].[STG_KeyMapping]
			   ([CreatedDate]
			   ,[CreatedBy]
			   ,[LastModifiedDate]
			   ,[LastModifiedBy]
			   ,[CustomerID]
			   ,[TCSCustomerID]
			   ,[InformationSourceID]
			   ,[IsParentInd])
		 VALUES
			   (GETDATE()
			   ,@userid
			   ,GETDATE()
			   ,@userid
			   ,@customerid
			   ,@tcscustomerid
			   ,@informationsourceid
			   ,@IsParentInd)

		SET @rows = @@rowcount

		--EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Prepare key Mapping Keys'
  --                  ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
		
		SET @StepName = 'Staging.STG_Address_Upsert'
		BEGIN TRY			

			--EXEC uspSSISProcStepStart @ProcName, @StepName

			EXEC [Staging].[STG_Address_Upsert]	  @customerid           = @customerid,   
												  @sourcecreateddate    = @sourcecreateddate,
												  @sourcemodifieddate   = @sourcemodifieddate,
												  @companyname          = @companyname,
												  @address1             = @addressline1,
												  @address2             = @addressline2,
												  @address3             = @addressline3,
												  @address4             = @addressline4,
												  @address5             = @addressline5,
												  @postcode             = @postcode,
												  @country              = @country
			--EXEC uspSSISProcStepSuccess @ProcName, @StepName

		END TRY
		BEGIN CATCH
			ROLLBACK TRAN;
			SELECT @ErrorMsg = 'Unable to update address for customer, cutomerid - '   + CAST(@customerid AS NVARCHAR(50));
			SET @ErrorNum = ERROR_NUMBER();
			EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
			THROW 51403, @ErrorMsg, 1; 
		END CATCH
		COMMIT TRAN
	END TRY
	BEGIN CATCH
	    ROLLBACK TRAN;
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;		
		THROW 51403, @ErrorMsg, 1; 
	END CATCH    

	-- End auditting
	--EXEC dbo.uspAuditAddAudit
	--	 @AuditType='PROCESS END'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid, @PrintToScreen=@DebugPrint
END
GO

