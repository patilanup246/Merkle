/*===========================================================================================
Name:			[Railtimetable].[JourneyStages_Upsert] 
Purpose:		Insert journey stages time table information into table Railtimetable.JourneyStages.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-10-10	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC [Railtimetable].[JourneyStages_Upsert] 
=================================================================================================*/

CREATE PROCEDURE [Railtimetable].[JourneyStages_Upsert] 
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

   DECLARE @xml XML 

   EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SET @ProcName = 'Railtimetable.JourneyStages_Upsert'
   
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

	SELECT @now = GETDATE()

	SET @StepName = 'Insert journey stages rail timetable information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert journey stages rail timetable information start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		
		SELECT @XML = XMLData FROM [PreProcessing].[RailTimeTable]
		WHERE DataImportDetailID = @dataimportdetailid

		IF OBJECT_ID(N'tempdb..#OR') IS NOT NULL
		DROP TABLE #OR
		;WITH XMLNAMESPACES (DEFAULT 'http://www.thalesgroup.com/rtti/XmlTimetable/v8')
		SELECT Tab.Col.value('@timetableID', 'varchar(50)') AS timetableID
				,Tab1.Col1.value('@rid', 'varchar(50)') AS rid
				,Tab1.Col1.value('@uid', 'varchar(50)') AS uid
				,Tab1.Col1.value('@trainId', 'varchar(50)') AS trainId
				,Tab1.Col1.value('@ssd', 'varchar(50)') AS ssd
				,Tab1.Col1.value('@toc', 'varchar(50)') AS toc
				,Tab1.Col1.value('@status', 'varchar(50)') AS status
				,Tab1.Col1.value('@trainCat', 'varchar(50)') AS trainCat
				,Tab1.Col1.value('@isPassengerSvc', 'varchar(50)') AS isPassengerSvc
				,Tab1.Col1.value('@deleted', 'varchar(50)') AS deleted
				,Tab1.Col1.value('@isCharter', 'varchar(50)') AS isCharter
				,Tab1.Col1.value('@qtrain', 'varchar(50)') AS qtrain
				,Tab2.Col2.value('@tpl', 'varchar(50)') AS tpl
				,Tab2.Col2.value('@act', 'varchar(50)') AS act
				,Tab2.Col2.value('@planAct', 'varchar(50)') AS planAct
				,Tab2.Col2.value('@can', 'varchar(50)') AS can
				,Tab2.Col2.value('@plat', 'varchar(50)') AS plat
				,Tab2.Col2.value('@pta', 'varchar(50)') AS pta
				,Tab2.Col2.value('@ptd', 'varchar(50)') AS ptd
				,Tab2.Col2.value('@wta', 'varchar(50)') AS wta
				,Tab2.Col2.value('@wtd', 'varchar(50)') AS wtd
				,Tab2.Col2.value('@fd', 'varchar(50)') AS fd
		INTO #OR
		FROM @XML.nodes('//PportTimetable') AS Tab(Col)
		CROSS APPLY Tab.Col.nodes('Journey') AS Tab1(Col1)
		CROSS APPLY Tab1.Col1.nodes('OR') AS Tab2(Col2)

		--IF OBJECT_ID(N'tempdb..#PP') IS NOT NULL
		--DROP TABLE #PP
		--;WITH XMLNAMESPACES (DEFAULT 'http://www.thalesgroup.com/rtti/XmlTimetable/v8')
		--SELECT Tab.Col.value('@timetableID', 'varchar(50)') AS timetableID
		--       ,Tab1.Col1.value('@rid', 'varchar(50)') AS rid
		--	   ,Tab1.Col1.value('@uid', 'varchar(50)') AS uid
		--	   ,Tab1.Col1.value('@trainId', 'varchar(50)') AS trainId
		--	   ,Tab1.Col1.value('@ssd', 'varchar(50)') AS ssd
		--	   ,Tab1.Col1.value('@toc', 'varchar(50)') AS toc
		--	   ,Tab1.Col1.value('@status', 'varchar(50)') AS status
		--	   ,Tab1.Col1.value('@trainCat', 'varchar(50)') AS trainCat
		--	   ,Tab1.Col1.value('@isPassengerSvc', 'varchar(50)') AS isPassengerSvc
		--	   ,Tab1.Col1.value('@deleted', 'varchar(50)') AS deleted
		--	   ,Tab1.Col1.value('@isCharter', 'varchar(50)') AS isCharter
		--	   ,Tab1.Col1.value('@qtrain', 'varchar(50)') AS qtrain
		--	   ,Tab2.Col2.value('@tpl', 'varchar(50)') AS tpl
		--	   ,Tab2.Col2.value('@act', 'varchar(50)') AS act
		--	   ,Tab2.Col2.value('@planAct', 'varchar(50)') AS planAct
		--	   ,Tab2.Col2.value('@can', 'varchar(50)') AS can
		--	   ,Tab2.Col2.value('@plat', 'varchar(50)') AS plat
		--	   ,Tab2.Col2.value('@wtp', 'varchar(50)') AS wtp
		--	   ,Tab2.Col2.value('@rdelay', 'varchar(50)') AS rdelay
		--INTO #PP
		--FROM @XML.nodes('//PportTimetable') AS Tab(Col)
		--CROSS APPLY Tab.Col.nodes('Journey') AS Tab1(Col1)
		--CROSS APPLY Tab1.Col1.nodes('PP') AS Tab2(Col2)


		IF OBJECT_ID(N'tempdb..#IP') IS NOT NULL
		DROP TABLE #IP
		;WITH XMLNAMESPACES (DEFAULT 'http://www.thalesgroup.com/rtti/XmlTimetable/v8')
		SELECT Tab.Col.value('@timetableID', 'varchar(50)') AS timetableID
				,Tab1.Col1.value('@rid', 'varchar(50)') AS rid
				,Tab1.Col1.value('@uid', 'varchar(50)') AS uid
				,Tab1.Col1.value('@trainId', 'varchar(50)') AS trainId
				,Tab1.Col1.value('@ssd', 'varchar(50)') AS ssd
				,Tab1.Col1.value('@toc', 'varchar(50)') AS toc
				,Tab1.Col1.value('@status', 'varchar(50)') AS status
				,Tab1.Col1.value('@trainCat', 'varchar(50)') AS trainCat
				,Tab1.Col1.value('@isPassengerSvc', 'varchar(50)') AS isPassengerSvc
				,Tab1.Col1.value('@deleted', 'varchar(50)') AS deleted
				,Tab1.Col1.value('@isCharter', 'varchar(50)') AS isCharter
				,Tab1.Col1.value('@qtrain', 'varchar(50)') AS qtrain
				,Tab2.Col2.value('@tpl', 'varchar(50)') AS tpl
				,Tab2.Col2.value('@act', 'varchar(50)') AS act
				,Tab2.Col2.value('@planAct', 'varchar(50)') AS planAct
				,Tab2.Col2.value('@can', 'varchar(50)') AS can
				,Tab2.Col2.value('@plat', 'varchar(50)') AS plat
				,Tab2.Col2.value('@pta', 'varchar(50)') AS pta
				,Tab2.Col2.value('@ptd', 'varchar(50)') AS ptd
				,Tab2.Col2.value('@wta', 'varchar(50)') AS wta
				,Tab2.Col2.value('@wtd', 'varchar(50)') AS wtd
				,Tab2.Col2.value('@rdelay', 'varchar(50)') AS rdelay
				,Tab2.Col2.value('@fd', 'varchar(50)') AS fd
		INTO #IP
		FROM @XML.nodes('//PportTimetable') AS Tab(Col)
		CROSS APPLY Tab.Col.nodes('Journey') AS Tab1(Col1)
		CROSS APPLY Tab1.Col1.nodes('IP') AS Tab2(Col2)


		IF OBJECT_ID(N'tempdb..#DT') IS NOT NULL
		DROP TABLE #DT
		;WITH XMLNAMESPACES (DEFAULT 'http://www.thalesgroup.com/rtti/XmlTimetable/v8')
		SELECT Tab.Col.value('@timetableID', 'varchar(50)') AS timetableID
				,Tab1.Col1.value('@rid', 'varchar(50)') AS rid
				,Tab1.Col1.value('@uid', 'varchar(50)') AS uid
				,Tab1.Col1.value('@trainId', 'varchar(50)') AS trainId
				,Tab1.Col1.value('@ssd', 'varchar(50)') AS ssd
				,Tab1.Col1.value('@toc', 'varchar(50)') AS toc
				,Tab1.Col1.value('@status', 'varchar(50)') AS status
				,Tab1.Col1.value('@trainCat', 'varchar(50)') AS trainCat
				,Tab1.Col1.value('@isPassengerSvc', 'varchar(50)') AS isPassengerSvc
				,Tab1.Col1.value('@deleted', 'varchar(50)') AS deleted
				,Tab1.Col1.value('@isCharter', 'varchar(50)') AS isCharter
				,Tab1.Col1.value('@qtrain', 'varchar(50)') AS qtrain
				,Tab2.Col2.value('@tpl', 'varchar(50)') AS tpl
				,Tab2.Col2.value('@act', 'varchar(50)') AS act
				,Tab2.Col2.value('@planAct', 'varchar(50)') AS planAct
				,Tab2.Col2.value('@can', 'varchar(50)') AS can
				,Tab2.Col2.value('@plat', 'varchar(50)') AS plat
				,Tab2.Col2.value('@pta', 'varchar(50)') AS pta
				,Tab2.Col2.value('@ptd', 'varchar(50)') AS ptd
				,Tab2.Col2.value('@wta', 'varchar(50)') AS wta
				,Tab2.Col2.value('@wtd', 'varchar(50)') AS wtd
				,Tab2.Col2.value('@rdelay', 'varchar(50)') AS rdelay
		INTO #DT
		FROM @XML.nodes('//PportTimetable') AS Tab(Col)
		CROSS APPLY Tab.Col.nodes('Journey') AS Tab1(Col1)
		CROSS APPLY Tab1.Col1.nodes('DT') AS Tab2(Col2)

		IF OBJECT_ID(N'tempdb..#cancelReason') IS NOT NULL
		DROP TABLE #cancelReason
		;WITH XMLNAMESPACES (DEFAULT 'http://www.thalesgroup.com/rtti/XmlTimetable/v8')
		SELECT Tab.Col.value('@timetableID', 'varchar(50)') AS timetableID
				,Tab1.Col1.value('@rid', 'varchar(50)') AS rid
				,Tab1.Col1.value('@uid', 'varchar(50)') AS uid
				,Tab1.Col1.value('@trainId', 'varchar(50)') AS trainId
				,Tab1.Col1.value('@ssd', 'varchar(50)') AS ssd
				,Tab1.Col1.value('@toc', 'varchar(50)') AS toc
				,Tab1.Col1.value('@status', 'varchar(50)') AS status
				,Tab1.Col1.value('@trainCat', 'varchar(50)') AS trainCat
				,Tab1.Col1.value('@isPassengerSvc', 'varchar(50)') AS isPassengerSvc
				,Tab1.Col1.value('@deleted', 'varchar(50)') AS deleted
				,Tab1.Col1.value('@isCharter', 'varchar(50)') AS isCharter
				,Tab1.Col1.value('@qtrain', 'varchar(50)') AS qtrain
				,Tab1.Col1.value('cancelReason[1]', 'varchar(50)') AS cancelReason
		INTO #cancelReason
		FROM @XML.nodes('//PportTimetable') AS Tab(Col)
		CROSS APPLY Tab.Col.nodes('Journey') AS Tab1(Col1)



		IF OBJECT_ID(N'tempdb..#JourneyStages') IS NOT NULL
		DROP TABLE #JourneyStages 
		SELECT rid, uid, trainId, ssd, toc, trainCat, isPassengerSvc, 'OR' AS Stage, tpl 
				,act, plat, pta, ptd, wta, wtd, timetableID
		INTO #JourneyStages
		FROM #OR
		WHERE toc ='VT'
		UNION ALL 
		SELECT rid, uid, trainId, ssd, toc, trainCat, isPassengerSvc, 'IP' AS Stage, tpl 
				,act, plat, pta, ptd, wta, wtd, timetableID
		FROM #IP
		WHERE toc ='VT'
		UNION ALL 
		SELECT rid, uid, trainId, ssd, toc, trainCat, isPassengerSvc, 'DT' AS Stage, tpl 
				,act, plat, pta, ptd, wta, wtd, timetableID
		FROM #DT
		WHERE toc ='VT'

		INSERT INTO [Railtimetable].[JourneyStages]
		(rid, uid, trainId, ssd, toc, trainCat, isPassengerSvc
		,Stage, tpl, act, plat, pta, ptd, wta, wtd, cancelReason
		,LocationID, CreatedDate, CreatedBy, CreatedExtractNumber
		,LastModifiedDate, LastModifiedBy, LastModifiedExtractNumber)

		SELECT A.rid, A.uid, A.trainId, A.ssd, A.toc, A.trainCat
				,A.isPassengerSvc, A.Stage, A.tpl, A.act, A.plat
				,A.pta, A.ptd, A.wta, A.wtd, SQ.cancelReason
				,L.LocationID, @now, @userid, @dataimportdetailid
				,@userid, @userid, @dataimportdetailid
		FROM #JourneyStages AS A
		LEFT JOIN (SELECT *
				FROM #cancelReason
				WHERE cancelReason IS NOT NULL) AS SQ
			ON A.rid = SQ.rid
		LEFT JOIN Reference.Location AS L
			ON A.tpl = L.TIPLOC
		ORDER BY rid, COALESCE(A.ptd,pta)

		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert journey stages rail timetable information finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	SELECT @now = GETDATE()

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing RailTimeTable table start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE B
	SET  B.ProcessedInd = 1
		 ,B.LastModifiedDateETL = @now
	FROM [PreProcessing].RailTimeTable AS B 
	WHERE    B.DataImportDetailID = @dataimportdetailid

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing RailTimeTable table finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	SELECT @successcountimport = COUNT(1)
	FROM   [Railtimetable].[JourneyStages]
	WHERE  LastModifiedExtractNumber = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

	SELECT @now = GETDATE()

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


