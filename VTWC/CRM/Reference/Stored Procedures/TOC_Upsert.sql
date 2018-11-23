﻿/*===========================================================================================
Name:			Reference.TOC_Upsert
Purpose:		Insert/Update TOC reference data into table Reference.TOC
Parameters:		@userid - The key for the user executing the proc	
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-23	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Reference.TOC_Upsert
=================================================================================================*/

CREATE PROCEDURE [Reference].[TOC_Upsert]
(
	@userid                INTEGER = 0,
	@DebugPrint			   INTEGER = 0,
	@PkgExecKey			   INTEGER = -1,
	@DebugRecordset		   INTEGER = 0
)
AS
BEGIN

    SET NOCOUNT ON;

	DECLARE @now                    DATETIME = GETDATE()

	DECLARE @spid	INTEGER	= @@SPID
	DECLARE @spname  SYSNAME = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
	DECLARE @dbname  SYSNAME = DB_NAME()
	DECLARE @Rows	INTEGER = 0
	DECLARE @ProcName NVARCHAR(50)
	DECLARE @StepName NVARCHAR(50)

	DECLARE  @ErrorMsg		NVARCHAR(MAX)
	DECLARE  @ErrorNum		INTEGER
	DECLARE  @ErrorSeverity	 NVARCHAR(255)
	DECLARE  @ErrorState NVARCHAR(255)

	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SET @ProcName = 'Reference.TOC_Upsert'

	SET @StepName = 'Insert/Update TOC reference information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert/Update TOC reference information start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		MERGE Reference.TOC AS TRGT
		USING #TOC AS SRC
		ON TRGT.ShortCode = SRC.ShortCode
		WHEN NOT MATCHED THEN
		INSERT ([Name],[CreatedDate],[CreatedBy],[LastModifiedDate],[LastModifiedBy]
		        ,[ArchivedInd],[InformationSourceID],[ShortCode])
		VALUES ([Name], @now, @userid, @now, @userid, 0, InformationSourceID, [ShortCode])
		WHEN MATCHED 
			AND (ISNULL(TRGT.[Name],'0') <> ISNULL(SRC.[Name],'0'))
			THEN 
			UPDATE 
			SET	TRGT.[Name] = SRC.[Name]
			    ,TRGT.LastModifiedDate = GETDATE();
    
		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert/Update TOC reference information finish'
							,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	-- End auditting
	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS END'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid, @PrintToScreen=@DebugPrint

    RETURN
END
GO

