
/*===========================================================================================
Name:			    uspSSISPrepareEnvironment
Purpose:		  Truncates DbgMatch and staging tables. Removes index on dbo.StagingAttributeValue.
Parameters:		@FeedFileKey - The key for the feed being processed.
              @FileSpecificationKey - The Key for the specification being processed.
				      @DebugPrint - Displays debug information to the message pane.
				      @DebugRecordSet - When implmented, used to control displaying debug recordset information
				                        to screen, or storing debug recordsets to global temp tables.
				
Notes:			 
			
Created:		2011-09-07	Steve Blackman
Modified:		2011-09-08	Steve Blackman	Added truncating StagingAttributes
				2011-11-22	Ryan Brownley	Added wrapper for StagingCustomer table
				2012-01-19  George Hudd. Added truncate statement for StagingEmail
				2013-03-22  Colin Thoams. Added rule to update DestinationDataType on MetadataColumnSpecification table (and add it if it doesn't exist)
				2013-04-17  Colin Thoams. Fixed bug for nvarchar destination datatypes
				2014-01-09  Colin Thomas. Fixed bug for numeric destination datatypes
				2014-01-13  Colin Thomas. Added process to kill other SPIDs
				2014-02-10  Colin Thomas. Disabled SPID kill for generic template
Peer Review:	
Call script:	EXEC uspSSISPrepareEnvironment
=================================================================================================*/
CREATE PROCEDURE dbo.uspSSISPrepareEnvironment
			    @FeedFileKey int,
			    @FileSpecificationKey int,
				  @DebugPrint tinyint = 0,
				  @DebugRecordSet tinyint = 0
				
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Standard declarations and variable setting.
---------------------------------------------------------
DECLARE @ThisDb sysname = DB_NAME()
      , @Rows int
      , @ThisProc sysname = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNOWN')
      , @FileName varchar(127)
      , @SPID int = @@SPID
      , @updates varchar(max)
      ,	@cr char(1) = CHAR(10)

SELECT TOP 1 @FileName = OriginalFileName
FROM dbo.AuditFeedFile
WHERE FeedFileKey = @FeedFileKey

EXEC synUspAudit @AuditType='PROCESS START'
               , @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint

BEGIN TRY
  --***************************************************
	-- START CUSTOM PROCESS
  --***************************************************
  
  ----------------------------------------------------
  -- Kill all other SPIDs
  ----------------------------------------------------
  -- 20140113 Colin Thomas - added to prevent long running queries delaying the load

  /* To enable, copy this proc to client proc folder

  EXEC synUspAudit @AuditType='TRACE START', @ProcessStep = 'Kill all other SPIDs', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint

  --Get list of SPIDs to kill
  SELECT spid, loginame, CAST(0 as bit) processed
	INTO #spids
	FROM master..sysprocesses P
	INNER JOIN master..sysdatabases D
	ON D.dbid = P.dbid  
	WHERE loginame NOT LIKE 'STELLA\CLT%_Proxy' -- Best to update this with the Proxy account
	AND spid <> @@spid
	AND D.[name]='VWGDW'  -- Remove this if queries could start in a different Database (e.g. Unica)

  --Kill Spids
  DECLARE @spidtokill int, @sql varchar(50)
  WHILE EXISTS (SELECT * FROM #spids WHERE processed=0)
  BEGIN
	SELECT TOP 1 @sql='KILL '+CAST(spid as varchar(10)) + ' -- '+loginame, @spidtokill=spid FROM #spids WHERE processed=0

	EXEC (@sql)

	UPDATE #spids SET processed=1 WHERE spid=@spidtokill
  END

  SELECT @Rows=COUNT(*) FROM #spids

  EXEC synUspAudit @AuditType='TRACE END', @ProcessStep = 'Kill all other SPIDs', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=@Rows, @PrintToScreen=@DebugPrint
  */

  ----------------------------------------------------
  -- Truncate DbgMatch and Staging tables
  ----------------------------------------------------
  EXEC synUspAudit @AuditType='TRACE START', @ProcessStep = 'Truncate Staging Tables', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint
    
  IF EXISTS(SELECT 1 FROM SYS.OBJECTS  WHERE name = 'DbGMatch')
	BEGIN  
    TRUNCATE TABLE dbo.DbGMatch
    END
    
  IF EXISTS(SELECT 1 FROM SYS.OBJECTS  WHERE name = 'StagingCustomer')
    BEGIN
    TRUNCATE TABLE dbo.StagingCustomer
    END
  
  IF EXISTS(SELECT 1 FROM SYS.OBJECTS  WHERE name = 'StagingEmail')
    BEGIN
    TRUNCATE TABLE dbo.StagingEmail
    END
   
    TRUNCATE TABLE dbo.StagingAttributeValue
    TRUNCATE TABLE dbo.StagingAttributes
    TRUNCATE TABLE dbo.StagingAuditResults
	TRUNCATE TABLE dbo.StagingAttributeKeys
	TRUNCATE TABLE dbo.StagingAttributeList
	TRUNCATE TABLE dbo.StagingAttributeRowValues
    
  EXEC synUspAudit @AuditType='TRACE END', @ProcessStep = 'Truncate Staging Tables', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint
  
  ----------------------------------------------------
  -- Remove indexes on StagingAttributeValue
  ----------------------------------------------------
  EXEC synUspAudit @AuditType='TRACE START', @ProcessStep = 'Disable StagingAttributeValue Indexes', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint  
  EXEC dbo.uspUtilityDisableEnableNonClusteredIndexes @TABLE_NAME='dbo.StagingAttributeValue', @Action='DISABLE', @DebugPrint = 0, @DebugRecordset = 0
  SET @Rows = @@ROWCOUNT
  EXEC synUspAudit @AuditType='TRACE END', @ProcessStep = 'Disable StagingAttributeValue Indexes', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=@Rows,@PrintToScreen=@DebugPrint
  
  ----------------------------------------------------
  -- Update DestinationDataType on MetadataColumnSpecification table
  ----------------------------------------------------

  --Add column if required
  -------------------------------------
  --This will support older deployments
  IF NOT EXISTS (SELECT * FROM sys.columns where name='DestinationDataType' and OBJECT_NAME(OBJECT_ID)='MetadataColumnSpecification')
  BEGIN
	EXEC synUspAudit @AuditType='TRACE START', @ProcessStep = 'Add DestinationDataType column to MetadataColumnSpecification table', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint  
	ALTER TABLE MetadataColumnSpecification	ADD DestinationDatatype varchar(50)
	EXEC synUspAudit @AuditType='TRACE END', @ProcessStep = 'Add DestinationDataType column to MetadataColumnSpecification table', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint  
  END

    --Update 
  -------------------------------------
  EXEC synUspAudit @AuditType='TRACE START', @ProcessStep = 'Update DestinationDatatypes on MetadataColumnSpecification table', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint  
  
  UPDATE cs
	SET DestinationDatatype=
		t.name
		+ CASE WHEN t.name in ('varchar', 'char', 'nvarchar', 'nchar') THEN
				COALESCE('(' + CASE
									WHEN t.name = 'XML' THEN NULL
									WHEN Cast(c.max_length AS VARCHAR(5)) = -1 THEN 'max'
									ELSE CASE WHEN t.name IN ('nvarchar', 'nchar')
											  THEN Cast(c.max_length/2 AS VARCHAR(5))
											  ELSE Cast(c.max_length AS VARCHAR(5))
											  END
							   END + ')'
						, '') 
			WHEN t.name in ('float', 'decimal', 'real', 'numeric') -- separated these data types as it was not working correctly
			 THEN '(' + Cast(c.precision AS NVARCHAR(5)) + ',' + Cast(c.scale AS NVARCHAR(5)) + ')'
			ELSE ''
		END
	FROM MetadataColumnSpecification cs
	INNER JOIN sys.columns c ON (OBJECT_NAME(c.OBJECT_ID)=cs.LookupKeyFromTable AND c.name=cs.LookupMatchOnDestinationColumn
								OR OBJECT_NAME(c.OBJECT_ID)=cs.Destination AND c.name=cs.DestinationColumn)
	INNER JOIN sys.types t ON t.user_type_id = c.user_type_id

	EXEC synUspAudit @AuditType='TRACE END', @ProcessStep = 'Update DestinationDatatypes on MetadataColumnSpecification table', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=@@ROWCOUNT,@PrintToScreen=@DebugPrint  

  --***************************************************
	-- END OF PROCESSING
  --***************************************************
EXEC synUspAudit @AuditType='PROCESS COMPLETE'
               , @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint

END TRY
BEGIN CATCH
	DECLARE 
		@ErrorMessage VARCHAR(4000),
		@ErrorNumber INT,
		@ErrorSeverity INT,
		@ErrorState INT,
		@ErrorLine INT,
		@ErrorProcedure VARCHAR(126)
		;

	SELECT 
		@ErrorNumber = ERROR_NUMBER(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE(),
		@ErrorLine = ERROR_LINE(),
		@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), 'N/A'),
		@ErrorMessage=ERROR_MESSAGE()
		;

    -- Log
    EXEC synUspAudit @AuditType='ERROR'
                   , @Message=@ErrorMessage
                   , @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint
    
	--Rethrow the error
	RAISERROR                                    
	(   @ErrorMessage,
		@ErrorSeverity,
		1 
	);    
END CATCH