
CREATE PROCEDURE [dat_dtv].[uspAddAudit]
    @Process VARCHAR(128)
   ,@Step VARCHAR(128)
   ,@FileName VARCHAR(128)
   ,@PkgExecKey VARCHAR(50)
AS
    INSERT  INTO [dat_dtv].[AuditLog]
            ([Process]
            ,[Step]
            ,[FileName]
            ,[AuditStartTime]  
			,[PkgExecKey]          
            )
    VALUES  (@Process
            ,@Step
            ,@FileName
            ,GETDATE()
			,REPLACE(REPLACE(@PkgExecKey,'}',''),'{','')
            );