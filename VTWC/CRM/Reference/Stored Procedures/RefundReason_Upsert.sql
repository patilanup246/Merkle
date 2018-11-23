﻿/*===========================================================================================
Name:			Reference.RefundReason_Upsert
Purpose:		Insert/Update refund reason reference data into table Reference.RefundReason
Parameters:		@userid - The key for the user executing the proc	
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-30	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Reference.RefundReason_Upsert
=================================================================================================*/

CREATE PROCEDURE [Reference].[RefundReason_Upsert]
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

	SET @ProcName = 'Reference.RefundReason_Upsert'

	SET @StepName = 'Insert/Update refund reason reference information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert/Update refund reason reference information start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		MERGE Reference.RefundReasonCode AS TRGT
		USING #RefundReason AS SRC
		ON TRGT.Code = SRC.Code
		WHEN NOT MATCHED THEN
		INSERT ([Code], [Name],[CreatedDate],[CreatedBy],[LastModifiedDate],[LastModifiedBy]
		        ,[ArchivedInd],[InformationSourceID], SourceCreatedDate, SourceModifiedDate
				,ValidityStartDate, ValidityEndDate)
		VALUES ([Code], [Name], @now, @userid, @now, @userid, 0, InformationSourceID, @now, @now
				,@now, @now)
		WHEN MATCHED 
			AND (ISNULL(TRGT.[Name],'0') <> ISNULL(SRC.[Name],'0'))
			THEN 
			UPDATE 
			SET	TRGT.[Name] = SRC.[Name]
			    ,TRGT.LastModifiedDate = GETDATE()
				,TRGT.SourceModifiedDate = GETDATE();
    
		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert/Update TOC refund reason information finish'
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

