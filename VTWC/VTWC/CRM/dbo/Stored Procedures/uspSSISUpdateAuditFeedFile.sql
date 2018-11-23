
/*===========================================================================================
Name:			  uspSSISUpdateAuditFeedFile
Purpose:		Updates AuditFeedFile for the feed file that is	referenced by FeedFileKey.
				    This stored procedure should be called once for	each feed file that is
				    processed by the package.
Parameters:		@FeedFileKey		- The key of the DimAudit row that needs to be updated by
									  this stored procedure.
				      @ExtractGoodCount	- The number of rows that were extracted from the feed file
									  that passed the column validation tests in the package.
				      @ExtractErrorCount	- The number of rows that were extracted from the feed file
									  that failed the column validation tests in the package.
Outputs:		None
Notes:			    
			
Created:		2009-05-23	Caryl Wills
Modified:		2010-02-22  Joey Breame
                Extended functionality to copy data from from extention row to zip and zip row to extention so both
                rows also have all the matching information. Also made @ExtractGoodCount and 
                @ExtractErrorCount optional and default as NULL.
                Extended to work with any extention, not just CSV.
Modified:		2011-02-28  Philip Robinson. Bug in script. Proc name was "[uspSSISUpdateAuditFeedFile 27]"
Modified:   2011-03-01  Philip Robinson. When ZIP file entry gets updated it was not updating ETLStopDate, just ETLStartDate.
                        This was because of incorrect sequence of the logic added on 22-Feb.
Modified:   2011-03-01  Philip Robinson. Added functionality so also cleans up .ATT and .CUS files which are left 
                        behind in the AuditFeedFile log as unprocessed files                       
Modified: 2011-04-20    Joey Breame. Extended the SET for .cus and .att to be SuccessFlag = 'Y' and ShowInLoadReport = 'N'  
Modified: 2012-12-10    Nitin Khurana. ShowInLoadReport should not be reset to 'N' when drop date is copied from ZIP to CSV
                                       Setting DropRowCount using @ZIPDropRowCount.

Peer Review:	
Call script:	EXEC uspSSISUpdateAuditFeedFile ?
=================================================================================================*/
CREATE PROCEDURE [dbo].[uspSSISUpdateAuditFeedFile]
				 @FeedFileKey INT,
				 @ExtractGoodCount INT = NULL,
				 @ExtractErrorCount INT = NULL,
				 @DebugPrint int = NULL,
				 @DebugRecordset int = NULL
AS
SET XACT_ABORT ON;
BEGIN TRY
	
DECLARE @Rows int = 0
DECLARE @BaseProcessedFileName  VARCHAR(150)
DECLARE @ZIPETLStartDate DATETIME
DECLARE @ZIPETLStopDate DATETIME
DECLARE @ZIPDropDate  DATETIME

DECLARE @ZIPDropRowCount INT
DECLARE @ZIPDropFileSize INT
DECLARE @ExtETLStartDate DATETIME
DECLARE @ExtETLStopDate DATETIME
DECLARE @ExtDropDate  DATETIME
DECLARE @ExtOriginalFileName  VARCHAR(150)
    
    
-- Get the extention name from the filename
--------------------------------------------------------- 
DECLARE @FileName VARCHAR(128) =(SELECT ProcessedFileName FROM AuditFeedFile 
                                 WHERE FeedFileKey = @FeedFileKey)
DECLARE @ExtStart INT
DECLARE @Ext VARCHAR(128)

SET @ExtStart = CHARINDEX('.',REVERSE(@FileName),0)
    
IF @ExtStart>0 SET @Ext=  RIGHT(@FileName, @ExtStart)
ELSE           SET @Ext = ''
            
            
SET @BaseProcessedFileName  = (SELECT REPLACE(ProcessedFileName, @Ext, '') FROM AuditFeedFile 
                               WHERE FeedFileKey = @FeedFileKey)



-- Update AuditFeedFile row
---------------------------------------------------------
-- Update AuditFeedFile with the count of rows processed.
UPDATE AuditFeedFile
SET 
  ETLStopDate = GETDATE(),
	ExtractGoodCount = COALESCE(@ExtractGoodCount, ExtractGoodCount),
	ExtractErrorCount = COALESCE(@ExtractErrorCount, ExtractErrorCount),
	SuccessFlag = 'Y',
	ShowInLoadReport = 'Y'
WHERE FeedFileKey = @FeedFileKey



-- Store details of current file and zip file (if any)
---------------------------------------------------------
-- Collect the values from the corresponding Zip row                            
SELECT
    @ZIPETLStartDate = ETLStartDate,
    @ZIPETLStopDate = ETLStopDate,
    @ZIPDropDate = DropDate,
	@ZIPDropRowCount = DropRowCount
FROM AuditFeedFile 
WHERE OriginalFileName = @BaseProcessedFileName+'.ZIP'

-- Collect the values from the corresponding Ext row 
SELECT
    @ExtETLStartDate = ETLStartDate,
    @ExtETLStopDate = ETLStopDate,
    @ExtDropDate = DropDate,
    @ExtOriginalFileName = OriginalFileName
FROM AuditFeedFile 
WHERE FeedFileKey = @FeedFileKey



IF @DebugRecordset>0 SELECT '@DebugRecordset' AS [@DebugRecordset]
                           , @FeedFileKey AS [@FeedFileKey]
                           , @FileName AS [@FileName]
                           , @BaseProcessedFileName AS [@BaseProcessedFileName]
                           , @Ext AS [@Ext]
                           , @ExtractGoodCount AS [@ExtractGoodCount]
                           , @ExtractErrorCount AS [@ExtractErrorCount]
                           , @ExtETLStartDate AS [@ExtETLStartDate]
                           , @ExtETLStopDate AS [@ExtETLStopDate]
                           , @ExtDropDate AS [@ExtDropDate]
                           , @ExtOriginalFileName AS [@ExtOriginalFileName]
                           , @ZIPETLStartDate AS [@ZIPETLStartDate]
                           , @ZIPETLStopDate AS [@ZIPETLStopDate]
                           , @ZIPDropDate AS [@ZIPDropDate]
                           , @ZIPDropRowCount AS [@ZIPDropRowCount]
                           , @ZIPDropFileSize AS [@ZIPDropFileSize]



IF (SELECT COUNT(*) 
    FROM AuditFeedFile 
    WHERE OriginalFileName = @BaseProcessedFileName+'.ZIP') > 0
BEGIN
    UPDATE AuditFeedFile -- Update ext row with Zip data if it's blank
    SET 
        ETLStartDate = COALESCE(ETLStartDate, @ZIPETLStartDate),
        ETLStopDate = COALESCE(ETLStopDate, @ZIPETLStopDate),
        DropDate = COALESCE(DropDate,@ZIPDropDate),
        DropRowCount = COALESCE(DropRowCount,@ZIPDropRowCount), --Required for the load report
        SuccessFlag = 'Y'
        --ShowInLoadReport = 'N'  
    WHERE FeedFileKey = @FeedFileKey


    UPDATE AuditFeedFile -- Update ZIP row with ext data if it's not blank
    SET 
        ETLStartDate = COALESCE(ETLStartDate, @ExtETLStartDate),
        ETLStopDate = COALESCE(ETLStopDate, @ExtETLStopDate),
        DropDate = COALESCE(DropDate, @ExtDropDate),
        ProcessedFileName = @ExtOriginalFileName, -- Change to the ext file name, Not Zip as this is more logical for the column.
        SuccessFlag = 'Y',
        ShowInLoadReport = 'N'     
    WHERE OriginalFileName = @BaseProcessedFileName+'.ZIP'
END 


-- 2011-03-01 Also clean up .CUS and .ATT files.
-- Same as before but we do not update ProcessedFileName.
IF (SELECT COUNT(*) 
    FROM AuditFeedFile 
    WHERE OriginalFileName = @FileName+'.CUS') > 0
BEGIN
    UPDATE AuditFeedFile -- Update ZIP row with ext data if it's not blank
    SET 
        ETLStartDate = COALESCE(ETLStartDate, @ExtETLStartDate),
        ETLStopDate = COALESCE(ETLStopDate, @ExtETLStopDate),
        DropDate = COALESCE(DropDate, @ExtDropDate),
        SuccessFlag = 'Y',
        ShowInLoadReport = 'N'  
        
    WHERE OriginalFileName = @FileName+'.CUS'
      
    SET @Rows = @@ROWCOUNT
    IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Fixed .CUS rows. '+CONVERT(varchar,@Rows)+' rows.'
END 

IF (SELECT COUNT(*) 
    FROM AuditFeedFile 
    WHERE OriginalFileName = @FileName+'.ATT') > 0
BEGIN
    UPDATE AuditFeedFile -- Update ZIP row with ext data if it's not blank
    SET 
        ETLStartDate = COALESCE(ETLStartDate, @ExtETLStartDate),
        ETLStopDate = COALESCE(ETLStopDate, @ExtETLStopDate),
        DropDate = COALESCE(DropDate, @ExtDropDate),
        SuccessFlag = 'Y',
        ShowInLoadReport = 'N'  
    WHERE OriginalFileName = @FileName+'.ATT'
      
    SET @Rows = @@ROWCOUNT
    IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Fixed .ATT rows. '+CONVERT(varchar,@Rows)+' rows.'
END 




                             
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