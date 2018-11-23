/*===========================================================================================
Name:			uspSSISGetAuditFeedFileKey
Purpose:		Checks to see if an AuditFeedFile row exists for the specified
				file and if not inserts one.
Parameters:		@FileName	  - The name of the feed file that is being processed.
				@PkgExecKey	  - The primary key of the AuditPkgExec row under which this ETL
								process is running.
				@ProcessFolder- The full UNC path of the folder where the file is placed for
								processing.
				@ArchiveFolder- The full UNC path of the folder where the file is copied to
								after it has been processed.
				@ErrorFolder  - The full UNC path of the folder where the file is placed if
								any errors are found.
				@FeedType -		A friendly name for the package\feed. This will be used in the end-to-end report.
								
Outputs:		@FeedFileKey  - The key of the AuditFeedFile row that is created/updated by
								by this stored procedure.
Notes:			    
			
Created:	2009-05-23	Caryl Wills
Modified:   2009-06-08	Philip Robinson Changed line 51 from ETLStartDate IS NOT NULL to ETLStartDate IS NULL
                                        We want to retuirn key only if file has not yet been involved in ETL process.
			2009-06-16	Philip Robinson Added FeedType paramter to populate table in AudutFeedFile. Useful for end-to-end reports.
            2009-07-08	Philip Robinson Added optional @ReturnFolder param which will return the path to return the
                                        file to based on SourceFolder. If SourceFolder is null, null will be returned.
                                        Also amended so if file is registered by this process it does not record an entry in SourceFolder
                                        as this is not really the SourceFolder. ProcessFolder will continue to be recorded.
                                        SP was tested to make sure the new param will not break existing packages that do not
                                        pass in the SP.
             2010-11-09	Nitin Khurana	Added logic to update FileSpecificationKey on AuditFeedFile table for Genworth                           
			 2011-06-29 Colin Thomas	Added AuditLog to record the start of file processing.
			 2011-09-01 Philip Robinson. Increasing param size of @FileName to 100.
			 2012-08-24 Steve Blackman. Removed transaction because caused error 
			 2013-01-17 Nitin Khurana   FileSpecificationKey insert in AuditFeedFile
			 2013-05-31 Nilesh Rathi	SP uspSSISFileProcessList updated to include code to insert files to be processed in 
										the AuditFeedfile table. As a result of this the update AuditFeedfile statement in this SP 
										needs to include more columns if they are empty. This is because in the uspSSISFileProcessList
										we only insert record in Auditfeedfile table and populate only OriginalFileName and DateCreated columns
             2013-11-01 Philip Robinson Added optional param to allow duplicate files to be loaded. 
			 2013-11-26 Nigel Ainscoe   Make sure file specification key is populated on inserts. Tidy up the code a bit.

Peer Review:	
Call script:	EXEC uspSSISGetAuditFeedFileKey ?,?,?,?,?
=================================================================================================*/
CREATE PROCEDURE [dbo].[uspSSISGetAuditFeedFileKey]
				@FileName VARCHAR(100),
				@PkgExecKey INT,
				@ProcessFolder VARCHAR(255),
				@ArchiveFolder VARCHAR(255),
				@ErrorFolder VARCHAR(255),
				@FeedType VARCHAR(20),
				@FeedFileKey INT OUTPUT,
				@ReturnFolder VARCHAR(255) = NULL OUTPUT,
				@FileSpecificationKey INT = 0 OUTPUT,
                @AllowDuplicateFileName BIT = 0

AS
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @Error INT = 0
	DECLARE @RC_Initial INT = -1
	DECLARE @ETLStartDate DATETIME
	DECLARE @ThisDb SYSNAME = DB_NAME()

	SELECT @FileSpecificationKey = COALESCE(dbo.fnGetFileSpecificationKey(@Filename),@FileSpecificationKey)
	
	-- See if an UNPROCESSED AuditFeedFile row already exists for the specified file.
	SELECT @FeedFileKey = ISNULL(MAX(FeedFileKey), -1)
	FROM AuditFeedFile
	WHERE OriginalFileName = @FileName
	  AND ETLStartDate IS NULL

    IF @FeedFileKey > 0
        BEGIN
			-- An AuditFeedFile row already exists for this file, but it has
			-- not yet been processed, so we are OK to process it now.
            UPDATE  AuditFeedFile
            SET     ETLStartDate = GETDATE()
                  , PkgExecKey = @PkgExecKey
                  , FileSpecificationKey = COALESCE(FileSpecificationKey, @FileSpecificationKey)
                  , ProcessFolder = COALESCE(ProcessFolder, @ProcessFolder)
                  , ArchiveFolder = COALESCE(ArchiveFolder, @ArchiveFolder)
                  , ErrorFolder = COALESCE(ErrorFolder, @ErrorFolder)
                  , OriginalFileName = COALESCE(OriginalFileName, @FileName)
                  , ProcessedFileName = COALESCE(ProcessedFileName, @FileName)
                  , ShowInLoadReport = COALESCE(ShowInLoadReport, 'Y')
                  , FeedType = COALESCE(FeedType, @FeedType)
            WHERE   FeedFileKey = @FeedFileKey
        END
	ELSE
	BEGIN
		-- Either an AuditFeedFile row does not exist for the specified file,
		-- or one exists and the file has been loaded.
		SELECT @FeedFileKey = ISNULL(MAX(FeedFileKey), -1)
		FROM AuditFeedFile
		WHERE OriginalFileName = @FileName
		
		
        -- CASE 1: Duplicate file not allowed (default behaviour) and file has already been loaded (or attempted to be loaded)
		IF @FeedFileKey > 0 AND ISNULL(@AllowDuplicateFileName,0)=0
        BEGIN
            SET @Error = 1
        END
        -- CASE 2: Duplicate file allowed and file has already been loaded (or attempted to be loaded)
		ELSE 
		BEGIN
			-- An AuditFeedFile row does not exist so create one.
			INSERT INTO AuditFeedFile
			(
				PkgExecKey
				,ProcessFolder
				,ArchiveFolder
				,ErrorFolder
				,OriginalFileName
				,ProcessedFileName
				,ETLStartDate
				,ShowInLoadReport
			    ,FeedType
				,FileSpecificationKey
)
			VALUES
			(
				@PkgExecKey
				,@ProcessFolder
				,@ArchiveFolder
				,@ErrorFolder
				,@FileName
				,@FileName
				,GETDATE()
				,'Y'
				,@FeedType
				,@FileSpecificationKey
			)
			SET @FeedFileKey = CAST(SCOPE_IDENTITY() AS INT)
		END
	END

  SELECT @ReturnFolder = REPLACE(SourceFolder, 'To_DBG', 'From_DBG')
  FROM AuditFeedFile
  WHERE FeedFileKey = @FeedFileKey

  IF LEN(@ReturnFolder)>0 AND RIGHT(@ReturnFolder,1) <> '\'   SET @ReturnFolder = @ReturnFolder+'\'

  --Create AuditLog entry for this file
  EXEC dbo.uspAuditAddAudit @AuditType='PS', @Process='Process File', @ProcessStep = @FileName, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL, @PrintToScreen=0

  RETURN @Error
END TRY
BEGIN CATCH
	DECLARE 
		@ErrorMessage VARCHAR(4000),
		@ErrorNumber INT,
		@ErrorSeverity INT,
		@ErrorState INT,
		@ErrorLine INT,
		@ErrorProcedure VARCHAR(126);

	SELECT 
		@ErrorNumber = ERROR_NUMBER(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE(),
		@ErrorLine = ERROR_LINE(),
		@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), 'N/A');

	--Build the error message string
	SELECT @ErrorMessage = 'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +
						   'Message: ' + ERROR_MESSAGE()      
						   	
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