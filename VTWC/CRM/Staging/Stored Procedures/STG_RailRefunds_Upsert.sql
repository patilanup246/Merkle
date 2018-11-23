/*===========================================================================================
Name:			Staging.STG_RailRefunds_Upsert
Purpose:		Insert new/update rail refunds information into table Staging.STG_Refunds.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-30	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Staging.STG_RailRefunds_Upsert
=================================================================================================*/

  CREATE PROCEDURE [Staging].[STG_RailRefunds_Upsert] 
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

   DECLARE @informationsourceid INT 

   DECLARE  @ErrorMsg		NVARCHAR(MAX)
   DECLARE  @ErrorNum		INTEGER
   DECLARE  @ErrorSeverity	 NVARCHAR(255)
   DECLARE  @ErrorState NVARCHAR(255)

	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SET @ProcName = 'PreProcessing.TOCPlus_RailRefunds_Insert'
   
    SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid

	SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'TrainLine'

	SET @StepName = 'Check if information source reference values are populated'

	IF @informationsourceid                 IS NULL
	BEGIN
	    SET @ErrorMsg = 'No or invalid reference information.' +
		                  ' @informationsourceid =  '                + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') 
	    
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey

        RETURN
    END

	IF OBJECT_ID(N'tempdb..#RefundType') IS NOT NULL
	DROP TABLE #RefundType
	SELECT RefundType AS [Name], @InformationSourceID AS InformationSourceID
	INTO #RefundType
	FROM PreProcessing.TOCPLUS_Refunds
	WHERE DataImportDetailID = @DataImportDetailID
	GROUP BY RefundType


	EXEC [Reference].[RefundType_Upsert]

	IF OBJECT_ID(N'tempdb..#RefundReason') IS NOT NULL
	DROP TABLE #RefundReason
	SELECT RefundReason AS [Code], RefundReasonDesc AS [Name], @InformationSourceID AS InformationSourceID
	INTO #RefundReason
	FROM PreProcessing.TOCPLUS_Refunds
	WHERE DataImportDetailID = @DataImportDetailID
	GROUP BY RefundReason, RefundReasonDesc

	EXEC [Reference].[RefundReason_Upsert]

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

	

	SET @StepName = 'Insert/Update rail refunds information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert/Update rail refunds information start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		IF OBJECT_ID(N'tempdb..#RailRefunds_WithDups') IS NOT NULL
		DROP TABLE #RailRefunds_WithDups
		SELECT SD.CustomerID, SD.SalesTransactionID, R.TcsBookingID AS ExtReference, R.ArRefArrivalId AS RefundNumber
				,RT.RefundTypeID, R.Percentage, R.GrossRefund, R.AdminFee, R.RefundAmount
				,R.DatamartCreateDate, R.DatamartUpdateDate, R.RequestedDate, R.RefundedIssuedDate
				,RRC.RefundReasonCodeID, DatamartCreateDate AS SourceCreatedDate, DatamartUpdateDate AS SourceModifiedDate
				,TOCRefundsID
		INTO #RailRefunds_WithDups
		FROM Staging.STG_SalesDetail AS SD
		INNER JOIN Staging.STG_Journey AS J
			ON SD.SalesDetailID = J.SalesDetailID
		INNER JOIN (SELECT *
					FROM PreProcessing.TOCPLUS_Refunds 
					WHERE  DataImportDetailID = @dataimportdetailid
					AND    ProcessedInd = 0
					) AS R
			ON J.TCSBookingID = R.TcsBookingID 
		LEFT JOIN Reference.RefundType AS RT
			ON R.RefundType = RT.Name 
		LEFT JOIN Reference.RefundReasonCode AS RRC 
			ON R.RefundReason = RRC.Code 

		IF OBJECT_ID(N'tempdb..#RailRefunds') IS NOT NULL
		DROP TABLE #RailRefunds
		SELECT CustomerID, SalesTransactionID, ExtReference,  RefundNumber
				,RefundTypeID, Percentage, GrossRefund, AdminFee, RefundAmount
				,DatamartCreateDate, DatamartUpdateDate, RequestedDate, RefundedIssuedDate
				,RefundReasonCodeID, SourceCreatedDate, SourceModifiedDate
		INTO #RailRefunds
		FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY ExtReference, RefundNumber ORDER BY ExtReference, RefundNumber, TOCRefundsID DESC) AS RANKING
			   ,*
		FROM  #RailRefunds_WithDups) AS SQ
		WHERE RANKING=1

		MERGE Staging.STG_Refund AS TRGT
		USING #RailRefunds AS SRC
		ON TRGT.ExtReference = SRC.ExtReference
		AND TRGT.RefundNumber = SRC.RefundNumber
		WHEN NOT MATCHED THEN
		-- Inserting new sales detail information 
		INSERT ([CreatedDate],[CreatedBy], [CreatedExtractNumber],[LastModifiedDate],[LastModifiedBy], [LastModifiedExtractNumber]
				,[ArchivedInd],[SourceCreatedDate], [SourceModifiedDate],[InformationSourceID],[CustomerID],[SalesTransactionID]
				,[RefundNumber],[RefundTypeID], [Percentage], [GrossRefund], [AdminChargeAmount], [RefundAmount]
				,[RequestedDate], [RefundDate], [RefundReasonCodeID], [ExtReference], RetailChannelID)
		VALUES
				(@now, 0, @dataimportdetailid, @now, 0, @dataimportdetailid, 0, SourceCreatedDate, SourceModifiedDate, @informationsourceid
				,CustomerID, SalesTransactionID, RefundNumber, RefundTypeID, Percentage, GrossRefund, AdminFee
				,RefundAmount, RequestedDate, RefundedIssuedDate, RefundReasonCodeID, ExtReference, -1)
		WHEN MATCHED 
			AND SRC.SourceModifiedDate > TRGT.SourceModifiedDate
			THEN 
				-- Update existing broad_log information 
				UPDATE 
				SET TRGT.LastModifiedDate = @now
					, TRGT.LastModifiedExtractNumber = @dataimportdetailid
					, TRGT.SourceCreatedDate = SRC.SourceCreatedDate
					, TRGT.SourceModifiedDate = SRC.SourceModifiedDate
					, TRGT.CustomerID = SRC.CustomerID
					, TRGT.SalesTransactionID = SRC.SalesTransactionID
					--, TRGT.RefundNumber = SRC.RefundNumber
					, TRGT.RefundTypeID = SRC.RefundTypeID
					, TRGT.Percentage = SRC.Percentage
					, TRGT.GrossRefund = SRC.GrossRefund
					, TRGT.AdminChargeAmount = SRC.AdminFee
					, TRGT.RefundAmount = SRC.RefundAmount
					, TRGT.RequestedDate = SRC.RequestedDate
					, TRGT.RefundDate = SRC.RefundedIssuedDate
					, TRGT.RefundReasonCodeID = SRC.RefundReasonCodeID;



		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert rail refunds information finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing rail refunds table start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE B
	SET  B.ProcessedInd = 1
		,B.LastModifiedDateETL = GETDATE()
	FROM [PreProcessing].TOCPLUS_Refunds AS B 
	INNER JOIN  Staging.STG_Refund AS BL ON B.TcsBookingID = BL.ExtReference
	AND   B.DataImportDetailID = @dataimportdetailid

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing rail refunds table finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Refunds
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Refunds
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
