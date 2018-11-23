
/*============================================================================
Purpose:    dbo.uspAuditAddAudit
Notes:      Wrapper code for adding an audit event.
            If connection has any open transactions the code will execute a proc call
            that will make the connection remotely so as not to bring the audit table into the transaction.
            This is to avoid the risk of clients deadlocking each other.
Created:    PhilipR 2010-09-27
Modified:   PhilipR 2010-10-14 Adding @PrintToScreen for when we want the log to first be written to the screen.
Modified:   PhilipR 2010-12-08 Audit procs will now live in local DW therefore @ClientName and @ClientNumber parsms obsolete.
                    These two params will still be available in the Local and Remote(clr) version of the proc so they can support
                    a non-local implementation if required in the future.
Modified:   PhilipR 2010-12-08 Moved so Process Auditting now lives in DW. No need to identify client and other changes.
Modified:   PhilipR 2010-12-13 Bug. Server was being populated by DatabaseName.  
Modified:   PhilipR 2011-05-25 Increasing len of Process when written to screen.
Modified:   Colin Thomas 2011-06-28 Adding @UserLogin which is passed ot remote and local auditing.
Modified:   PhilipR 2011-11-01 Adding TRY CATCH because failure to log should not itself raise error.
                               You do get occasional times when remote logging proc raises an error on busy server when it fails to get connection.
Modified:   PhilipR Robinson 2012-11-03 Added SET XACT_ABORT OFF because logging should not fail main Tx and anyway, remote logging via the via the CLR cannot
                             be incorporated in Tx.
Modified:   Philip Robinson. 2012-12-03 Re-adding call to raiseerror to better track errors.
==================================================================================*/ 

CREATE PROCEDURE [dbo].[uspAuditAddAudit]
  -- SIGNATURE FOR THIS PROC MATCHES THE PROC THAT ACTUALLY ADDS THE AUDIT ENTRIES.
  -- See uspAddAudit for details of what the params mean.
  
  @DatabaseName varchar(128) = NULL
, @AuditType varchar(32) 
, @Server varchar(128) = NULL
, @SPID int = NULL
, @Process varchar(255)
, @ProcessStep varchar(255) = NULL
, @FileName varchar(512) = NULL
, @Message varchar(512) = NULL
, @CodeExecuted varchar(max) = NULL
, @Rows int = NULL
, @PrintToScreen bit = 0
-- These params are for debugging the auditting procs.
-- Use @PrintToScreen to get the audit events themselves printed.
, @DebugPrint int = 0
, @DebugRecordSet int = 0
, @DebugDate datetime = NULL


AS
BEGIN

SET XACT_ABORT OFF;    -- Required OFF.
SET NOCOUNT ON;
BEGIN TRY

  IF @PrintToScreen=1
  BEGIN
     DECLARE @Msg varchar(8000)
     SET @Msg = CONVERT(varchar(19), getdate(),121)+' --------------------------------------------'+CHAR(13)+CHAR(10)
               +'Audit Type:   '+@AuditType+'    '
               +'Process: '+ISNULL(@Process,'Unspecified')+'    '
               +CASE WHEN LEN(@ProcessStep)>0 THEN 'Step: '+@ProcessStep+'    ' ELSE '' END 
               +CASE WHEN LEN(@Rows)>0 THEN 'Rows: '+CONVERT(varchar,@Rows)+'    ' ELSE '' END 
               +CHAR(13)+CHAR(10)
               +CASE WHEN LEN(@FileName)>0 THEN 'File Name: '+@FileName+CHAR(13)+CHAR(10) ELSE '' END 
               +CASE WHEN LEN(@Message)>0 THEN 'Message:      '+@Message+CHAR(13)+CHAR(10) ELSE '' END 
               +CASE WHEN LEN(@CodeExecuted)>0 THEN 'Code:         '+CHAR(13)+CHAR(10)+@CodeExecuted ELSE '' END
               +CHAR(13)+CHAR(10) 
               --+'----------------------------------------------------------------'
  
    PRINT @Msg
  END

  -- Defaults.
  ---------------------------------------------------------
  DECLARE @UserLogin sysname = suser_sname()
  SELECT @DatabaseName = COALESCE(@DatabaseName, DB_NAME())
       , @Server = COALESCE(@Server, @@SERVERNAME)
  


  IF @@TRANCOUNT = 0
  BEGIN
    IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' No open transactions. Calling local version of uspAddAudit.'
    EXEC dbo.uspAuditAddLocalAudit
          @DatabaseName  = @DatabaseName
        , @AuditType = @AuditType
        , @Server = @Server
        , @SPID = @SPID
        , @Process = @Process
        , @ProcessStep = @ProcessStep
        , @FileName = @FileName
        , @Message = @Message
        , @CodeExecuted = @CodeExecuted
        , @Rows = @Rows
        , @UserLogin = @UserLogin
        , @DebugPrint = @DebugPrint
        , @DebugRecordSet = @DebugRecordSet
        , @DebugDate = @DebugDate
  END

  IF @@TRANCOUNT > 0
  BEGIN
    IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Open transactions. Calling remote version of uspAddAudit.'
    DECLARE @LoggingServer sysname
          , @LoggingDatabase sysname
    
    SELECT @LoggingServer = @@SERVERNAME
         , @LoggingDatabase = DB_NAME()
   
    --EXEC [dbo].[clrAuditAddRemoteAudit]
	   --    @LoggingServer = @LoggingServer
    --   , @LoggingDatabase = @LoggingDatabase
    --   , @DatabaseName  = @DatabaseName
    --   , @AuditType  = @AuditType
    --   , @Server = @Server
    --   , @SPID = @SPID
    --   , @Process = @Process
    --   , @ProcessStep = @ProcessStep
    --   , @FileName  = @FileName
    --   , @Message  = @Message
    --   , @CodeExecuted  = @CodeExecuted
    --   , @Rows = @Rows
    --   , @UserLogin = @UserLogin
    --   , @DebugPrint = @DebugPrint
    --   , @DebugRecordSet = @DebugRecordSet
    --   , @DebugDate = @DebugDate
       

  END


END TRY
BEGIN CATCH
  DECLARE @ErrMessage varchar(512)
        , @ErrNumber int
        , @ErrState int
        , @ObjName sysname

  SELECT @ObjName = COALESCE(OBJECT_NAME(@@PROCID),'Non Proc') 
       , @ErrMessage = ERROR_MESSAGE()
       , @ErrNumber = CASE WHEN ERROR_NUMBER() <= 16 THEN ERROR_NUMBER() ELSE 16 END
       , @ErrState = ERROR_STATE()
  
  -- Never throw a severe message as we do not want logging to bring down other processes.
  DECLARE @Proc sysname = OBJECT_NAME(@@PROCID)
  RAISERROR('Error occurred writing AuditRow (%s). %s',10,1, @Proc, @ErrMessage)
  
END CATCH
END