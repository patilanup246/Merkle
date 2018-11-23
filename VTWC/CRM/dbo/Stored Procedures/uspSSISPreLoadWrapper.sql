
/*===========================================================================================
Name:			uspSSISPreLoadWrapper
Purpose:		Empty SP stub.
Parameters:		
Notes:			    

-- Base template modifications			
Created:		2010-05-16	Caryl Wills
Modified:		2010-11-16 Philip Robinson. Added calls to central logging mechanism.
Modified:       2011-02-09  Philip Robinson. Adding @PkgExecKey as final param to proc failure.
Modified:		2010-11-16 Philip Robinson. Added calls to central logging mechanism.

-- Client specific implementation
Created:		
Modified:		
			
Call script:	EXEC uspSSISPreLoadWrapper
=================================================================================================*/
CREATE PROCEDURE [dbo].[uspSSISPreLoadWrapper]
				 @PkgExecKey INT = -1
				,@DebugPrint int = 0
				,@DebugRecordset int = 0
AS
	DECLARE @ThisDb sysname = DB_NAME()
		   ,@ThisProc sysname = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
		   ,@SPID int = @@SPID
		   ,@Rows int 

	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@ThisProc, @DatabaseName=@ThisDb,@SPID =@SPID, @PrintToScreen=1

	DECLARE @ProcName AS VARCHAR(50)
	DECLARE @StepName AS VARCHAR(50)
	
	-- Use @ProcName to define procs being called.
	SET @ProcName = 'uspSSISPreLoadWrapper'


	
	/*
	-- Description of the step.
	BEGIN TRY
		SET @StepName = 'uspSSISUpdateContactability'
		EXEC uspSSISProcStepStart @ProcName, @StepName
		EXEC xxx
		EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;
	RAISERROR('',10,1) WITH NOWAIT
	--*/
	
-- Example of trace start and end to be wrapped around sql statements!!!
/*

        EXEC synUspAudit @AuditType='TRACE START', @ProcessStep='Perform UPDATE to FactVoucherRedemption'
                        ,@Process=@ThisProc, @DatabaseName=@ThisDb, @Rows=null, @PrintToScreen=@DebugPrint

update dbo.tableName set value = ''
set @rows = @@rowcount


	       EXEC synUspAudit @AuditType='TRACE END', @ProcessStep='Prepare Audit Keys'
                        ,@Process=@ThisProc, @DatabaseName=@ThisDb, @Rows=@Rows, @PrintToScreen=@DebugPrint

*/

	
	-- End auditting
	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS END'
		,@Process=@ThisProc, @DatabaseName=@ThisDb,@SPID =@SPID, @PrintToScreen=1