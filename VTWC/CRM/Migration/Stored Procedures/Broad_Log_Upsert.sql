/*===========================================================================================
Name:			Migration.Broad_Log_Upsert
Purpose:		Insert/Update BroadLog information into table Migration.broad_log.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-10	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Migration.Broad_Log_Upsert
=================================================================================================*/

  CREATE PROCEDURE [Migration].[Broad_Log_Upsert] 
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

	SET @ProcName = 'Migration.Broad_Log_Upsert'
   
    SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid

    SET @StepName = 'Operations.DataImportDetail_Update'
	BEGIN TRY		

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

	SET @StepName = 'Insert/Update broadlog information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert/Update broadlog information'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		MERGE Migration.broad_log AS TRGT
		USING (SELECT * FROM PreProcessing.broad_log
			   WHERE DataImportDetailID = @DataImportDetailID
			   AND ProcessedInd = 0
			  ) AS SRC
		ON TRGT.delivery_log_id		= SRC.delivery_log_id
		WHEN NOT MATCHED THEN
		-- Inserting new broad_log information 
		INSERT (delivery_log_id,tcs_customer_id, delivery_id, campaign_id, ttl_segment, cell_code
				,vt_segment_code, control_population, seed, delivery_label, status
				,reason, error_description, campaign_label, category, sent_date
				,program, folder, last_modified, date_loaded, [created_extract_number]
				,[modified_extract_number])
		VALUES
				(SRC.delivery_log_id,SRC.tcs_customer_id, SRC.delivery_id, SRC.campaign_id, SRC.ttl_segment, SRC.cell_code
				,SRC.vt_segment_code, SRC.control_population, SRC.seed, SRC.delivery_label, SRC.status
				,SRC.reason, SRC.error_discription, SRC.campaign_label, SRC.category, SRC.sent_date
				,SRC.program, SRC.folder, SRC.last_modified, SRC.CreatedDateETL, @DataImportDetailID
				,@DataImportDetailID)
		WHEN MATCHED 
		      AND TRGT.last_modified < SRC.last_modified
			--AND (
			--		ISNULL(TRGT.tcs_customer_id,0) <> ISNULL(SRC.tcs_customer_id,0)
			--		OR ISNULL(TRGT.delivery_id,0) <> ISNULL(SRC.delivery_id,0)
			--		OR ISNULL(TRGT.campaign_id,0) <> ISNULL(SRC.campaign_id,0)
			--		OR ISNULL(TRGT.ttl_segment,'0') <> ISNULL(SRC.ttl_segment,'0')
			--		OR ISNULL(TRGT.cell_code,'0') <> ISNULL(SRC.cell_code,'0')
			--		OR ISNULL(TRGT.vt_segment_code,'0') <> ISNULL(SRC.vt_segment_code,'0')
			--		OR ISNULL(TRGT.control_population,0) <> ISNULL(SRC.control_population,0)
			--		OR ISNULL(TRGT.seed,0) <> ISNULL(SRC.seed,0)
			--		OR ISNULL(TRGT.delivery_label,'0') <> ISNULL(SRC.delivery_label,'0')
			--		OR ISNULL(TRGT.status,'0') <> ISNULL(SRC.status,'0')
			--		OR ISNULL(TRGT.reason,'0') <> ISNULL(SRC.reason,'0')
			--		OR ISNULL(TRGT.error_discription,'0') <> ISNULL(SRC.error_discription,'0')
			--		OR ISNULL(TRGT.campaign_label,'0') <> ISNULL(SRC.campaign_label,'0')
			--		OR ISNULL(TRGT.category,'0') <> ISNULL(SRC.category,'0')
			--		OR ISNULL(TRGT.sent_date,'19000101') <> ISNULL(SRC.sent_date,'19000101')
			--		OR ISNULL(TRGT.program,'0') <> ISNULL(SRC.program,'0')
			--		OR ISNULL(TRGT.folder,'0') <> ISNULL(SRC.folder,'0')
			--		OR ISNULL(TRGT.last_modified,'19000101') <> ISNULL(SRC.last_modified,'19000101')
			--		OR ISNULL(TRGT.date_loaded,'19000101') <> ISNULL(SRC.date_loaded,'19000101')
			--	)
			THEN
				-- Update existing broad_log information 
				UPDATE 
				SET TRGT.tcs_customer_id = SRC.tcs_customer_id
					, TRGT.delivery_id = SRC.delivery_id
					, TRGT.campaign_id = SRC.campaign_id
					, TRGT.ttl_segment = SRC.ttl_segment
					, TRGT.cell_code = SRC.cell_code
					, TRGT.vt_segment_code = SRC.vt_segment_code
					, TRGT.control_population = SRC.control_population
					, TRGT.seed = SRC.seed
					, TRGT.delivery_label = SRC.delivery_label
					, TRGT.status = SRC.status
					, TRGT.reason = SRC.reason
					, TRGT.error_description = SRC.error_discription
					, TRGT.campaign_label = SRC.campaign_label
					, TRGT.category = SRC.category
					, TRGT.sent_date = SRC.sent_date
					, TRGT.program = SRC.program
					, TRGT.folder = SRC.folder
					, TRGT.last_modified = SRC.last_modified
					, TRGT.date_loaded = SRC.CreatedDateETL
					, TRGT.modified_extract_number = @DataImportDetailID;

		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert/Update broadlog information'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing broad_log table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE B
	SET  B.ProcessedInd = 1
	FROM [PreProcessing].[broad_log] AS B 
	INNER JOIN  [Migration].[broad_log] AS BL ON B.delivery_log_id = BL.delivery_log_id
	AND   B.DataImportDetailID = @dataimportdetailid

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing broad_log table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.broad_log
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.broad_log
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

