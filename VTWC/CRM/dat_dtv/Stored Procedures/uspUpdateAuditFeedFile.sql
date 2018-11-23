


CREATE PROCEDURE [dat_dtv].[uspUpdateAuditFeedFile]
    @FileName VARCHAR(128)
   ,@PkgExecKey VARCHAR(50)
   ,@FileStatus VARCHAR(15)
AS
    UPDATE  [dat_dtv].[AuditFeedFile]
    SET     [FileStatus] = @FileStatus
    WHERE   '{' + [PkgExecKey] + '}' = @PkgExecKey
            AND [FileName] = @FileName;