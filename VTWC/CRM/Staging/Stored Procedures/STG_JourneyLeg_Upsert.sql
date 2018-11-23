/*===========================================================================================
Name:			[Staging].[STG_JourneyLeg_Upsert]
Purpose:		Insert/Update Journey leg information into table Staging.STG_JourneyLeg.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-10	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC [Staging].[STG_JourneyLeg_Upsert]
=================================================================================================*/

  CREATE PROCEDURE [Staging].[STG_JourneyLeg_Upsert] 
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

	SET @ProcName = 'PreProcessing.TOCPlus_JourneyLeg_Insert'
   
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

	IF OBJECT_ID(N'tempdb..#ModeOfTransport') IS NOT NULL
	DROP TABLE #ModeOfTransport
	SELECT modeoftransport AS ShortCode, ModeOfTransportDesc AS [Name], @InformationSourceID AS InformationSourceID
	INTO #ModeOfTransport
	FROM PreProcessing.TOCPLUS_JourneyLegs
	WHERE DataImportDetailID = @DataImportDetailID
	GROUP BY modeoftransport, ModeOfTransportDesc

	EXEC [Reference].[ModeOfTransport_Upsert]

	IF OBJECT_ID(N'tempdb..#TicketClass') IS NOT NULL
	DROP TABLE #TicketClass
	SELECT seatingclass AS ShortCode, SeatingClassDesc AS [Name], @InformationSourceID AS InformationSourceID
	INTO #TicketClass
	FROM PreProcessing.TOCPLUS_JourneyLegs
	WHERE DataImportDetailID = @DataImportDetailID
	GROUP BY seatingclass, SeatingClassDesc

	EXEC [Reference].[TicketClass_Upsert]

	IF OBJECT_ID(N'tempdb..#TOC') IS NOT NULL
	DROP TABLE #TOC
	SELECT operatorcode AS ShortCode, OperatorCodeDesc AS [Name], @InformationSourceID AS InformationSourceID
	INTO #TOC
	FROM PreProcessing.TOCPLUS_JourneyLegs
	WHERE DataImportDetailID = @DataImportDetailID
	GROUP BY operatorcode, OperatorCodeDesc

	EXEC [Reference].[TOC_Upsert]


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

	

	SET @StepName = 'Insert journey leg information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert journey leg information start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		--Create temporary table with location information to aid performance
		SELECT [LocationID]
			  ,[LocationIDParent]
			  ,[Name]
			  ,[Description]
			  ,[TIPLOC]
			  ,[NLCCode]
			  ,[CRSCode]
			  ,[CATEType]
			  ,[3AlphaCode]
			  ,[3AlphaCodeSub]
			  ,[Longitude]
			  ,[Latitude]
			  ,[Northing]
			  ,[Easting]
			  ,[ChangeTime]
			  ,[DescriptionATOC]
			  ,[DescriptionATOC_ATB]
			  ,[NLCPlusbus]
			  ,[PTECode]
			  ,[IsPlusbusInd]
			  ,[IsGroupStationInd]
			  ,[LondonZoneNumber]
			  ,[PartOfAllZones]
			  ,[IDMSDisplayName]
			  ,[IDMSPrintingName]
			  ,[IsIDMSAttendedTISInd]
			  ,[IsIDMSUnattendedTISInd]
			  ,[IDMSAdviceMessage]
			  ,[ExtReference]
			  ,[SourceCreatedDate]
			  ,[SourceModifiedDate]
			  ,[CreatedDate]
			  ,[LastModifiedDate]
		  INTO #tmp_NLCCode_LU
		  FROM [Reference].[Location_NLCCode_VW]

			IF OBJECT_ID(N'tempdb..#JourneyLeg_0') IS NOT NULL
			DROP TABLE #JourneyLeg_0
			SELECT JL.legid AS ExtReference, J.JourneyID, JL.legno, legorigstationcode, legdeststationcode
					,depdatetime, arrdatetime, modeoftransport, seatingclass
					,operatorcode, JL.retailtrainid AS RSID, JL.coach + '' + CASE WHEN JL.seat =0 THEN NULL ELSE  JL.seat END AS SeatReservation
					,JL.quietzoneyn, JL.trainuid, JL.jltype, JL.CMDDateCreated AS SourceCreatedDate, JL.cmddateupdated AS SourceModifiedDate
			INTO #JourneyLeg_0
			FROM Staging.STG_SalesDetail AS SD
			INNER JOIN Staging.STG_Journey AS J
				ON SD.SalesDetailID = J.SalesDetailID
			INNER JOIN (
					SELECT   ROW_NUMBER() OVER (PARTITION BY journeyid,legid, legno ORDER BY cmddateupdated DESC, TOC_JourneyLegsID DESC) AS RANKING 
							,*
					FROM PreProcessing.TOCPLUS_JourneyLegs 
					WHERE  DataImportDetailID = @dataimportdetailid
					AND    ProcessedInd = 0) AS JL
				ON  J.ExtReference = JL.journeyid
			WHERE JL.RANKING = 1

			IF OBJECT_ID(N'tempdb..#JourneyLeg') IS NOT NULL
			DROP TABLE #JourneyLeg
			SELECT  JL.ExtReference, JL.JourneyID, JL.legno, Origin.LocationID AS OrigStation, Dest.LocationID AS DestStation
					,depdatetime, arrdatetime, MOT.ModeOfTransportID, TC.TicketClassID,TOC.TOCID, JL.RSID, JL.SeatReservation
					,JL.quietzoneyn, JL.trainuid, JL.jltype, JL.SourceCreatedDate, JL.SourceModifiedDate
			INTO #JourneyLeg
			FROM #JourneyLeg_0 AS JL
			LEFT JOIN #tmp_NLCCode_LU AS Origin WITH (NOLOCK)
				ON Origin.CRSCode = JL.legorigstationcode
			LEFT JOIN #tmp_NLCCode_LU AS Dest WITH (NOLOCK)
				ON Dest.CRSCode = JL.legdeststationcode
			LEFT JOIN Reference.ModeOfTransport AS MOT
				ON JL.modeoftransport = MOT.ShortCode 
			LEFT JOIN Reference.TicketClass AS TC
				ON JL.seatingclass = TC.ShortCode 
			LEFT JOIN Reference.TOC AS TOC
				ON JL.operatorcode = TOC.ShortCode

		MERGE Staging.STG_JourneyLeg AS TRGT
		USING #JourneyLeg AS SRC
		ON TRGT.ExtReference = SRC.ExtReference
		WHEN NOT MATCHED THEN
		-- Inserting new journey information 
		INSERT ([JourneyID], [LegNumber], [RSID], [TicketClassID], [LocationIDOrigin]
				,[LocationIDDestination], [DepartureDateTime],[ArrivalDateTime], [ModeOfTransportID], [TOCID]
				,[SeatReservation], [ExtReference], [InformationSourceID], [SourceCreatedDate]
				,[SourceModifiedDate], [QuietZone_YN], [TrainUID], [JLType], CreatedDate
				,CreatedBy, CreatedExtractNumber, LastModifiedDate, LastModifiedBy
				,LastModifiedExtractNumber)
		VALUES
				(JourneyID, legno, RSID, TicketClassID, OrigStation
			    ,DestStation, depdatetime, arrdatetime, ModeOfTransportID, TOCID
			    ,SeatReservation, ExtReference, @InformationSourceID, SourceCreatedDate
			    ,SourceModifiedDate, quietzoneyn, trainuid, jltype, @Now
			    ,0, @dataimportdetailid, @Now, 0, @dataimportdetailid)
		WHEN MATCHED 
			AND SRC.SourceModifiedDate > TRGT.SourceModifiedDate
			THEN 
				-- Update existing journey information
				UPDATE 
				SET TRGT.SourceModifiedDate = SRC.SourceModifiedDate
					,TRGT.LastModifiedExtractNumber = @dataimportdetailid
				    ,TRGT.LastModifiedDate = @now
					,TRGT.[JourneyID] = SRC.[JourneyID]
					,TRGT.[LegNumber] = SRC.legno
					,TRGT.[RSID] = SRC.[RSID]
					,TRGT.[TicketClassID] = SRC.[TicketClassID]
					,TRGT.[LocationIDOrigin] = SRC.OrigStation
					,TRGT.[LocationIDDestination] = SRC.DestStation
					,TRGT.[DepartureDateTime] = SRC.depdatetime
					,TRGT.[ArrivalDateTime] = SRC.arrdatetime
					,TRGT.[TOCID] = SRC.[TOCID]
					,TRGT.[SeatReservation] = SRC.[SeatReservation]
					,TRGT.[QuietZone_YN] = SRC.quietzoneyn
					,TRGT.[TrainUID] = SRC.[TrainUID]
					,TRGT.[JLType] = SRC.[JLType];


		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert journey leg information finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing journey leg table start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE B
	SET  B.ProcessedInd = 1
		 ,b.LastModifiedDateETL = @now
	FROM [PreProcessing].TOCPLUS_JourneyLegs AS B 
	INNER JOIN  Staging.STG_JourneyLeg AS BL ON B.legid = BL.ExtReference
	AND   B.DataImportDetailID = @dataimportdetailid

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing journey leg table finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_JourneyLegs
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_JourneyLegs
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


