/*===========================================================================================
Name:			Migration.Delivery_Upsert
Purpose:		Insert/Update Delivery information into table Migration.delivery.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-10	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Migration.Delivery_Upsert
=================================================================================================*/

  CREATE PROCEDURE [Migration].[Delivery_Upsert] 
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

	SET @ProcName = 'Migration.Delivery_Upsert'
   
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

	SET @StepName = 'Insert/Update delivery information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert/Update delivery information'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		MERGE Migration.delivery AS TRGT
		USING (SELECT * FROM PreProcessing.delivery
			   WHERE DataImportDetailID = @DataImportDetailID
			   AND ProcessedInd = 0
			  ) AS SRC
		ON TRGT.primary_key	= SRC.primary_key
		WHEN NOT MATCHED THEN
		-- Inserting new delivery information 
		INSERT (primary_key,category_campaign, date_only_contact_date, delivered, opt_out, refused
				,sent_success, total_count_of_opens, total_number_of_clicks, unique_clicks_persons_who_have_clicked
				,unique_opens_recipients_who_have_opened, campaign_name, date_loaded, last_modified, [created_extract_number]
				,[modified_extract_number])
		VALUES
				(SRC.primary_key,SRC.category_campaign, SRC.date_only_contact_date, SRC.delivered, SRC.opt_out, SRC.refused
				,SRC.sent_success, SRC.total_count_of_opens, SRC.total_number_of_clicks, SRC.unique_clicks_persons_who_have_clicked
				,SRC.unique_opens_recipients_who_have_opened, SRC.campaign_name, SRC.CreatedDateETL, SRC.LastModifiedDateETL, @DataImportDetailID
				,@DataImportDetailID)
		WHEN MATCHED 
			AND (
					ISNULL(TRGT.category_campaign,'0') <> ISNULL(SRC.category_campaign,'0')
					OR ISNULL(TRGT.date_only_contact_date,'19000101') <> ISNULL(SRC.date_only_contact_date,'19000101')
					OR ISNULL(TRGT.delivered,0) <> ISNULL(SRC.delivered,0)
					OR ISNULL(TRGT.opt_out,'0') <> ISNULL(SRC.opt_out,'0')
					OR ISNULL(TRGT.refused,'0') <> ISNULL(SRC.refused,'0')
					OR ISNULL(TRGT.sent_success,'0') <> ISNULL(SRC.sent_success,'0')
					OR ISNULL(TRGT.total_count_of_opens,0) <> ISNULL(SRC.total_count_of_opens,0)
					OR ISNULL(TRGT.total_number_of_clicks,0) <> ISNULL(SRC.total_number_of_clicks,0)
					OR ISNULL(TRGT.unique_clicks_persons_who_have_clicked,'0') <> ISNULL(SRC.unique_clicks_persons_who_have_clicked,'0')
					OR ISNULL(TRGT.unique_opens_recipients_who_have_opened,'0') <> ISNULL(SRC.unique_opens_recipients_who_have_opened,'0')
					OR ISNULL(TRGT.campaign_name,'0') <> ISNULL(SRC.campaign_name,'0')
					OR ISNULL(TRGT.date_loaded,'19000101') <> ISNULL(SRC.CreatedDateETL,'19000101')
					OR ISNULL(TRGT.last_modified,'19000101') <> ISNULL(SRC.LastModifiedDateETL,'19000101')
				)
			THEN
				-- Update existing delivery information 
				UPDATE 
				SET TRGT.category_campaign = SRC.category_campaign
					, TRGT.date_only_contact_date = SRC.date_only_contact_date
					, TRGT.delivered = SRC.delivered
					, TRGT.opt_out = SRC.opt_out
					, TRGT.refused = SRC.refused
					, TRGT.sent_success = SRC.sent_success
					, TRGT.total_count_of_opens = SRC.total_count_of_opens
					, TRGT.total_number_of_clicks = SRC.total_number_of_clicks
					, TRGT.unique_clicks_persons_who_have_clicked = SRC.unique_clicks_persons_who_have_clicked
					, TRGT.unique_opens_recipients_who_have_opened = SRC.unique_opens_recipients_who_have_opened
					, TRGT.campaign_name = SRC.campaign_name
					, TRGT.date_loaded = SRC.CreatedDateETL
					, TRGT.last_modified = SRC.LastModifiedDateETL
					, TRGT.modified_extract_number = @DataImportDetailID;

		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert/Update delivery information'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing delivery table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE PD
	SET  PD.ProcessedInd = 1
	FROM [PreProcessing].[delivery] AS PD
	INNER JOIN  [Migration].[delivery] AS MD ON PD.primary_key = MD.primary_key
	AND   PD.DataImportDetailID = @dataimportdetailid

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing delivery table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.delivery
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.delivery
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

