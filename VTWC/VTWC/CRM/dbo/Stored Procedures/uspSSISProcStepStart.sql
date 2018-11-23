
/*===========================================================================================
Name:			uspSSISProcStepStart
Purpose:		Empty SP stub.
Parameters:		@ProcName - The name of the stored procedure that needs to be logged.
				@StepName - The name of the step within the calling SP that needs to be logged.
Notes:			    
			
Created:		2009-05-16	Caryl Wills
Modified		2010-11-16  Philip Robinson. Added calls to central logging mechanism.

Call script:	EXEC uspSSISProcStepStart ?,?
=================================================================================================*/
CREATE PROCEDURE dbo.uspSSISProcStepStart
				 @ProcName VARCHAR(50),
				 @StepName VARCHAR(50)
AS

	DECLARE @ThisDb sysname = DB_NAME()
		   ,@SPID int = @@SPID

	EXEC synUspAudit
		 @AuditType='PROCESS START'
		,@Process=@ProcName, @ProcessStep=@StepName ,@DatabaseName=@ThisDb, @SPID =@SPID, @PrintToScreen=1