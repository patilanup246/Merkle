CREATE PROCEDURE [dat_dtv].[uspInsertIntoAuditFeedFile]
AS
    SET DATEFORMAT YMD;
    INSERT  [dat_dtv].[AuditFeedFile]
            ([PkgExecKey]
            ,[SourceFolder]
            ,[ProcessFolder]
            ,[RowData]
            ,[ProcessedDate]
            ,[FileName]
            ,[FileSizeBytes]
            ,[CreateDate]
            ,[FileStatus]
            )
    SELECT  [PkgExecKey]
           ,[SourceFolder]
           ,[ProcessFolder]
           ,[RowData]
           ,[ProcessedDate]
           ,CAST([FileName] AS VARCHAR(50)) AS [FileName]
           ,CAST([FileSizeBytes] AS BIGINT) AS [FileSizeBytes]
           ,CAST([CreateDate] AS DATETIME) AS [CreateDate]
           ,'NewFile' [FileStatus]
    FROM    [dat_dtv].[StagingAuditFeedFile] AS [saff]
    WHERE   NOT EXISTS ( SELECT 1
                         FROM   [dat_dtv].[AuditFeedFile] [paff]
                         WHERE  [saff].[FileName] = [paff].[FileName] )
            AND CAST([FileSizeBytes] AS BIGINT) <> 0;