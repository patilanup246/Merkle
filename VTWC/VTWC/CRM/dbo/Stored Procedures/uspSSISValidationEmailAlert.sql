
/*===========================================================================================
Purpose:		dbo.uspSSISValidationEmailAlert
Notes:			Procedure to send notifications of record validation failures.
            The proc is based on the PkgExecKey.
Created			2010-11-23 Philip Robinson 
Modified    2010-12-01 Philip Robinson [W] events now give full description.
Modified:   2011-02-17 Re-enabling code to dynamically find profiles are all enviroments are inconsistent.
Modified:   2011-08-09 Philip Robinson. Modification so description of event is taken from Description.
Modified:   2012-04-23 Philip Robinson. Modification so File Reject gives reason.
=================================================================================================*/

CREATE PROCEDURE dbo.uspSSISValidationEmailAlert 
  @PkgExecKey int
, @PcvSMTPExternalMailTo varchar(4000) = NULL
, @PcvSMTPExternalMailCc varchar(4000) = NULL
, @PcvSMTPInternalMailTo varchar(4000) = NULL
, @PcvSMTPInternalMailCc varchar(4000) = NULL
, @PcvSMTPMailFrom varchar(4000)= NULL
, @DebugPrint int = 0
, @DebugRecordset int = 0

-- Might need to try impersonation to get the proc working and able to send query results.
-- WITH EXECUTE AS 'Production'

AS

-- Ue this to maintain complete consistency and reduce deadlocks
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON

-- Standard declarations and variable setting.
---------------------------------------------------------
DECLARE @ThisDb sysname = DB_NAME()
      , @Rows int
      , @ThisProc sysname = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
      , @SPID int = @@SPID

DECLARE @ValidationMsg varchar(max) = ''
      , @ValidationFileCount int = 0
      , @tmp varchar(1000)
      , @CR  varchar(1) = CHAR(13)+CHAR(10)
      , @OffsetLen int = 6


-- Set defaults
SELECT @PcvSMTPMailFrom = COALESCE(@PcvSMTPMailFrom, 'ssis@dbg.co.uk')

BEGIN TRY

-- The following sets up default behaviour for this proc.
-- To override the behaviour - setup up the required dbgConfigurationParameters.
---------------------------------------------------------
DECLARE @ValidationEmailAlertTypes varchar(30)

SET @ValidationEmailAlertTypes = 'FREBUTWX'       -- X=Unknown

IF EXISTS(SELECT * 
          FROM dbo.dbgConfigurationParameters
          WHERE Parameter = 'ValidationEmailAlertTypes'
            AND IsActive=1)
  SELECT @ValidationEmailAlertTypes = Value
  FROM dbo.dbgConfigurationParameters
  WHERE Parameter = 'ValidationEmailAlertTypes'
    AND IsActive=1

SET @tmp = 'Sending Validation Email Alerts for types '+ISNULL(@ValidationEmailAlertTypes,'<blank>')
EXEC synUspAudit
    @AuditType='TRACE'
  , @Message = @tmp
  , @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=NULL, @Rows=NULL,@PrintToScreen=@DebugPrint



---------------------------------------------------------
-- PART 1: Build the email message.
---------------------------------------------------------

-- Loop and build summary string
/* -- Summary message in for the form

TEDB_AAA_BBB_CCC_DDD_V00001_20101121.csv
  File was rejected in its entirity [F].
  3   Whole source records rows were rejected [R]
  2   Partial record rejects (entity rejects) [E]
  123 Fields blanked [B].
*/

-- Variables to help build the emal message.

-- Variables to collect cursor values.
DECLARE @OriginalFileName varchar(128), @PrevOriginalFileName varchar(128)
      , @FeedFileKey int
      , @ValidationAction char(1)
      , @ValidationActionText varchar(2000)
      , @RecordCount int

SELECT TOP 200 f.FeedFileKey
     , COALESCE(OriginalFileName, ProcessedFileName, '[Unknown. FeedFileKey '+CONVERT(varchar,f.FeedFileKey)+']') AS OriginalFileName
     , UPPER(ISNULL(ValidationAction,'X')) AS ValidationAction
     , CASE WHEN ValidationAction='F' THEN '' ELSE '[[RECORDCOUNT]] ' END
       +'['+UPPER(ISNULL(ValidationAction,'X'))+'] '
       +CASE ValidationAction            
            WHEN 'B' THEN 'Field blanked: '+COALESCE(SourceColumnName, Description, '')
            WHEN 'F' THEN 'File was rejected in its entirety. Description: '+ISNULL(Description,'(unspecified)')
            WHEN 'R' THEN COALESCE('['+SourceColumnName+']: ','')+COALESCE(Description,'')
            WHEN 'E' THEN COALESCE('['+SourceColumnName+']: ','')+COALESCE(Description,'')
            WHEN 'W' THEN 'Warning: '+ISNULL(Description,'(unspecified)')
            WHEN 'T' THEN 'Truncation: '+COALESCE(SourceColumnName, Description, '')
            WHEN 'U' THEN 'Value was updated: '+COALESCE(SourceColumnName, Description, '')
            ELSE 'Unknown Validation type' 
        END AS ValidationActionText
     , COUNT(*) AS RecordCount
INTO #ValidationSummary
FROM dbo.AuditFeedFile f
JOIN dbo.AuditErrorLog ON f.FeedFileKey = AuditErrorLog.FeedFileKey
WHERE f.PkgExecKey = @PkgExecKey
  AND @PkgExecKey > 0
  AND (ISNULL(ValidationAction,'X') LIKE '['+@ValidationEmailAlertTypes+']'
       OR 'X' LIKE '['+@ValidationEmailAlertTypes+']' AND ISNULL(ValidationAction,'') NOT IN ('B','E','R','F','U','W','T') )
GROUP BY f.FeedFileKey
     , COALESCE(OriginalFileName, ProcessedFileName, '[Unknown. FeedFileKey '+CONVERT(varchar,f.FeedFileKey)+']')
     , UPPER(ISNULL(ValidationAction,'X'))
     , CASE WHEN ValidationAction='F' THEN '' ELSE '[[RECORDCOUNT]] ' END
       +'['+UPPER(ISNULL(ValidationAction,'X'))+'] '
       +CASE ValidationAction            
            WHEN 'B' THEN 'Field blanked: '+COALESCE(SourceColumnName, Description, '')
            WHEN 'F' THEN 'File was rejected in its entirety. Description: '+ISNULL(Description,'(unspecified)')
            WHEN 'R' THEN COALESCE('['+SourceColumnName+']: ','')+COALESCE(Description,'')
            WHEN 'E' THEN COALESCE('['+SourceColumnName+']: ','')+COALESCE(Description,'')
            WHEN 'W' THEN 'Warning: '+ISNULL(Description,'(unspecified)')
            WHEN 'T' THEN 'Truncation: '+COALESCE(SourceColumnName, Description, '')
            WHEN 'U' THEN 'Value was updated: '+COALESCE(SourceColumnName, Description, '')
            ELSE 'Unknown Validation type' 
        END
HAVING COUNT(*)>0
ORDER BY OriginalFileName  -- ordering is important for gerating msg correctly
       , CASE UPPER(ISNULL(ValidationAction,'X')) WHEN 'F' THEN 10
                                           WHEN 'R' THEN 20
                                           WHEN 'E' THEN 30
                                           WHEN 'B' THEN 40
                                           WHEN 'T' THEN 50
                                           WHEN 'U' THEN 55
                                           WHEN 'W' THEN 60
                                           ELSE 99 END

IF @DebugRecordset>0
  SELECT '#ValidationSummary' AS [#ValidationSummary], * FROM #ValidationSummary


DECLARE cFiles CURSOR FOR
	SELECT FeedFileKey
	     , OriginalFileName
	     , ValidationAction
	     , ValidationActionText
	     , RecordCount
	FROM #ValidationSummary
	
OPEN cFiles
FETCH NEXT FROM cFiles INTO @FeedFileKey, @OriginalFileName, @ValidationAction, @ValidationActionText, @RecordCount
WHILE @@FETCH_STATUS=0 BEGIN

  -- Add file name to header of this msg block.
  IF ISNULL(@PrevOriginalFileName,'') <> @OriginalFileName
  BEGIN
      SET @ValidationMsg += @CR +@CR +@OriginalFileName +@CR
      SET @ValidationFileCount += 1
  END

  -- Format record count and place into ValidationActionText
  SET @tmp = LEFT(CONVERT(varchar, @RecordCount) + REPLICATE(' ',@OffsetLen), @OffsetLen)
  SET @ValidationActionText = REPLACE(@ValidationActionText, '[[RECORDCOUNT]]', @tmp)
      
  -- Add validation string
  SET @ValidationMsg += REPLICATE(' ',@OffsetLen)+@ValidationActionText+@CR
  
  SET @PrevOriginalFileName = @OriginalFileName
  
	FETCH NEXT FROM cFiles INTO @FeedFileKey, @OriginalFileName, @ValidationAction, @ValidationActionText, @RecordCount
END
CLOSE cFiles
DEALLOCATE cFiles



-- If no validations to report: exit
---------------------------------------------------------
IF @ValidationFileCount=0
BEGIN
  --EXEC synUspAudit
  --  @AuditType='PPROCESS COMPLETE'
  --, @Message = 'No validations to report'
  --, @Process=@ThisProc, @DatabaseName=@ThisDb, @Rows=NULL,@PrintToScreen=@DebugPrint

  RETURN 0;
END



-- PART 2: Sent the email
---------------------------------------------------------
DECLARE @ProfileName varchar(128)
      , @RecipientsTo varchar(8000)
      , @RecipientsCc varchar(8000)
      , @Subject varchar(127)
      , @Body varchar(max)
      , @QueryString varchar(8000)

-- Get profile dynamically. This gives more fault tollerance than hard-coding the profile name.
-- Use order to try and find the most suitable profile (similar to client name, contains Production, contains DBA, anything else)

SELECT TOP 1 @ProfileName = name
FROM msdb.dbo.sysmail_profile
ORDER BY CASE WHEN REPLACE(REPLACE(name,'DW',''),' ','') LIKE '%'+REPLACE(REPLACE(@ThisDb,'DW',''),' ','')+'%' THEN 10 
              WHEN Name LIKE '%Production%' THEN 20
              WHEN Name LIKE '%DBA%' THEN 30
              ELSE 99 END
--SET @ProfileName = 'DBGSQLService Profile'


-- Build Subject.
SELECT TOP 1 @tmp = 'Pkg:"'+ISNULL(ap.PkgName, 'Unknown')+'", Srv:"'+@@SERVERNAME +'"'
FROM dbo.AuditPkgExecution ap
WHERE PkgExecKey = @PkgExecKey

SET @Subject = 'Validation errors occurred in '+CONVERT(varchar, @ValidationFileCount)+' files.['+@tmp+']'

-- Build recipients.
SET @RecipientsTo = ISNULL(@PcvSMTPExternalMailTo,'')
                  + CASE WHEN LEN(@PcvSMTPExternalMailTo)>0 AND LEN(@PcvSMTPInternalMailTo)>0 THEN ';' ELSE '' END
                  + ISNULL(@PcvSMTPInternalMailTo,'')
                  
SET @RecipientsCc = ISNULL(@PcvSMTPExternalMailCc,'')
                  + CASE WHEN LEN(@PcvSMTPExternalMailCc)>0 AND LEN(@PcvSMTPInternalMailCc)>0 THEN ';' ELSE '' END
                  + ISNULL(@PcvSMTPInternalMailcc,'')

-- Build Body.
SET @Body = @Subject+@CR
          + @ValidationMsg+@CR+@CR
          + 'For more information please review the load report.'+@CR
          + '---------------------------------------------------'+@CR
          + 'This is an automated message generated, please do not respond.'+@CR
          + 'The contents of this email and the type of events causing an alert can be configured.'+@CR
          + 'Source: '+@@SERVERNAME+'.'+@ThisDb+'.'+@ThisProc


-- Build query string.
-- This is similar to the query used above but also breaks down by TargetTable and SourceColumnName.
SET @QueryString= '
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT f.FeedFileKey
     , COALESCE(OriginalFileName, ProcessedFileName, ''[Unknown. FeedFileKey ''+CONVERT(varchar,f.FeedFileKey)+'']'') AS OriginalFileName
     , ISNULL(ValidationAction,''X'') AS ValidationAction
     , TargetTable
     , SourceColumnName
     , COUNT(*) AS RecordCount
FROM dbo.AuditFeedFile f
JOIN dbo.AuditErrorLog ON f.FeedFileKey = AuditErrorLog.FeedFileKey
WHERE f.PkgExecKey = '+CONVERT(varchar, @PkgExecKey)+'
GROUP BY f.FeedFileKey
     , COALESCE(OriginalFileName, ProcessedFileName, ''[Unknown. FeedFileKey ''+CONVERT(varchar,f.FeedFileKey)+'']'')
     , ISNULL(ValidationAction,''X'')
     , TargetTable
     , SourceColumnName
HAVING COUNT(*)>0
ORDER BY OriginalFileName  -- ordering is important for gerating msg correctly
       , CASE ISNULL(ValidationAction,''X'') WHEN ''F'' THEN 10
                                             WHEN ''R'' THEN 20
                                             WHEN ''E'' THEN 30
                                             WHEN ''B'' THEN 40
                                             WHEN ''T'' THEN 50
                                             WHEN ''U'' THEN 55
                                             WHEN ''W'' THEN 60
                                             ELSE 99 END
'


--EXEC synUspAudit
--    @AuditType='TRACE', @ProcessStep='Sending email'
--  , @Message = 'Body contents of the email stored in CodeExecuted.'
--  , @CodeExecuted = @Body
--  , @Process=@ThisProc, @DatabaseName=@ThisDb, @Rows=@ValidationFileCount,@PrintToScreen=@DebugPrint


IF @DebugRecordset>0
  SELECT 'Parameters used by dbmail' AS DebugReason
       , @ProfileName AS [@ProfileName]
       , @RecipientsTo AS [@RecipientsTo]
       , @RecipientsCc AS [@RecipientsCc]
       , @Subject AS [@Subject]
       , @Body AS [@Body]
       , @QueryString AS [@QueryString]
       , @ThisDb AS [@ThisDb]

IF @DebugRecordset>0
  EXEC (@QueryString)


-- CURRENTLY WE CANNOT INCLUDE QUERY DUE TO PERMISSIONS ISSUE.


EXEC [msdb].[dbo].[sp_send_dbmail] @profile_name = @ProfileName 
						   , @recipients = @RecipientsTo
						   , @copy_recipients = @RecipientsCc
						   , @subject = @Subject
						   , @body = @Body
						   , @importance ='Normal'
						   , @body_format = 'TEXT'
						   --, @query = @QueryString
						   --, @attach_query_result_as_file = 1
						   --, @execute_query_database = @ThisDb
						   --, @query_attachment_filename = 'Error Log Summary.csv'
						   --, @query_result_separator = ','

--EXEC synUspAudit
--    @AuditType='PPROCESS COMPLETE'
--  , @Process=@ThisProc, @DatabaseName=@ThisDb, @Rows=NULL,@PrintToScreen=@DebugPrint


---------------------------------------------------------
END TRY BEGIN CATCH
    
  -- Audit declarations
  DECLARE @ErrNo INT, @ErrMsg VARCHAR(400)
  SET @ErrMsg = ERROR_MESSAGE()
  
  EXEC synUspAudit
      @AuditType = 'ERROR'
    , @Process = @ThisProc
    , @DatabaseName = @ThisDb
    , @Message = @ErrMsg
    , @CodeExecuted = @Body
  

  RAISERROR (@ErrMsg, 16, 1)

END CATCH