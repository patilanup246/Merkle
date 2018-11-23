
/*===========================================================================================
Name:			uspSSISPostLoadWrapper
Purpose:		Inserts an inferred Customer dimension member.
Parameters:		None
Notes:			    

-- Client specific implementation
Created:	2018-07-25	Neil Butler. Initial Stub Creation.
	
Modified:	

Call script:	EXEC uspSSISPostLoadWrapper ?
=================================================================================================*/
CREATE PROCEDURE dbo.uspSSISPostLoadWrapper
				 @PkgExecKey INT = -1
				,@DebugPrint int = 0
				,@DebugRecordset int = 0
AS

	DECLARE @ThisDb sysname = DB_NAME()
		   ,@ThisProc sysname = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
		   ,@SPID int = @@SPID

	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@ThisProc, @DatabaseName=@ThisDb,@SPID =@SPID, @PrintToScreen=1

	DECLARE @ProcName AS VARCHAR(50)
	DECLARE @StepName AS VARCHAR(50)
	DECLARE @ErrorNum AS INT
	DECLARE @ErrorMsg AS VARCHAR(2048)
	DECLARE @dbName VARCHAR(30) ; SET @dbName=DB_NAME()

	DECLARE
		@StartDate		DATE,
		@EndDate		DATE

	SET @StartDate = GETDATE()-1
	SET @EndDate = GETDATE()
	
	SET @ProcName = 'uspSSISPostLoadWrapper'

	BEGIN TRY
		SET @StepName = 'uspSourceFileCheck'
		EXEC dbo.uspSSISProcStepStart @ProcName, @StepName

		EXEC dbo.uspSourceFileCheck
			@StartDate = @StartDate,
			@EndDate = @EndDate,
			@PkgExecKey = @PkgExecKey,
			@DebugPrint = @DebugPrint,
			@DebugRecordSet = @DebugRecordSet

		EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;
	RAISERROR('',10,1) WITH NOWAIT	

	/*===============================================================================================
	-- example of proc call
	=================================================================================================

	-- Updates Fact Tables with the Results of Customer Merging
    -----------------------------------------------------
        BEGIN TRY
                SET @StepName = 'uspSSISClientSpecificPostLoadCustomerMerge'
                EXEC dbo.uspSSISProcStepStart @ProcName, @StepName
                EXEC dbo.uspSSISClientSpecificPostLoadCustomerMerge @DebugPrint = @DebugPrint,@DebugRecordSet = @DebugRecordSet
                EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
                SET @ErrorNum = ERROR_NUMBER()
                SET @ErrorMsg = ERROR_MESSAGE()
                EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
        END CATCH ;
        RAISERROR('',10,1) WITH NOWAIT
       
		-- Populates Customerkey With "Lead Customer" From FactCustomerTicket
	-----------------------------------------------------

	*/


	-- End auditing
	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS END'
		,@Process=@ThisProc, @DatabaseName=@ThisDb,@SPID =@SPID, @PrintToScreen=1


	-- If any errors. Re-throw so error bubbles up to initiate a call to action.
	---------------------------------------------------------
	IF @ErrorNum>0
	RAISERROR('One or more errors occurred during post load process. Check AuditErrorLog for full details. The last error was: %s',16,1,@ErrorMsg)