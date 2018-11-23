/*===========================================================================================
Name:			Migration.Tracking_Logs_Upsert
Purpose:		Insert/Update tracking_log information into table Migration.tracking_logs.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-10	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Migration.Tracking_Logs_Upsert
=================================================================================================*/

  CREATE PROCEDURE [Migration].[Tracking_Logs_Upsert] 
    @userid                INTEGER = 0,
	@dataimportdetailid    INTEGER, 
	@DebugPrint			   INTEGER = 0,
	@PkgExecKey			   INTEGER = -1,
	@DebugRecordset		   INTEGER = 0
  ----------------------------------------
  AS 
  BEGIN

  
   SET NOCOUNT ON;

	DECLARE @now                    DATETIME = GETDATE()
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @importfilename			NVARCHAR(256)


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

	SET @ProcName = 'Migration.Tracking_Logs_Upsert'
   
   SET @StepName = 'Operations.DataImportDetail_Update'

   SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid

	BEGIN TRY
		SET @StepName = 'Operations.DataImportDetail_Update'

		EXEC uspSSISProcStepStart @ProcName, @StepName

		EXEC [Operations].[DataImportDetail_Update] @userid                 = @userid,
													@dataimportdetailid     = @dataimportdetailid,
													@operationalstatusname  = 'Processing',
													@importfilename         = @importfilename,
													@starttimepreprocessing = NULL,
													@endtimepreprocessing   = NULL,
													@starttimeimport        = @now,
													@endtimeimport          = NULL,
													@totalcountimport       = NULL,
													@successcountimport     = NULL,
													@errorcountimport       = NULL
		EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;

	SET @StepName = 'Insert/Update tracking_logs information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert/Update tracking_logs information'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		MERGE Migration.tracking_logs AS TRGT
		USING (SELECT * FROM PreProcessing.tracking_logs
			   WHERE DataImportDetailID = @DataImportDetailID
			   AND ProcessedInd = 0
			  ) AS SRC
		ON TRGT.log_id	= SRC.log_id
		AND TRGT.tcs_customer_id	= SRC.tcs_customer_id
		AND TRGT.delivery_id	= SRC.delivery_id
		AND TRGT.campaign_id	= SRC.campaign_id
		WHEN NOT MATCHED THEN
		-- Inserting new tracking_logs information 
		INSERT (log_id, tcs_customer_id, delivery_id, campaign_id, log_date, category_url
				,label_url, url, response_type, operating_system_icon, operating_system_family
				,device_browser, delivery_label, campaign_label, sent_date, date_loaded
				,last_modified, [created_extract_number], [modified_extract_number])
		VALUES
				(SRC.log_id,SRC.tcs_customer_id, SRC.delivery_id, SRC.campaign_id, SRC.log_date, SRC.category_url
				,SRC.label_url, SRC.url, SRC.response_type, SRC.operating_system_icon, SRC.operating_system_family
				,SRC.device_browser, SRC.delivery_label, SRC.campaign_label, SRC.sent_date, SRC.CreatedDateETL
				,SRC.LastModifiedDateETL, @DataImportDetailID, @DataImportDetailID)
		WHEN MATCHED 
			AND (
					ISNULL(TRGT.log_date,'19000101') <> ISNULL(SRC.log_date,'19000101')
					OR ISNULL(TRGT.category_url,'0') <> ISNULL(SRC.category_url,'0')
					OR ISNULL(TRGT.label_url,'0') <> ISNULL(SRC.label_url,'0')
					OR ISNULL(TRGT.url,'0') <> ISNULL(SRC.url,'0')
					OR ISNULL(TRGT.response_type,'0') <> ISNULL(SRC.response_type,'0')
					OR ISNULL(TRGT.operating_system_icon,'0') <> ISNULL(SRC.operating_system_icon,'0')
					OR ISNULL(TRGT.operating_system_family,'0') <> ISNULL(SRC.operating_system_family,'0')
					OR ISNULL(TRGT.device_browser,'0') <> ISNULL(SRC.device_browser,'0')
					OR ISNULL(TRGT.delivery_label,'0') <> ISNULL(SRC.delivery_label,'0')
					OR ISNULL(TRGT.campaign_label,'0') <> ISNULL(SRC.campaign_label,'0')
					OR ISNULL(TRGT.sent_date,'19000101') <> ISNULL(SRC.sent_date,'19000101')
					OR ISNULL(TRGT.date_loaded,'19000101') <> ISNULL(SRC.CreatedDateETL,'19000101')
					OR ISNULL(TRGT.last_modified,'19000101') <> ISNULL(SRC.LastModifiedDateETL,'19000101')
				)
			THEN
				-- Update existing tracking_logs information 
				UPDATE 
				SET TRGT.log_date = SRC.log_date
					, TRGT.category_url = SRC.category_url
					, TRGT.label_url = SRC.label_url
					, TRGT.url = SRC.url
					, TRGT.response_type = SRC.response_type
					, TRGT.operating_system_icon = SRC.operating_system_icon
					, TRGT.operating_system_family = SRC.operating_system_family
					, TRGT.device_browser = SRC.device_browser
					, TRGT.delivery_label = SRC.delivery_label
					, TRGT.campaign_label = SRC.campaign_label
					, TRGT.sent_date = SRC.sent_date
					, TRGT.date_loaded = SRC.CreatedDateETL
					, TRGT.last_modified = SRC.LastModifiedDateETL
					, TRGT.modified_extract_number = @DataImportDetailID;

		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert/Update tracking_logs information'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing tracking_logs table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE PTL
	SET  PTL.ProcessedInd = 1
	FROM [PreProcessing].[tracking_logs] AS PTL
	INNER JOIN  [Migration].[tracking_logs] AS MTL 
		ON PTL.log_id = MTL.log_id
		AND PTL.tcs_customer_id = MTL.tcs_customer_id
		AND PTL.delivery_id = MTL.delivery_id
		AND PTL.campaign_id = MTL.campaign_id
	AND   PTL.DataImportDetailID = @dataimportdetailid


	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing tracking_logs table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.tracking_logs
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.tracking_logs
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

	SET @StepName = 'Operations.DataImportDetail_Update'
	BEGIN TRY
		EXEC uspSSISProcStepStart @ProcName, @StepName
		EXEC [Operations].[DataImportDetail_Update] @userid						= @userid,
													@dataimportdetailid			= @dataimportdetailid,
													@operationalstatusname		= 'Completed',
													@importfilename             = @importfilename,
													@starttimepreprocessing     = NULL,
													@endtimepreprocessing		= NULL,
													@starttimeimport			= NULL,
													@endtimeimport				= @now,
													@totalcountimport			= @recordcount,
													@successcountimport			= @successcountimport,
													@errorcountimport			= @errorcountimport
		EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;

	-- End auditting
	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS END'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid, @PrintToScreen=@DebugPrint
 END
GO

