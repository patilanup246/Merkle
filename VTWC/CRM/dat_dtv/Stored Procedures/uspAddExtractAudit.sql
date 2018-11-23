




CREATE PROCEDURE [dat_dtv].[uspAddExtractAudit]
    @PkgExecKey VARCHAR(50)
   ,@ExtractFolder VARCHAR(255)
   ,@DestinationFolder VARCHAR(255)
   ,@Step VARCHAR(128)
   ,@FileName VARCHAR(128)
AS
   INSERT INTO [dat_dtv].[AuditExtractFeedFile]
        ([PkgExecKey]
        ,[ExtractFolder]
        ,[DestinationFolder]
        ,[FileName]
		,[FileStatus]
        ,[LastUpdateDate]
        )
    VALUES  (@PkgExecKey 
			,@ExtractFolder
			,@DestinationFolder
			,@FileName
			,@Step
            ,GETDATE()
            );