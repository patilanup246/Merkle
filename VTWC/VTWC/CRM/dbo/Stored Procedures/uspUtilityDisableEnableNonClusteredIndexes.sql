
/*============================================================================ 
Name:       uspUtilityDisableEnableNonClusteredIndexes
Purpose:    Disab les or rebuilds indexes. Useful for large file loads on heavily indexed tables.
Parms:		@ThisDb Database name
			    @TABLE_NAME table name including schema e.g. dbo.FactEmailresponse
			    @Action DISABLE = Disable, ENABLE = Rebuild

Created:   2009-12-17 KenS
Modified:  2010-01-19 PhilipR Adding datetime to print statements to help identify performance issues
           20100122 KJS Modified to remove 'Blurp' printing and standardised the date output.
           2011-01-23 Added @ExcludeList and @IncludeList optional params. 
                      This adds a dependancy to fnSplitString function.
                      Changed to use #table due to danger of ## table being used.
           2011-09-07 Steve Blackman @DB_NAME not passed in as parameter. Now set using DB_NAME(). 
                      Added auditing and standard proc error handling.
           2012-01-17 George Hudd. Added @DB_NAME back in as an optional parameter. IF DB_NAME is passed
					  in to the proc, it is assigned to @ThisDB, if it is not passed in, @ThisDB is populated using
					  the DB_NAME() function. (DECLARE @ThisDb sysname = ISNULL(@DB_NAME, DB_NAME()))
		   2012-01-17 George Hudd. Added synonym which references the similarly named procedure:
					  'UspDisableEnableNonClusteredIndexes' so that the duplicate proc can be removed.

CALL:      EXEC dbo.uspUtilityDisableEnableNonClusteredIndexes @ThisDb='TedBakerDW'
                                                       , @TABLE_NAME='dbo.FactEmailResponse'
                                                       , @Action='ENABLE'
                                                       --, @ExcludeList='IX_FactEmailResponse_GenusQuery'
                                                       --, @IncludeList = 'IX_FactEmailResponse_BrandKey,IX_FactEmailResponse_GenusQuery'
                                                       , @FeedFileKey int = 0
	                                                     , @FileSpecificationKey int = 0
                                                       , @DebugPrint = 0
                                                       , @DebugRecordset = 0
            2011-11-22 Philip Robinson. Amendment to reduce logging and record @Action is message. No other functional change.

============================================================================ */

CREATE PROCEDURE [dbo].uspUtilityDisableEnableNonClusteredIndexes  
  (  @TABLE_NAME SYSNAME
   , @Action nvarchar(10)
   , @IncludeList varchar(8000) = NULL
   , @ExcludeList varchar(8000) = NULL
   , @FeedFileKey int = 0
	 , @FileSpecificationKey int = 0
   , @DebugPrint bit = 0   
   , @DebugRecordset bit = 0
   , @DB_NAME SYSNAME = NULL)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Standard declarations and variable setting.
---------------------------------------------------------
DECLARE @ThisDb sysname = ISNULL(@DB_NAME, DB_NAME())
      , @Rows int
      , @ThisProc sysname = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNOWN')
      , @FileName varchar(127)
      , @SQL1 VARCHAR(1000)
      , @SQL2 VARCHAR(1000)
      
SELECT TOP 1 @FileName = OriginalFileName
FROM dbo.AuditFeedFile
WHERE FeedFileKey = @FeedFileKey

EXEC synUspAudit @Message=@Action, @AuditType='PROCESS START', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL, @PrintToScreen=@DebugPrint

BEGIN TRY
  --***************************************************
	-- START CUSTOM PROCESS
  --***************************************************
      
    -- Create and populate list of indexes table
    ---------------------------------------------------------
    IF OBJECT_ID('tempdb.dbo.#STOREINDEXINFORMATION') IS NOT NULL   DROP TABLE #STOREINDEXINFORMATION
    CREATE TABLE #STOREINDEXINFORMATION (IDENT int IDENTITY(1,1)
                                       , TABLENAME varchar(128)
                                       , FULLOBJECTNAME varchar(255)
                                       , INDEXNAME sysname )
                                   
    
    SET @SQL1 = '
    INSERT #STOREINDEXINFORMATION (FULLOBJECTNAME, TABLENAME, INDEXNAME)
    SELECT	SC.[TABLE_SCHEMA]+''.''+SC.[TABLE_NAME]
           ,SC.[TABLE_NAME]
		       ,SI.[NAME]
    FROM	'+@ThisDb+ '.SYS.INDEXES I JOIN SYS.TABLES T ON I.[OBJECT_ID] = T.[OBJECT_ID] 
    JOIN '+@ThisDb+ '.SYS.SYSINDEXES SI ON SI.ID = T.[OBJECT_ID] 
    JOIN '+@ThisDb+ '.INFORMATION_SCHEMA.TABLES SC ON SC.TABLE_NAME = OBJECT_NAME (T.[OBJECT_ID])
    WHERE	I.[INDEX_ID] > 1 
		    AND		I.[TYPE] = 2 
		    AND		I.[IS_PRIMARY_KEY] <> 1
		    AND		I.[IS_UNIQUE_CONSTRAINT] <> 1
		    AND		I.[INDEX_ID] = SI.INDID
		    AND		SC.[TABLE_SCHEMA]+''.''+SC.[TABLE_NAME] = '''+ @TABLE_NAME+''''		   
    
    -- Add list of indexes to #STOREINDEXINFORMATION table
                   
		IF @SQL1 IS NULL RAISERROR('@SQL dynamic sql variable is null, indicating a failure generating dynamic sql.', 16,1)
    BEGIN  
        EXEC (@SQL1)  
        SET @Rows = @@ROWCOUNT  
    END 
		
		IF @DebugRecordset>0 SELECT 'Before removals #STOREINDEXINFORMATION' AS [Before removals #STOREINDEXINFORMATION], * FROM #STOREINDEXINFORMATION
		SET @SQL1 = NULL;

		-- Remove rows if we have specific Inclusions or Exclusions
    ---------------------------------------------------------
    IF LEN(@IncludeList)>0
    BEGIN
        -- Remove indexes not in the specific inclusion list. 
        DELETE from #STOREINDEXINFORMATION
        WHERE INDEXNAME NOT IN (SELECT Item
                                FROM dbo.fnSplitStringList(@IncludeList, ',')
                                WHERE Item IS NOT NULL )
        SET @Rows = @@ROWCOUNT              
    END

    IF LEN(@ExcludeList)>0
    BEGIN
      -- Remove indexes in the specific exclusion list. 
      DELETE from #STOREINDEXINFORMATION
      WHERE INDEXNAME      IN (SELECT Item
                               FROM dbo.fnSplitStringList(@ExcludeList, ',')
                               WHERE Item IS NOT NULL )
      SET @Rows = @@ROWCOUNT                        
    END

    IF @DebugRecordset>0 SELECT 'After removals #STOREINDEXINFORMATION' AS [After removals #STOREINDEXINFORMATION], * FROM #STOREINDEXINFORMATION


    -- Process the Enable or Disable
    ---------------------------------------------------------
    DECLARE @INDEX int
    DECLARE @maxRec int
    SET @INDEX = 0

    SELECT @INDEX = MIN(IDENT) FROM #STOREINDEXINFORMATION
    WHERE IDENT > @INDEX

    WHILE @INDEX > 0
      BEGIN 
        SELECT @SQL2 =  CASE WHEN UPPER(LEFT(LTRIM(@Action),1)) = 'D' THEN 'ALTER INDEX '+ [INDEXNAME] +' ON '+[FULLOBJECTNAME]+' DISABLE'
                             WHEN UPPER(LEFT(LTRIM(@Action),1)) = 'E' THEN 'ALTER INDEX '+ [INDEXNAME] +' ON '+[FULLOBJECTNAME]+' REBUILD'
                             ELSE ''
                        END
        FROM #STOREINDEXINFORMATION
        WHERE IDENT=@INDEX
         
        IF ISNULL(@SQL2,'') <> ''
        BEGIN  
            EXEC (@SQL2)
            SET @SQL2 = ''  
            SET @Rows = @@ROWCOUNT  
        END 
        
        SELECT @INDEX = MIN(IDENT) FROM #STOREINDEXINFORMATION
        WHERE IDENT > @INDEX
    END 
    SET @SQL2 = NULL;
      
--***************************************************
	-- END OF PROCESSING
  --***************************************************
EXEC synUspAudit @AuditType='PROCESS COMPLETE', @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint

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
	(
		@ErrorMessage,
		@ErrorSeverity,
		1,
		@ErrorNumber,
		@ErrorSeverity,
		@ErrorState,
		@ErrorProcedure,
		@ErrorLine
	);     
END CATCH