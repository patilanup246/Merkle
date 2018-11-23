

CREATE PROCEDURE [dat_dtv].[uspUpdateAuditEndTime]
    @Process VARCHAR(128)
   ,@Step VARCHAR(128)
   ,@FileName VARCHAR(128)
   ,@PkgExecKey VARCHAR(50)
AS
SELECT @FileName = REPLACE(@FileName,'.gpg','')
    UPDATE  [dat_dtv].[AuditLog]
    SET     [AuditEndTime] = GETDATE()
    WHERE   [Process] = @Process
            AND [Step] = @Step
            AND [FileName] = @FileName
			AND '{' + [PkgExecKey] + '}' = @PkgExecKey;