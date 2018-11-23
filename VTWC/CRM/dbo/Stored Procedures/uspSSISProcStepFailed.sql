
/*===========================================================================================
Name:			uspSSISProcStepFailed
Purpose:		Report / Record proc errors to screen and AuditErrorLog
Parameters:		@ProcName - The name of the stored procedure that needs to be logged.
				@StepName - The name of the step within the calling SP that needs to be logged.
				@PkgExecKey - Optional the calling Package Key
Notes:			    
			
Created:		2009-05-16	Caryl Wills
Modified    	2010-06-07	Philip Robinson. Adding code to record the errors in AuditErrorLog.
Modified:   	2010-11-16	Philip Robinson. Added calls to central logging mechanism.
Modified:   	2011-02-09	Philip Robinson. Adding ISNULL round PkgExecKey for insert to 
							AuditErrorLog. And changing default=-1.
Modified:   	2011-08-22	Philip Robinson. Added cast to varchar(255) for error msg as this is
							the current size of AuditErrorLog.Description.

Call script:	EXEC uspSSISProcStepFailed ?,?,?,?,?
=================================================================================================*/
CREATE PROCEDURE  dbo.uspSSISProcStepFailed
				 @ProcName VARCHAR(50),
				 @StepName VARCHAR(50),
				 @ErrorNum INT,
				 @ErrorMsg NVARCHAR(2048),
				 @PkgExecKey INT = -1     -- Optional. If provided this will be used as key. Otherwise try and find key from AuditPkgExecution.
AS
	DECLARE @ThisDb sysname = DB_NAME()
		   ,@SPID int = @@SPID

	EXEC synUspAudit
		 @AuditType='ERROR', @Message=@ErrorMsg
		,@Process=@ProcName, @ProcessStep=@StepName,@DatabaseName=@ThisDb,@SPID =@SPID, @PrintToScreen=1

	INSERT INTO dbo.AuditErrorLog
	(
		PkgExecKey,
		FeedFileKey,
		ErrorCode,
		SourceColumnName,
		Occurred,
		Description,
		DateCreated
	)
	VALUES
	(
		ISNULL(@PkgExecKey, -1),
		-1,
		@ErrorNum,
		@StepName,
		GETDATE(),
		CONVERT(varchar(255), @ErrorMsg),
		GETDATE()
	)