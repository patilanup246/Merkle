
/*===========================================================================================
Name:             uspRPTDataLoadReport
Purpose:          Returns information of extract files and affected tables
Parameters:       @StartDate - Shows extracts started after this date
                        @EndDate- Shows extracts started before the end of this date
                        @FileFilter - Used to filter results based on filename
Notes:                  
Created:          2010-02-15  Colin Thomas
Modified:         
Peer Review:      
Call script:      EXEC uspRPTDataLoadReport '1 Jan 2010','16 Feb 2010', 'All'
=================================================================================================*/
CREATE PROCEDURE [dbo].[uspRPTDataLoadReport]
                        @StartDate datetime,
                        @EndDate datetime,
                @FileFilter varchar(50)
AS
SET XACT_ABORT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRANSACTION
BEGIN TRY

      -- Your DDL starts here
      
      SELECT
       CAST(aff.ETLStartDate as DATE) as ProcessingDate,
       aff.ETLStartDate,
       aff.ProcessedFileName, 
       aff.DropDate, 
       DATEDIFF(ss, aff.ETLStartDate, aff.ETLStopDate) Duration_Sec,
       aff.DropRowCount,
       aff.ExtractGoodCount, 
       aff.ExtractErrorCount, 
       aff.SuccessFlag,
       atp.TableName,
       atp.InsertStdRowCnt, 
       atp.UpdateRowCnt, 
       atp.NoChangeCnt,
       atp.ErrorRowCnt,
       atp.DuplicateBKCnt,
       COALESCE(atp.InsertStdRowCnt,0)
       +COALESCE(atp.UpdateRowCnt,0)
       +COALESCE(atp.NoChangeCnt,0)
       +COALESCE(atp.DuplicateBKCnt,0) total_updates
      INTO #ResultSet
      FROM [AuditFeedFile] aff WITH (NOLOCK)
      left JOIN AuditTableProcessing atp 
        ON atp.FeedFileKey=aff.FeedFileKey
      WHERE ETLStartDate BETWEEN @StartDate and DATEADD(dd, 1, @EndDate)
       AND (@FileFilter='All' 
            OR aff.ProcessedFileName like '%'+@FileFilter+'%')
       --AND aff.ShowInLoadReport = 'y'
      ORDER BY ETLStartDate DESC

      
      IF @@ROWCOUNT = 0
            --Send empty result row
            SELECT
                  cast(null as datetime) as ProcessingDate,
                  cast(null as datetime) as ETLStartDate,
                  'None' as ProcessedFileName, 
                  cast(null as datetime) as DropDate, 
                  0 as Duration_Sec,
                  0 as DropRowCount,
                  0 as ExtractGoodCount, 
                  0 as ExtractErrorCount, 
                  cast(null as char(1)) as SuccessFlag,
                  'None' as TableName,
                  0 as InsertStdRowCnt, 
                  0 as UpdateRowCnt, 
                  0 as NoChangeCnt,
                  0 as ErrorRowCnt,
                  0 as DuplicateBKCnt,
                  0 as total_updates
      ELSE
            SELECT * FROM #ResultSet
            
            
      -- and ends here
      IF XACT_STATE() = 1
      BEGIN
            COMMIT TRANSACTION;
      END;
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
      --Place cleanup and logging code
      IF @@TRANCOUNT > 0
      BEGIN
            ROLLBACK TRANSACTION;
      END;

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