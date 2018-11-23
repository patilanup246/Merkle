/*===========================================================================================
Name:			Operations.DataImportDetail_Insert
Purpose:		Insert DataImportDetail information for each feed file into table Operations.DataImportDetail
Parameters:		@userid - The key for the user executing the proc.
                @Feedtype - The type for the feed being processed.
				@importfilename - feed file name to be processed
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:		    Procedure creates control record for each feed file to be processed. Record is created at lowest granualar level so 
                each feed file can be processed indiviually.
			
Created:		2018-08-16	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Operations.DataImportDetail_Insert
=================================================================================================*/

CREATE PROCEDURE [Operations].[DataImportDetail_Insert]
(
	@userid                   INTEGER = 0,
	@Feedtype				  NVARCHAR (50),
	@importfilename           NVARCHAR(255),
	@DebugPrint				  INTEGER	   = 0,
	@PkgExecKey				  INTEGER	   =-1,
	@DebugRecordset			   INTEGER	   = 0
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

	DECLARE @operationalstatusid INT
	DECLARE @processingorder INT
	DECLARE @dataimportlogid INT

	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SET @ProcName = 'Operations.DataImportDetail_Insert'

   -- Check operation status id 
   SET @StepName = 'check if operation status id exists';

	SELECT @operationalstatusid = OperationalStatusID
	FROM   [Reference].[OperationalStatus]
	WHERE  Name = 'Pending'
	AND    ArchivedInd = 0

	IF @@ROWCOUNT = 0
    BEGIN	  
      SET @ErrorMsg = 'Unable to find the specified operation status';

	  EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey;

	  THROW 51403, @ErrorMsg,1;	       
     END   

	SELECT @processingorder = ProcessingOrder
	FROM Reference.DataImportDefinition
	WHERE Name = @Feedtype

	IF @@ROWCOUNT = 0
    BEGIN	  
      SET @ErrorMsg = 'Unable to find the specified processing order for the feed type';

	  EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey;

	  THROW 51403, @ErrorMsg,1;	       
     END   
	
	BEGIN TRY   		

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert Operations.DataImportDetail start'
                      ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint
	
	INSERT INTO [Operations].[DataImportDetail]
           ([Name]
          ,[CreatedDate]
          ,[CreatedBy]
          ,[LastModifiedDate]
          ,[LastModifiedBy]
          ,[ArchivedInd]
          ,[DataImportLogID]
          ,[DataImportDefinitionID]
          ,[OperationalStatusID]
          ,[ImportFileName]
          ,[ProcessingOrder]
		  ,[DestinationTable]
		  ,[StartTimePreprocessing])

	SELECT Name
		   , GETDATE()
		   , @userid
		   , GETDATE()
		   , @userid
		   , 0
		   , -1
		   , DataImportDefinitionID
		   , @operationalstatusid
		   , @importfilename
		   , @processingorder
		   , DestinationTable
		   , GETDATE()
	FROM Reference.DataImportDefinition 
	WHERE Name = @Feedtype

	SELECT @dataimportlogid = SCOPE_IDENTITY();

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert Operations.DataImportDetail end'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@@ROWCOUNT, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	-- End auditting
	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS END'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid, @PrintToScreen=@DebugPrint

    RETURN @dataimportlogid
END
GO

