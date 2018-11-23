
/*===========================================================================================
Name:			uspSSISUpdateAuditTables
Purpose:		Updates DimAudit and AuditTableProcessing for a specific table that is
				referenced by DimAuditKey.  This stored procedure should be called once for
				each table that has rows inserted or updated in it.
Parameters:		@DimAuditKey  - The key of the DimAudit row that needs to be updated by this
								stored procedure.
Outputs:		None
Notes:			    
			
Created:		2009-05-23	Caryl Wills
Modified:		2010-12-23  Philip Robinson. Now update Insert\Update counts etc on DimAudit.
                2011-01-04  Leyton Holmes. Change to DimAudit Column names
                2011-01-19  Nitin Khurana. added column @RC_ExtractGood; updated the DimAudit update logic. 
                2011-05-26  Philip Robinson. Removed TRAN.
                2016-04-08  Caryl Wills. Changed the code used to establish the number of rows in a table
                            so that it can cope with a fully qualified (schema.tablename) table name.

Peer Review:	
Call script:	EXEC uspSSISUpdateAuditTables ?,?,?,?,?,?,?,?,?
=================================================================================================*/
CREATE  PROCEDURE [dbo].[uspSSISUpdateAuditTables]  
     @DimAuditKey INT,  
     @RC_NewRows INT,  
     @RC_ChangedRows INT,  
     @RC_UnchangedRows INT,  
     @RC_ErrorRows INT,  
     @RC_ErrorRows2 INT,  
     @RC_ErrorRows3 INT,  
     @RC_DuplicateInserts INT,  
     @RC_DuplicateUpdates INT,
     @RC_ExtractGood INT  = 0
AS  
SET XACT_ABORT ON;  
SET NOCOUNT ON;

BEGIN TRY  
 DECLARE @RC_Final INT = -1  
 DECLARE @TableName VARCHAR(50)  
 DECLARE @TableProcessKey INT  
   
 -- Update DimAudit with the count of rows processed.  
 UPDATE DimAudit  
 SET BranchRowCnt = @RC_NewRows + @RC_ChangedRows  
   , InsertRowCnt = @RC_NewRows  
   , UpdateRowCnt = @RC_ChangedRows
   , GoodRowCnt   = @RC_ExtractGood  
 WHERE AuditKey = @DimAuditKey  
  
 -- Get the AuditTableProcessing key from the DimAudit row.  
 SELECT @TableProcessKey = TableProcessKey  
 FROM DimAudit  
 WHERE AuditKey = @DimAuditKey  
  
 -- Get the name of the table being loaded from the associated AuditTableProcessing row.  
 SELECT @TableName = TableName  
 FROM AuditTableProcessing  
 WHERE TableProcessKey = @TableProcessKey  
  
 -- Get the total number of rows in the table just loaded.  
 SELECT @RC_Final = rows FROM sysindexes   
 WHERE object_name(id) = CASE WHEN CHARINDEX('.', REVERSE(@Tablename)) > 0
                              THEN RIGHT(@TableName, CHARINDEX('.', REVERSE(@Tablename)) - 1)
                              ELSE @TableName
                         END
   AND indid <= 1  

 -- Finally update AuditTableProcessing with the row counts.  
 UPDATE AuditTableProcessing  
 SET InsertStdRowCnt = @RC_NewRows,  
  UpdateRowCnt = @RC_ChangedRows,  
  ErrorRowCnt = @RC_ErrorRows + @RC_ErrorRows2 + @RC_ErrorRows3,  
  NoChangeCnt = @RC_UnchangedRows,  
  DuplicateBKCnt = @RC_DuplicateInserts + @RC_DuplicateUpdates,  
  TableFinalRowCnt = @RC_Final,  
  SuccessFlag = 'Y'  
 WHERE TableProcessKey = @TableProcessKey  
  

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