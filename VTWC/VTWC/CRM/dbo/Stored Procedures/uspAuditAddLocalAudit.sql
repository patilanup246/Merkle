
/*============================================================================
Purpose:    dbo.uspAuditAddLocalAudit
Important:  Do not call this proc directly. Call this proc using the wrapper uspAuditAddAudit.
            ClientNumber and ClientName params are disabled in this DW implementation of the proc.
            They are kept so as to keep the signature of the proc the same as a version that can
            live in a central place (not DW).
            This allows the same CLR to be 
Created     2010-07-04 PhilipR 
Modified:   2010-12-08 PhilipR  Moved so Process Auditting now lives in DW. No need to identify client and other changes.
Modified:   2011-01-31 PhilipR  Adding code so TRACE START is correctly interpretted as TRACE PROCESS START
			2011-06-28 Colin T	Changed code to include @LoginUser (as this wasn't passed via CLR)
								Changed the way parentID was derived
								Changed to include a PE row in addition to closing the PS.
								
==================================================================================*/ 

CREATE PROCEDURE dbo.uspAuditAddLocalAudit
  -- Specify one of the following to try and identify the client .
  -- Or the first four chars of file name will be used in an attempt to find the client.
  @DatabaseName varchar(128) = NULL
  -- Params for the audit entries.
, @AuditType varchar(32) 
, @Server varchar(128) = NULL
, @SPID int = NULL
, @Process varchar(128)
, @ProcessStep varchar(128) = NULL
, @FileName varchar(128) = NULL
, @Message varchar(512) = NULL
, @CodeExecuted varchar(max) = NULL
, @Rows int = NULL
, @UserLogin sysname = NULL
-- Debug params
, @DebugPrint int = 0
, @DebugRecordSet int = 0
, @DebugDate datetime = NULL


AS
BEGIN
SET NOCOUNT ON;

-- Setting isolation level important to prevent different processes blocking each other.
-- Do not remove this with careful consideration.
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRY

  DECLARE @AuditTypeCode varchar(2)
        , @ParentLogID int
        , @Date datetime
        , @IsRemoteCall bit

  -- *****************************************************************
  -- SET DEFAULTS
  -- *****************************************************************  
  -- If we are passed a value in @Server then assume this is a remote call.
  -- Values @@SERVER and @@SPID should not be used.
  SET @IsRemoteCall = 0
  IF @Server <> @@SERVERNAME SET @IsRemoteCall = 1
  
  -- Set default params as nulls may be explicitly passed (especially aw remote CLR does not have optional params)
  SELECT @DebugPrint = COALESCE(@DebugPrint, 0)
       , @DebugRecordSet = COALESCE(@DebugRecordSet, 0)
  
  -- Null blanks (to keep logic flow consistent)
  SELECT @DatabaseName  = NULLIF(@DatabaseName , '')
       , @Server = NULLIF(@Server , '')
       , @ProcessStep = NULLIF(@ProcessStep , '')
       , @FileName = NULLIF(@FileName , '')
       , @Message = NULLIF(@Message , '')

  -- Set defaults
  SELECT @DatabaseName  = COALESCE(@DatabaseName, DB_NAME())
       , @Server = COALESCE(@Server , @@SERVERNAME)
       , @Date = COALESCE(@DebugDate, GETDATE())

  -- Find and validate this is a valid audit type.
  -- We allow either the (AuditTypeCode) code or the full name (AuditType) to be passed.
  ---------------------------------------------------------
  
  IF @AuditType='TRACE START' SET @AuditType = 'TRACE PROCESS START'
  IF @AuditType='TRACE END' SET @AuditType = 'TRACE PROCESS END'
  
  SELECT @AuditTypeCode = AuditTypeCode
  FROM dbo.LkupAuditType lk
  WHERE lk.AuditType = @AuditType
     OR lk.AuditTypeCode = @AuditType
  
  -- If still null, set to WARNING if values not found.
  -- Swap PC to PE. PC is a composite state when a process is completed - not an event that should be registered in its own right.
  SET @AuditTypeCode = REPLACE(@AuditTypeCode, 'PC', 'PE')
  SET @AuditTypeCode = REPLACE(@AuditTypeCode, 'TC', 'PE')
  SET @AuditTypeCode = COALESCE(@AuditTypeCode, 'U')
    
  -- Default SPID. Bear in mind when called remotely this will not be the SPID of the actual process.
  SELECT @SPID = CASE WHEN @IsRemoteCall = 0 THEN COALESCE(@SPID, @@SPID)
                      ELSE @SPID END

  -- Default UserLogin. Bear in mind when called remotely this will not be the SPID of the actual process.
  SELECT @UserLogin = COALESCE(@UserLogin, suser_sname())

 
  -- *****************************************************************
  -- RECORD THE AUDIT ENTRY
  -- *****************************************************************

  -- Find ParentID
  -- *****************************************************************
  -- Removed FileName as this will prevent first row with filename being added correctly 
  -- Removed SPID as new connection means child might be on different connection.
  SELECT TOP 1 @ParentLogID = AuditLogID
  FROM dbo.AuditLog a WITH (NOLOCK)
  JOIN dbo.LkupAuditType lk WITH (NOLOCK) ON lk.AuditTypeCode = a.AuditTypeCode
  WHERE 
    -- Only open processes can be parents
        a.AuditTypeCode = 'PS'
    AND a.AuditEndTime IS NULL
    -- Match server 
    AND (Server = @Server OR (Server IS NULL AND @Server IS NULL))
    -- Match On UserLogin
    AND (UserLogin=@UserLogin)
    -- Don't match to old open processes
    AND AuditStartTime > DATEADD(hour, -12, GETDATE())
  ORDER BY AuditStartTime DESC -- Ensure more recent record is used
  
  IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Tried to find @ParentLogID. Result= '+ISNULL(CONVERT(varchar,@ParentLogID),'(not found)')
  


  -- Add Audit entry (except for 'end process' types of events  @AuditTypeCode <> 'PC' )
  --****************************************************************
  --20110627 Removed PE as an exclusion here as having rows when processes end will be useful
  IF @AuditTypeCode NOT IN ('TE')
  BEGIN
    IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Starting Insert for standard Audit type.'
    -- Add the Audit row
    
    IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Length of @CodeExecuted = '+CONVERT(varchar,LEN(@CodeExecuted))
    INSERT dbo.AuditLog (
          ParentLogID
        , AuditTypeCode
        , Server
        , DatabaseName
        , Process
        , Step
        , FileName
        , Message
        , CodeExecuted
        , Rows
        , UserLogin
        , AuditStartTime
        )
          SELECT 
            @ParentLogID
          , @AuditTypeCode
          , @Server
          , @DatabaseName
          , @Process
          , @ProcessStep
          , @FileName
          , @Message
          , @CodeExecuted
          , @Rows
          , @UserLogin
		  , @Date          
		  
    IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Added new Audit row. '+CONVERT(varchar,@@ROWCOUNT)+' rows.'
  END


  -- Process End: close previous row
  --****************************************************************
  IF @AuditTypeCode IN ('PE', 'TE')
  BEGIN
      -- Process End: Find the matching start process.
      --   System, Client & Process must be the same.
      --   SubProcess & File must be the same is supplied.
      --   Audit Start must be within 24 hours.
      --   Audit entry must not be complete.
      
      DECLARE @AuditLogID int
        
      SELECT TOP 1 @AuditLogID = AuditLogID
      FROM dbo.AuditLog a WITH (NOLOCK)
      JOIN dbo.LkupAuditType lk WITH (NOLOCK)ON lk.AuditTypeCode = a.AuditTypeCode
      WHERE (Process = @Process)
        -- Only open processes can be closed (and only processes within last 24 hours are candidates)
        AND (a.AuditTypeCode = 'PS' AND @AuditTypeCode = 'PE'
             OR a.AuditTypeCode = 'TS' AND @AuditTypeCode = 'TE' )
        AND AuditStartTime > DATEADD(day, -1, @Date)
        AND AuditEndTime IS NULL
        -- Optional match elements (some entries will find parent using these, others won't)
        AND (Step = @ProcessStep OR Step IS NULL AND @ProcessStep IS NULL)
        AND (FileName = @FileName OR FileName IS NULL AND @FileName IS NULL)
        -- Match SPIDs. Removed because creating new connections puts end on a new spid.
        -- AND (SPID = @SPID OR SPID IS NULL AND @SPID IS NULL )
        -- Match server 
        AND (Server = @Server OR Server IS NULL AND @Server IS NULL )
      ORDER BY a.AuditStartTime DESC
             , a.AuditLogID desc 
      
      IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Process Close found start row at '+CONVERT(varchar,@AuditLogID)
    
      IF @AuditLogID IS NOT NULL
      BEGIN
        UPDATE dbo.AuditLog
        SET AuditEndTime = @Date
          , AuditTypeCode = CASE WHEN @AuditTypeCode = 'PE' THEN 'PC'
                                 WHEN @AuditTypeCode = 'TE' THEN 'TC'
                                 ELSE '??' END
          , Rows = COALESCE(NULLIF(Rows, 0), @Rows, Rows)
        WHERE AuditLogID = @AuditLogID
        
        IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Closed Audit Process entry. '+CONVERT(varchar,@@ROWCOUNT)+' rows.'
      END
      
      IF @AuditLogID IS NULL
      BEGIN
        -- Start row was not found.
        -- Rather than throwing this audit event away we add a new audit event of the process end type type.
        INSERT dbo.AuditLog (
              ParentLogID
            , AuditTypeCode
            , Server
            , DatabaseName
            , Process
            , Step
            , FileName
            , Message
            , CodeExecuted
            , Rows
            , UserLogin
            , AuditStartTime
            )
              SELECT 
               -- Do a last minute lookup just in case client key reversed.
                @ParentLogID
              , @AuditTypeCode
              , @Server
              , @DatabaseName
              , @Process
              , @ProcessStep
              , @FileName
              , @Message
              , @CodeExecuted
              , @Rows
              , @UserLogin
              , @Date
              
           IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' [TRACE] PROCESS END Event has no corresponding process start. '+CONVERT(varchar,@@ROWCOUNT)+' rows.'
           -- TODO: Add a WARNING event.
      END    
      
  END -- END @AuditTypeCode='PE'

  IF @DebugRecordSet=1
    SELECT 'Variables:' AS [RESULTS]
        , @AuditLogID AS [@AuditLogID]
        , @AuditType  AS [@AuditType]
        , @AuditTypeCode AS [@AuditTypeCode]
        , @CodeExecuted AS [@CodeExecuted]
        , @DatabaseName AS [@DatabaseName]
        , @FileName AS [@FileName]
        , @IsRemoteCall AS [@IsRemoteCall]
        , @Message AS [@Message]
        , @ParentLogID AS [@ParentLogID]
        , @Process AS [@Process]
        , @Rows AS [@Rows]
        , @Server AS [@Server]
        , @SPID AS [@SPID]
        , @ProcessStep AS [@ProcessStep]
		, @UserLogin AS [@UserLogin]


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

  RAISERROR('Error occurred writing AuditRow. %s',10,1, @ErrMessage)
  --PRINT CONVERT(varchar(19), getdate(),121)+' Error occurred writing AuditRow.'

END CATCH


END