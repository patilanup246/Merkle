
/*===========================================================================================
Name:			Staging.STG_Customer_Update
Purpose:		Update existing customer record in table Staging.STG_Customer
Parameters:		@userid - The key for the user executing the proc.
				@informationsourceid - The key for information source 	
				@customerid - The key for CRM customer 				
				@sourcecreateddate - date when source record was created
				@sourcemodifieddate - date when source record was modified
				@archivedind - flag to represent record is active or archived
				@salutation - customer title
				@firstname - customer firstname 
				@lastname - customer lastname 
				@datefirstpurchase - date when first purchase made
				@dateofbirth - customer date of birth
				@neareststation - nearest station for customer 
				@vtsegment
				@accountstatus          
				@experianhouseholdincome           
				@experianageband 
				@recordcount - count of records updated                
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


CREATE PROCEDURE [Staging].[STG_Customer_Update]
(
	@userid                 INTEGER      = 0,   
	@informationsourceid    INTEGER,
	@customerid             INTEGER,
	--@sourcecreateddate      DATETIME,
	@sourcemodifieddate     DATETIME,
	@archivedind            BIT          = 0,
	@salutation             NVARCHAR(64) = NULL,
	@firstname              NVARCHAR(64) = NULL,
	@lastname               NVARCHAR(64) = NULL,
	@datefirstpurchase      DATETIME     = NULL,
	@datelastpurchase       DATETIME     = NULL,
	@dateofbirth            DATETIME,
	@neareststation         NVARCHAR(5)  = NULL,
	@vtsegment              INT          = NULL,
	@accountstatus          NVARCHAR(25) = NULL,
	@experianhouseholdincome NVARCHAR(20)= NULL,
	@experianageband        NVARCHAR(10) = NULL,
    @DebugPrint				INTEGER		 = 0,
	@PkgExecKey				INTEGER		 = -1,
	@DebugRecordset			INTEGER		 = 0,
	@recordcount            INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

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

	SET @ProcName = 'Staging.STG_Customer_Update'

	--EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Perform Update to Staging.STG_Customer'
 --                       ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

    UPDATE [Staging].[STG_Customer]
    SET    [LastModifiedDate]    = GETDATE()
          ,[LastModifiedBy]      = @userid
		  --,[SourceCreatedDate]   = @sourcecreateddate
		  ,[SourceModifiedDate]  = @sourcemodifieddate
		  ,[ArchivedInd]         = @archivedind
          ,[Salutation]          = @salutation
          ,[FirstName]           = @firstname
          ,[LastName]            = @lastname
          ,[InformationSourceID] = @informationsourceid
          ,[DateFirstPurchase]   = @datefirstpurchase
		  ,DateLastPurchase      = @datelastpurchase
		  ,[DateOfBirth]         = @dateofbirth
		  ,[NearestStation]      = @neareststation
		  ,[VTSegment]           = @vtsegment
		  ,[AccountStatus]       = @accountstatus
		  ,[ExperianHouseholdIncome] = @experianhouseholdincome
		  ,[ExperianAgeBand]     = @experianageband
    WHERE CustomerID = @customerid

	SELECT @recordcount = @@ROWCOUNT

	--EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Complete Update to Staging.STG_Customer'
 --                       ,@Process=@spname, @DatabaseName=@dbname, @Rows=@recordcount, @PrintToScreen=@DebugPrint

	-- End auditting
	--EXEC dbo.uspAuditAddAudit
	--	 @AuditType='PROCESS END'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid, @PrintToScreen=@DebugPrint

	RETURN 
END