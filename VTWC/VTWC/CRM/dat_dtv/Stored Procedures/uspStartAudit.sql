
CREATE PROCEDURE [dat_dtv].[uspStartAudit]
    @Process VARCHAR(128)
   ,@Step VARCHAR(128)
   ,@FileName VARCHAR(128)
   ,@PkgExecKey VARCHAR(50)
AS 
--InsertIntoAuditTable
    EXECUTE [dat_dtv].[uspAddAudit] @Process = @Process, -- varchar(128)
        @Step = @Step, -- varchar(128)
        @FileName = @FileName, -- varchar(128)
		@PkgExecKey = @PkgExecKey; -- varchar(50)
--Update FeedFileTable
    EXECUTE [dat_dtv].[uspUpdateAuditFeedFile] @FileName = @FileName, -- varchar(128)
        @PkgExecKey = @PkgExecKey, -- varchar(50)
        @FileStatus = @Step; -- varchar(15)