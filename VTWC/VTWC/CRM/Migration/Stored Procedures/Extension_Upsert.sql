/*===========================================================================================
Name:			Migration.Extension_Upsert
Purpose:		Insert/Update extension information into table Migration.extension.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-10	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Migration.Extension_Upsert
=================================================================================================*/

  CREATE PROCEDURE [Migration].[Extension_Upsert] 
    @userid                INTEGER = 0,
	@dataimportdetailid    INTEGER, 
	@DebugPrint			   INTEGER = 0,
	@PkgExecKey			   INTEGER = -1,
	@DebugRecordset		   INTEGER = 0
  ----------------------------------------
  AS 
  BEGIN
  
   SET NOCOUNT ON;
    SET DATEFORMAT YMD
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

	SET @ProcName = 'Migration.Extension_Upsert'
   
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

	SET @StepName = 'Insert/Update extension information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert/Update extension information'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		MERGE Migration.extension AS TRGT
		USING (SELECT * FROM PreProcessing.extension
			   WHERE DataImportDetailID = @DataImportDetailID
			   AND ProcessedInd = 0
			  ) AS SRC
		ON TRGT.tcs_customer_id	= SRC.tcs_customer_id
		WHEN NOT MATCHED THEN
		-- Inserting new extension information 
		INSERT (tcs_customer_id, current_segment_vt_customer_extension, customer_form_frequency_vt_customer_extension
				,customer_form_preferred_station_vt_customer_extension, customer_form_purchasing_tickets_vt_customer_extension
				,customer_form_railcard_vt_customer_extension, nursery_added_date_vt_customer_extension, nursery_control_vt_customer_extension
				,nursery_dropout_date_vt_customer_extension, nursery_status_vt_customer_extension, nursery_stream_vt_customer_extension
				,nursery_travel_date_vt_customer_extension, pin_code_vt_customer_extension, pin_expiry_vt_customer_extension
				,propensity_to_buy_vt_customer_extension, reengagement_flag_vt_customer_extension, salutation_vt_customer_extension
				,segment_m1_vt_customer_extension, segment_m2_vt_customer_extension, segment_m3_vt_customer_extension
				,segment_m4_vt_customer_extension, segment_m5_vt_customer_extension, segment_m6_vt_customer_extension
				,segment_m7_vt_customer_extension, segment_m8_vt_customer_extension, segment_m9_vt_customer_extension
				,segment_m10_vt_customer_extension, segment_m11_vt_customer_extension, segment_m12_vt_customer_extension
				,softoptinrof_vt_customer_extension, traveller_expiry_vt_customer_extension, traveller_from_vt_customer_extension
				,traveller_no_vt_customer_extension, traveller_salutation_vt_customer_extension, traveller_status_vt_customer_extension
				,virghin_insight_segment_vt_customer_extension, vt_perm_control_vt_customer_extension, vt_red_matched_date_vt_customer_extension
				,vt_red_segment_vt_customer_extension, date_loaded, last_modified, [created_extract_number], [modified_extract_number])
		VALUES
				(SRC.tcs_customer_id, SRC.current_segment_vt_customer_extension, SRC.customer_form_frequency_vt_customer_extension
				,SRC.customer_form_preferred_station_vt_customer_extension, SRC.customer_form_purchasing_tickets_vt_customer_extension
				,SRC.customer_form_railcard_vt_customer_extension, SRC.nursery_added_date_vt_customer_extension, SRC.nursery_control_vt_customer_extension
				,SRC.nursery_dropout_date_vt_customer_extension, SRC.nursery_status_vt_customer_extension, SRC.nursery_stream_vt_customer_extension
				,SRC.nursery_travel_date_vt_customer_extension, SRC.pin_code_vt_customer_extension, SRC.pin_expiry_vt_customer_extension
				,SRC.propensity_to_buy_vt_customer_extension, SRC.reengagement_flag_vt_customer_extension, SRC.salutation_vt_customer_extension
				,SRC.segment_m1_vt_customer_extension, SRC.segment_m2_vt_customer_extension, SRC.segment_m3_vt_customer_extension
				,SRC.segment_m4_vt_customer_extension, SRC.segment_m5_vt_customer_extension, SRC.segment_m6_vt_customer_extension
				,SRC.segment_m7_vt_customer_extension, SRC.segment_m8_vt_customer_extension, SRC.segment_m9_vt_customer_extension
				,SRC.segment_m10_vt_customer_extension, SRC.segment_m11_vt_customer_extension, SRC.segment_m12_vt_customer_extension
				,SRC.softoptinrof_vt_customer_extension, SRC.traveller_expiry_vt_customer_extension, SRC.traveller_from_vt_customer_extension
				,SRC.traveller_no_vt_customer_extension, SRC.traveller_salutation_vt_customer_extension, SRC.traveller_status_vt_customer_extension
				,SRC.virghin_insight_segment_vt_customer_extension, SRC.vt_perm_control_vt_customer_extension, SRC.vt_red_matched_date_vt_customer_extension
				,SRC.vt_red_segment_vt_customer_extension, SRC.CreatedDateETL, SRC.LastModifiedDateETL, @DataImportDetailID, @DataImportDetailID)
		WHEN MATCHED 
			AND (
					ISNULL(TRGT.current_segment_vt_customer_extension,'0') <> ISNULL(SRC.current_segment_vt_customer_extension,'0')
					OR ISNULL(TRGT.customer_form_frequency_vt_customer_extension,'0') <> ISNULL(SRC.customer_form_frequency_vt_customer_extension,'0')
					OR ISNULL(TRGT.customer_form_preferred_station_vt_customer_extension,'0') <> ISNULL(SRC.customer_form_preferred_station_vt_customer_extension,'0')
					OR ISNULL(TRGT.customer_form_purchasing_tickets_vt_customer_extension,'0') <> ISNULL(SRC.customer_form_purchasing_tickets_vt_customer_extension,'0')
					OR ISNULL(TRGT.customer_form_railcard_vt_customer_extension,'0') <> ISNULL(SRC.customer_form_railcard_vt_customer_extension,'0')
					OR ISNULL(TRGT.nursery_added_date_vt_customer_extension,'0') <> ISNULL(SRC.nursery_added_date_vt_customer_extension,'0')
					OR ISNULL(TRGT.nursery_control_vt_customer_extension,'0') <> ISNULL(SRC.nursery_control_vt_customer_extension,'0')
					OR ISNULL(TRGT.nursery_dropout_date_vt_customer_extension,'0') <> ISNULL(SRC.nursery_dropout_date_vt_customer_extension,'0')
					OR ISNULL(TRGT.nursery_status_vt_customer_extension,'0') <> ISNULL(SRC.nursery_status_vt_customer_extension,'0')
					OR ISNULL(TRGT.nursery_stream_vt_customer_extension,'0') <> ISNULL(SRC.nursery_stream_vt_customer_extension,'0')
					OR ISNULL(TRGT.nursery_travel_date_vt_customer_extension,'19000101') <> ISNULL(SRC.nursery_travel_date_vt_customer_extension,'19000101')
					OR ISNULL(TRGT.pin_code_vt_customer_extension,'0') <> ISNULL(SRC.pin_code_vt_customer_extension,'0')
					OR ISNULL(TRGT.pin_expiry_vt_customer_extension,'0') <> ISNULL(SRC.pin_expiry_vt_customer_extension,'0')
					OR ISNULL(TRGT.propensity_to_buy_vt_customer_extension,'0') <> ISNULL(SRC.propensity_to_buy_vt_customer_extension,'0')
					OR ISNULL(TRGT.reengagement_flag_vt_customer_extension,'0') <> ISNULL(SRC.reengagement_flag_vt_customer_extension,'0')
					OR ISNULL(TRGT.salutation_vt_customer_extension,'0') <> ISNULL(SRC.salutation_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m1_vt_customer_extension,'0') <> ISNULL(SRC.segment_m1_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m2_vt_customer_extension,'0') <> ISNULL(SRC.segment_m2_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m3_vt_customer_extension,'0') <> ISNULL(SRC.segment_m3_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m4_vt_customer_extension,'0') <> ISNULL(SRC.segment_m4_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m5_vt_customer_extension,'0') <> ISNULL(SRC.segment_m5_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m6_vt_customer_extension,'0') <> ISNULL(SRC.segment_m6_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m7_vt_customer_extension,'0') <> ISNULL(SRC.segment_m7_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m8_vt_customer_extension,'0') <> ISNULL(SRC.segment_m8_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m9_vt_customer_extension,'0') <> ISNULL(SRC.segment_m9_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m10_vt_customer_extension,'0') <> ISNULL(SRC.segment_m10_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m11_vt_customer_extension,'0') <> ISNULL(SRC.segment_m11_vt_customer_extension,'0')
					OR ISNULL(TRGT.segment_m12_vt_customer_extension,'0') <> ISNULL(SRC.segment_m12_vt_customer_extension,'0')
					OR ISNULL(TRGT.softoptinrof_vt_customer_extension,'0') <> ISNULL(SRC.softoptinrof_vt_customer_extension,'0')
					OR ISNULL(TRGT.traveller_expiry_vt_customer_extension,'19000101') <> ISNULL(SRC.traveller_expiry_vt_customer_extension,'19000101')
					OR ISNULL(TRGT.traveller_from_vt_customer_extension,'19000101') <> ISNULL(SRC.traveller_from_vt_customer_extension,'19000101')
					OR ISNULL(TRGT.traveller_no_vt_customer_extension,0) <> ISNULL(SRC.traveller_no_vt_customer_extension,0)
					OR ISNULL(TRGT.traveller_salutation_vt_customer_extension,'0') <> ISNULL(SRC.traveller_salutation_vt_customer_extension,'0')
					OR ISNULL(TRGT.traveller_status_vt_customer_extension,'0') <> ISNULL(SRC.traveller_status_vt_customer_extension,'0')
					OR ISNULL(TRGT.virghin_insight_segment_vt_customer_extension,0) <> ISNULL(SRC.virghin_insight_segment_vt_customer_extension,0)
					OR ISNULL(TRGT.vt_perm_control_vt_customer_extension,'19000101') <> ISNULL(SRC.vt_perm_control_vt_customer_extension,'19000101')
					OR ISNULL(TRGT.vt_red_matched_date_vt_customer_extension,'19000101') <> ISNULL(SRC.vt_red_matched_date_vt_customer_extension,'19000101')
					OR ISNULL(TRGT.vt_red_segment_vt_customer_extension,0) <> ISNULL(SRC.vt_red_segment_vt_customer_extension,0)
					OR ISNULL(TRGT.date_loaded,'19000101') <> ISNULL(SRC.CreatedDateETL,'19000101')
					OR ISNULL(TRGT.last_modified,'19000101') <> ISNULL(SRC.LastModifiedDateETL,'19000101')
				)
			THEN
				UPDATE 
				SET TRGT.current_segment_vt_customer_extension = SRC.current_segment_vt_customer_extension
					,TRGT.customer_form_frequency_vt_customer_extension = SRC.customer_form_frequency_vt_customer_extension
					,TRGT.customer_form_preferred_station_vt_customer_extension = SRC.customer_form_preferred_station_vt_customer_extension
					,TRGT.customer_form_purchasing_tickets_vt_customer_extension = SRC.customer_form_purchasing_tickets_vt_customer_extension
					,TRGT.customer_form_railcard_vt_customer_extension = SRC.customer_form_railcard_vt_customer_extension
					,TRGT.nursery_added_date_vt_customer_extension = SRC.nursery_added_date_vt_customer_extension
					,TRGT.nursery_control_vt_customer_extension = SRC.nursery_control_vt_customer_extension
					,TRGT.nursery_dropout_date_vt_customer_extension = SRC.nursery_dropout_date_vt_customer_extension
					,TRGT.nursery_status_vt_customer_extension = SRC.nursery_status_vt_customer_extension
					,TRGT.nursery_stream_vt_customer_extension = SRC.nursery_stream_vt_customer_extension
					,TRGT.nursery_travel_date_vt_customer_extension = SRC.nursery_travel_date_vt_customer_extension
					,TRGT.pin_code_vt_customer_extension = SRC.pin_code_vt_customer_extension
					,TRGT.pin_expiry_vt_customer_extension = SRC.pin_expiry_vt_customer_extension
					,TRGT.propensity_to_buy_vt_customer_extension = SRC.propensity_to_buy_vt_customer_extension
					,TRGT.reengagement_flag_vt_customer_extension = SRC.reengagement_flag_vt_customer_extension
					,TRGT.salutation_vt_customer_extension = SRC.salutation_vt_customer_extension
					,TRGT.segment_m1_vt_customer_extension = SRC.segment_m1_vt_customer_extension
					,TRGT.segment_m2_vt_customer_extension = SRC.segment_m2_vt_customer_extension
					,TRGT.segment_m3_vt_customer_extension = SRC.segment_m3_vt_customer_extension
					,TRGT.segment_m4_vt_customer_extension = SRC.segment_m4_vt_customer_extension
					,TRGT.segment_m5_vt_customer_extension = SRC.segment_m5_vt_customer_extension
					,TRGT.segment_m6_vt_customer_extension = SRC.segment_m6_vt_customer_extension
					,TRGT.segment_m7_vt_customer_extension = SRC.segment_m7_vt_customer_extension
					,TRGT.segment_m8_vt_customer_extension = SRC.segment_m8_vt_customer_extension
					,TRGT.segment_m9_vt_customer_extension = SRC.segment_m9_vt_customer_extension
					,TRGT.segment_m10_vt_customer_extension = SRC.segment_m10_vt_customer_extension
					,TRGT.segment_m11_vt_customer_extension = SRC.segment_m11_vt_customer_extension
					,TRGT.segment_m12_vt_customer_extension = SRC.segment_m12_vt_customer_extension
					,TRGT.softoptinrof_vt_customer_extension = SRC.softoptinrof_vt_customer_extension
					,TRGT.traveller_expiry_vt_customer_extension = SRC.traveller_expiry_vt_customer_extension
					,TRGT.traveller_from_vt_customer_extension = SRC.traveller_from_vt_customer_extension
					,TRGT.traveller_no_vt_customer_extension = SRC.traveller_no_vt_customer_extension
					,TRGT.traveller_salutation_vt_customer_extension = SRC.traveller_salutation_vt_customer_extension
					,TRGT.traveller_status_vt_customer_extension = SRC.traveller_status_vt_customer_extension
					,TRGT.virghin_insight_segment_vt_customer_extension = SRC.virghin_insight_segment_vt_customer_extension
					,TRGT.vt_perm_control_vt_customer_extension = SRC.vt_perm_control_vt_customer_extension
					,TRGT.vt_red_matched_date_vt_customer_extension = SRC.vt_red_matched_date_vt_customer_extension
					,TRGT.vt_red_segment_vt_customer_extension = SRC.vt_red_segment_vt_customer_extension
					,TRGT.date_loaded = SRC.CreatedDateETL
					,TRGT.last_modified = SRC.LastModifiedDateETL
					,TRGT.modified_extract_number = @DataImportDetailID;

		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert/Update extension information'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing extension table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE PTL
	SET  PTL.ProcessedInd = 1
	FROM [PreProcessing].[extension] AS PTL
	INNER JOIN  [Migration].[extension] AS MTL 
		ON PTL.tcs_customer_id = MTL.tcs_customer_id
	AND   PTL.DataImportDetailID = @dataimportdetailid


	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing extension table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.extension
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.extension
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

