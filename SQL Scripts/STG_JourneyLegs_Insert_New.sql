

DECLARE @InformationSourceID INT, @DataImportDetailID INT = 575

DECLARE @Now DATETIME = GETDATE()

SELECT @InformationSourceID = InformationSourceID
FROM Reference.InformationSource
WHERE Name = 'TrainLine'

 

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

--Create temporary table with location information to aid performance
IF OBJECT_ID(N'tempdb..#Station') IS NOT NULL
DROP TABLE #Station
SELECT [StationID]
		,[Name]
		,[ShortCode] AS StationCode
		,County
		,PostCode
		,GroupStation
INTO #Station
FROM [Reference].[Station]

IF OBJECT_ID(N'tempdb..#JourneyLeg') IS NOT NULL
DROP TABLE #JourneyLeg
SELECT JL.legid, J.JourneyID, JL.legno, Origin.StationID AS OrigStation, Dest.StationID AS DestStation
       ,depdatetime, arrdatetime, MOT.ModeOfTransportID, TC.TicketClassID
	   ,TOC.TOCID, '00' + JL.retailtrainid AS RSID, JL.coach + '' + JL.seat AS SeatReservation
	   ,JL.quietzoneyn, JL.trainuid, JL.jltype, JL.CMDDateCreated, JL.cmddateupdated
INTO #JourneyLeg
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
LEFT JOIN #Station AS Origin WITH (NOLOCK)
	ON Origin.StationCode = JL.legorigstationcode
LEFT JOIN #Station AS Dest WITH (NOLOCK)
	ON Dest.StationCode = JL.legdeststationcode
LEFT JOIN Reference.ModeOfTransport AS MOT
	ON JL.modeoftransport = MOT.ShortCode 
LEFT JOIN Reference.TicketClass AS TC
	ON JL.seatingclass = TC.ShortCode 
LEFT JOIN Reference.TOC AS TOC
	ON JL.operatorcode = TOC.ShortCode
LEFT JOIN [Staging].[STG_JourneyLeg] AS JL1 WITH (NOLOCK) 
	ON  JL1.ExtReference = JL.legid
WHERE JL1.JourneyLegID IS NULL
AND JL.RANKING = 1

INSERT INTO [Staging].[STG_JourneyLeg]
([JourneyID], [LegNumber], [RSID], [TicketClassID], [LocationIDOrigin]
,[LocationIDDestination], [DepartureDateTime],[ArrivalDateTime], [TOCID]
,[SeatReservation], [ExtReference], [InformationSourceID], [SourceCreatedDate]
,[SourceModifiedDate], [QuietZone_YN], [TrainUID], [JLType], CreatedDate
,CreatedBy, LastModifiedDate, LastModifiedBy)

SELECT JourneyID, legno, RSID, TicketClassID, OrigStation
       ,DestStation, depdatetime, arrdatetime, TOCID
	   ,SeatReservation, legid, @InformationSourceID, CMDDateCreated
	   ,cmddateupdated, quietzoneyn, trainuid, jltype, @Now
	   ,0, @Now, 0
FROM #JourneyLeg 
	                                               
--SELECT *
--FROM PreProcessing.TOCPLUS_JourneyLegs

SELECT *
FROM [Staging].[STG_JourneyLeg] 

