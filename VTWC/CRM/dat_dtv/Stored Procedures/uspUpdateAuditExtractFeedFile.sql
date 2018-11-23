CREATE PROCEDURE [dat_dtv].[uspUpdateAuditExtractFeedFile]
    @FileName VARCHAR(128)
   ,@PkgExecKey VARCHAR(50)
   ,@FileStatus VARCHAR(15)
AS
    UPDATE [dat_dtv].AuditExtractFeedFile
    SET     [FileStatus] = @FileStatus
    WHERE   '{' + [PkgExecKey] + '}' = @PkgExecKey
            AND [FileName] = @FileName;