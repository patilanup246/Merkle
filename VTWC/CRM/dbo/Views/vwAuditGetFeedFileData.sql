
/*===========================================================================================
Name:			  vwAuditGetFeedFileData
Purpose:		Selects the AuditFeedFile row and TableProcessKey for all DimAudit rows.
Notes:			    
			
Created:		2009-05-26	Caryl Wills
Modified:		2010-11-05  Philip Robinson. Amending view in line with changes to audit tables.
Modified:   2010-12-04  Philip Robinson. Adding InsertStdRowCount from AuditTableProcessing.
Modified:   2010-12-16  Philip Robinson. Adding BranchName.
            2011-01-04 Leyton Holmes - Change to column names on DimAudit
            2011-01-04 Philip Robinson. Changed alias from "Count" to "Cnt" for consistency.
            2011-11-04 Leyton Holmes. Added VerifyReference Column
            2012-10-04 Philip Robinson. Added ParentPkgExecKey. This is useful for getting all pkg executions related to a master load.
=============================================================================================*/
CREATE VIEW [dbo].[vwAuditGetFeedFileData]
AS
	SELECT DimAudit.AuditKey,
		   ATP.TableProcessKey,
		   AFF.FeedFileKey,
		   AFF.PkgExecKey,
           AP.ParentPkgExecKey,
		   AFF.SourceFolder,
		   AFF.ProcessFolder,
		   AFF.ArchiveFolder,
		   AFF.ErrorFolder,
		   AFF.OriginalFileName,
		   AFF.ProcessedFileName,
		   AFF.VerifyReference,
		   AFF.DropDate,
		   AFF.DropRowCount,
		   AFF.DropFileSize,
		   AFF.PreProcessMessage,
		   AFF.ProcessStatus,
		   AFF.ProcessedDate,
		   AFF.ProcessingRowCount,
		   AFF.ProcessingFileSize,
		   AFF.ETLStartDate,
		   AFF.ETLStopDate,
		   AFF.SuccessFlag      AS AFFSuccessFlag,
		   AFF.ExtractGoodCount,
		   AFF.ExtractErrorCount,
		   AFF.FeedType,
		   AFF.ShowInLoadReport AS AFFShowInLoadReport,
		   AFF.DateCreated      AS AFFDateCreated,
		   ATP.TableName,
		   ATP.InsertStdRowCnt,
		   ATP.UpdateRowCnt,
		   ATP.ErrorRowCnt,
		   ATP.NoChangeCnt,
		   ATP.DuplicateBKCnt,
		   ATP.TableInitialRowCnt,
		   ATP.TableFinalRowCnt,
		   -- 2010-11-05 Adding new BranchXxxxRowCount columns.
		   -- 2010-12-16 Added branch names.
		   DimAudit.ProcessingSummaryGroup,
		   DimAudit.InsertRowCnt AS BranchInsertRowCnt,
		   DimAudit.UpdateRowCnt AS BranchUpdateRowCnt,
		   
		   ATP.SuccessFlag         AS ATPSuccessFlag,
		   ATP.ShowInLoadReport    AS ATPShowInLoadReport,
		   ATP.DateCreated         AS ATPDateCreated
	FROM dbo.DimAudit
	INNER JOIN dbo.AuditTableProcessing AS ATP 	ON ATP.TableProcessKey = DimAudit.TableProcessKey
	INNER JOIN dbo.AuditFeedFile AS AFF         ON AFF.FeedFileKey = ATP.FeedFileKey
  INNER JOIN dbo.AuditPkgExecution AP         ON AFF.PkgExecKey = AP.PkgExecKey