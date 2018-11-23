/*===========================================================================================
Name:			[Staging].[STG_ADRCash_Insert]
Purpose:		Insert/Update ADR cash information into table Staging.STG_ADRCash.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-09-03	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC [Staging].[STG_ADRCash_Insert]
=================================================================================================*/

  CREATE PROCEDURE [Staging].[STG_ADRCash_Insert]
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

	SET @ProcName = 'PreProcessing.TOCPlus_ADRCash_Insert'
   
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

	

	SET @StepName = 'Insert ADR cash information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert/Update ADR cash information start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		IF OBJECT_ID(N'tempdb..#ADRCash') IS NOT NULL
		DROP TABLE #ADRCash
		SELECT ST.CustomerID, ST.SalesTransactionID, ADR.iTotalDelayMinutes, ADR.sADRGroup, ADR.fRefundAmount
			    ,ADR.sDepartureStation, ADR.sDestinationStation, ADR.dtScheduledDepart, ADR.dtScheduledArrive
				,ADR.dtProcessed, ADR.sVTCaseNumber, ADR.sJourneyReference, ADR.sTransactionId AS ExtReference
				,@InformationSourceID AS InformationSourceID, @dataimportdetailid AS DataImportDetailID
		INTO #ADRCash
		FROM Staging.STG_SalesTransaction AS ST
		INNER JOIN (SELECT  ROW_NUMBER() OVER (PARTITION BY sTransactionId, sTracsTrId ORDER BY sTransactionId, TOCPlus_ADRCashID DESC) AS Ranking
							,*
					FROM PreProcessing.TOCPlus_ADRCash
					WHERE DataImportDetailID = @DataImportDetailID
					AND ProcessedInd = 0) AS ADR
			ON ST.ExtReference = ADR.sTracsTrId
		WHERE Ranking =1 

		MERGE Staging.STG_ADRCash AS TRGT
		USING #ADRCash AS SRC
		ON TRGT.ExtReference = SRC.ExtReference
		AND TRGT.SalesTransactionID = SRC.SalesTransactionID
		WHEN NOT MATCHED THEN
		-- Inserting new ADR cash information 
		INSERT (CustomerID, SalesTransactionID, iTotalDelayMinutes, sADRGroup, fRefundAmount
			    ,sDepartureStation, sDestinationStation, dtScheduledDepart, dtScheduledArrive
				,dtProcessed, sVTCaseNumber, sJourneyReference, ExtReference
				,InformationSourceID, CreatedDate, CreatedBy, CreatedExtractNumber
				,LastModifiedDate, LastModifiedBy, LastModifiedExtractNumber)
		VALUES
				(CustomerID, SalesTransactionID, iTotalDelayMinutes, sADRGroup, fRefundAmount
			    ,sDepartureStation, sDestinationStation, dtScheduledDepart, dtScheduledArrive
				,dtProcessed, sVTCaseNumber, sJourneyReference, ExtReference
				,InformationSourceID, @now, 0, DataImportDetailID
				,@now, 0, DataImportDetailID);
		--WHEN MATCHED 
		--	AND SRC.DateUpdated > TRGT.LastModifiedDate
		--	THEN 
		--		-- Update existing ADR cash information 
		--		UPDATE 
		--		SET   TRGT.LastModifiedDate = @now
		--		    , TRGT.LastModifiedExtractNumber = @DataImportDetailID
		--		    , TRGT.iTotalDelayMinutes = SRC.iTotalDelayMinutes
		--		    , TRGT.sADRGroup = SRC.sADRGroup
		--			, TRGT.fRefundAmount = SRC.fRefundAmount
		--			, TRGT.sDepartureStation = SRC.sDepartureStation
		--			, TRGT.sDestinationStation = SRC.sDestinationStation
		--			, TRGT.dtScheduledDepart = SRC.dtScheduledDepart
		--			, TRGT.dtScheduledArrive = SRC.dtScheduledArrive
		--			, TRGT.dtProcessed = SRC.dtProcessed
		--			, TRGT.sVTCaseNumber = SRC.sVTCaseNumber
		--			, TRGT.sJourneyReference = SRC.sJourneyReference;


		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert/Update  ADR cash  information finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing ADRCash table start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE B
	SET  B.ProcessedInd = 1
	FROM [PreProcessing].TOCPlus_ADRCash AS B 
	INNER JOIN #ADRCash AS S
		ON B.sTracsTrId = S.ExtReference
	AND   B.DataImportDetailID = @dataimportdetailid

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing ADRCash table finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.TOCPlus_ADRCash
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPlus_ADRCash
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

