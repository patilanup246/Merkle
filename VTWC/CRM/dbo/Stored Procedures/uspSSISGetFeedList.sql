/*============================================================================
Name:         dbo.uspSSISGetFeedList
Purpose:	  Gets an ordered list of files for SSIS processing. CAM needs to load first.
Parameters:
Notes:	

Created: 2018-06-17		Adrian Power		Creation
Modified:
Peer Review:
Call script: exec dbo.uspSSISGetFeedList
==================================================================================*/ 
CREATE PROCEDURE [dbo].[uspSSISGetFeedList]
	 @FileList varchar(4000) = NULL,
	 @ProcessFolder VARCHAR(100) = NULL,
	 @DebugPrint tinyint = 0,
	 @DebugRecordSet tinyint = 0

AS

BEGIN TRY
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

	SET @FileName = 'List of Files'

	EXEC synUspAudit @AuditType='PROCESS START'
				   , @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint
				   , @Message = 'dbo.uspSSISGetFeedList Start'

	--Get the list
	SELECT 
		-- FileSpecificationKey
		--,FileSpecificationName
		--,ClientCode
		--,SupplierCode
		--,FileType
		--,FileNameElement4
		--,FileNameElement5
		SUBSTRING(FileNameWildCard,0,LEN(FileNameWildCard)-5)
		--,FileSpecificationOptions
	FROM dbo.MetadataFileSpecification
	ORDER BY FileSpecificationOptions
			--CASE WHEN FileNameElement4 = 'CAM' THEN 'AAAA'
				 --WHEN FileNameElement4 = 'PER' THEN 'AAAB'
				 --WHEN FileNameElement4 = 'CAN' THEN 'AAAC'
				 --ELSE FileNameElement4
			--END
			DESC;



	--Get Some Logging Data
	SELECT @FileName = SUBSTRING(
(
    SELECT ',' + FilenameElement4 AS 'data()'
        FROM dbo.MetadataFileSpecification
	ORDER BY FileSpecificationOptions
			DESC
        FOR XML PATH('')
), 2 , 9999) 



SELECT @FileName = 'dbo.uspSSISGetFeedList End - ' + @FileName



	EXEC synUspAudit @AuditType='TRACE'
				   , @Process=@ThisProc
				   , @ProcessStep='Finished Running the get file from meta data set'
				   , @DatabaseName=@ThisDb
				   , @FileName=@FileName
				   , @Rows=@@RowCount
				   , @PrintToScreen=@DebugPrint
				   , @Message = @ProcessFolder

	EXEC synUspAudit @AuditType='PROCESS COMPLETE'
				, @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=@@RowCount,@PrintToScreen=@DebugPrint , @Message = @FileName

	END TRY
	BEGIN CATCH
		DECLARE 
			@ErrorMessage VARCHAR(4000) = ERROR_MESSAGE() ,
			@ErrorNumber INT = ERROR_NUMBER(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE(),
			@ErrorLine INT = ERROR_LINE(),
			@ErrorProcedure VARCHAR(126) = ISNULL(ERROR_PROCEDURE(), 'N/A')
			;
		-- Log
		EXEC synUspAudit @AuditType='ERROR', @Message=@ErrorMessage
					         , @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint
	    
		--Rethrow the error
		RAISERROR  ( @ErrorMessage, @ErrorSeverity,	1);     
	END CATCH