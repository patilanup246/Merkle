

DECLARE @InformationSourceID INT, @DataImportDetailID INT = 574

DECLARE @Now DATETIME = GETDATE()

SELECT @InformationSourceID = InformationSourceID
FROM Reference.InformationSource
WHERE Name = 'TrainLine'

IF OBJECT_ID(N'tempdb..#TOC') IS NOT NULL
DROP TABLE #TOC
SELECT faresettingtoc AS ShortCode, FareSettingTOCDesc AS [Name], @InformationSourceID AS InformationSourceID
INTO #TOC
FROM PreProcessing.TOCPLUS_Journey
WHERE DataImportDetailID = @DataImportDetailID
GROUP BY faresettingtoc, FareSettingTOCDesc

EXEC [Reference].[TOC_Upsert]


IF OBJECT_ID(N'tempdb..#RailCardType') IS NOT NULL
DROP TABLE #RailCardType
SELECT Code, Name, InformationSourceID
INTO #RailCardType
FROM (
SELECT railcard1 AS Code, railcarddesc AS [Name], @InformationSourceID AS InformationSourceID
FROM PreProcessing.TOCPLUS_Journey
WHERE DataImportDetailID = @DataImportDetailID 
GROUP BY railcard1, railcarddesc
UNION ALL 
SELECT Railcard2, railcard2desc , @InformationSourceID
FROM PreProcessing.TOCPLUS_Journey
WHERE DataImportDetailID = @DataImportDetailID 
GROUP BY Railcard2, railcard2desc 
UNION ALL 
SELECT Railcard3, railcard3desc , @InformationSourceID 
FROM PreProcessing.TOCPLUS_Journey
WHERE DataImportDetailID = @DataImportDetailID 
GROUP BY Railcard3, railcard3desc) AS SQ
GROUP BY Code, Name, InformationSourceID

DELETE FROM #RailCardType
WHERE Code = ''

EXEC [Reference].[RailCardType_Upsert]

IF OBJECT_ID(N'tempdb..#Product') IS NOT NULL
DROP TABLE #Product
SELECT tickettypecode AS TicketTypeCode, tickettypedesc AS [Name], @InformationSourceID AS InformationSourceID
INTO #Product
FROM PreProcessing.TOCPLUS_Journey
WHERE DataImportDetailID = @DataImportDetailID
GROUP BY tickettypecode, tickettypedesc

EXEC [Reference].[Product_Upsert]

IF OBJECT_ID(N'tempdb..#FulfilmentMethod') IS NOT NULL
DROP TABLE #FulfilmentMethod
SELECT deliverymethodcode AS ShortCode, deliverymethoddescription AS [Name], @InformationSourceID AS InformationSourceID
INTO #FulfilmentMethod
FROM PreProcessing.TOCPLUS_Journey
WHERE DataImportDetailID = @DataImportDetailID
GROUP BY deliverymethodcode, deliverymethoddescription

EXEC [Reference].[FulfilmentMethod_Upsert]

IF OBJECT_ID(N'tempdb..#AvailabilityCode') IS NOT NULL
DROP TABLE #AvailabilityCode
SELECT availabilitycode AS ShortCode, AvailabilityCodeDesc AS [Name], @InformationSourceID AS InformationSourceID
INTO #AvailabilityCode
FROM PreProcessing.TOCPLUS_Journey
GROUP BY availabilitycode, AvailabilityCodeDesc

EXEC [Reference].[AvailabilityCode_Upsert]

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

IF OBJECT_ID(N'tempdb..#Journey') IS NOT NULL
DROP TABLE #Journey
SELECT  J.journeyid, J.purchaseid, SD.SalesDetailID, SD.SalesTransactionID, SD.CustomerID, J.tcstransactionid, J.tcsbookingid, TOC.TOCID, Origin.StationID AS OrigStationID
       ,Dest.Stationid AS DestStationID, J.outdatedep, J.outdatearr, J.retdatedep, J.retdatearr, CASE WHEN J.journeytype = 'R' THEN 1 ELSE 0 END AS IsReturnIndicator
	   ,COALESCE(RCT.RailcardTypeID,-1) AS RailCard, J.noofrailcards, J.totaladults, J.totalchildren, J.totalreturningadults
	   ,J.totalreturningchildren, J.costoftickets, J.totalcost, J.savingsmade, J.procode
	   ,P.ProductID, FFM.FulfilmentMethodID, CASE WHEN J.journeydirection='O' THEN 1 ELSE 0 END IsOutboundInd, J.journeyreference
	   ,J.outboundmileage, AC.AvailabilityCodeID, CASE WHEN J.DisabledInd = 'N' THEN 0 WHEN J.DisabledInd = 'Y' THEN 1 ELSE NULL END AS DisabledInd, J.NoFullFareAdults, J.NoDiscFareAdults
	   ,J.NoFullFareChildren, J.NoDiscFareChildren, J.NoRailcard1, J.DateCreated, J.DateUpdated
	   ,J.FareId, J.PromoCode, J.FullAdultFare, J.DiscAdultFare1, J.DiscAdultFare2, J.DiscAdultFare3
	   ,J.FullChildFare, J.DiscChildFare1, J.DiscChildFare2, J.DiscChildFare3, J.NoAdultsFullFare
	   ,J.NoAdultsDiscFare1, J.NoAdultsDiscFare2, J.NoAdultsDiscFare3, J.NoChildFullFare, J.NoChildDiscFare1
	   ,J.NoChildDiscFare2, J.NoChildDiscFare3, COALESCE(RCT1.RailcardTypeID,-1) AS RailCard2, J.NoRailcard2, COALESCE(RCT2.RailcardTypeID,-1) AS RailCard3
	   ,J.NoRailcard3, J.NoGroupTicketsFullFare, J.NoGroupTicketsDiscFare, J.FullGroupFare, J.DiscGroupFare
INTO #Journey
FROM Staging.STG_SalesDetail AS SD
INNER JOIN (
		SELECT   ROW_NUMBER() OVER (PARTITION BY purchaseid, journeyid ORDER BY cmddateupdated DESC, TOC_JourneyID DESC) AS RANKING 
				,*
		FROM PreProcessing.TOCPLUS_Journey 
		WHERE  DataImportDetailID = @dataimportdetailid
		AND    ProcessedInd = 0) AS J
	ON  SD.ExtReference = J.purchaseid
LEFT JOIN Reference.TOC AS TOC
	ON J.faresettingtoc = TOC.ShortCode 
LEFT JOIN Reference.RailcardType AS RCT
	ON J.railcard1 = RCT.Code
LEFT JOIN Reference.Product AS P
	ON J.tickettypecode = P.TicketTypeCode
LEFT JOIN Reference.FulfilmentMethod AS FFM
	ON J.deliverymethodcode = FFM.ShortCode 
LEFT JOIN Reference.AvailabilityCode AS AC
	ON J.availabilitycode = AC.ShortCode
LEFT JOIN #Station AS Origin WITH (NOLOCK)
	ON Origin.StationCode = J.origstationcode
LEFT JOIN #Station AS Dest WITH (NOLOCK)
	ON Dest.StationCode = J.deststationcode
LEFT JOIN Reference.RailcardType AS RCT1
	ON J.railcard2 = RCT1.Code
LEFT JOIN Reference.RailcardType AS RCT2
	ON J.railcard3 = RCT2.Code
LEFT JOIN Staging.STG_Journey AS J1
	ON J1.ExtReference = J.journeyid
WHERE J1.SalesDetailID IS NULL
AND J.RANKING = 1



INSERT INTO [Staging].[STG_Journey]
(SalesDetailID, CustomerID, SalesTransactionID, ExtReference, BookingID, TOCIDPrimary, LocationIDOrigin, LocationIDDestination
,[OutDepartureDateTime], [OutArrivalDateTime], [RetDepartureDateTime], [RetArrivalDateTime], IsReturnInd,InformationSourceID
,NoOfRailCards, TotalAdults, TotalChildren, TotalReturningAdults , totalreturningchildren, costoftickets
,totalcost, savingsmade, procode, JourneyReference,IsOutboundInd, outboundmileage, AvailabilityCodeID
,DisabledInd, NoFullFareAdults, NoDiscFareAdults, NoFullFareChildren, NoDiscFareChildren, NoRailcard1, DateCreated
,DateUpdated, FareId, PromoCode, FullAdultFare, DiscAdultFare1, DiscAdultFare2, DiscAdultFare3, FullChildFare
,DiscChildFare1, DiscChildFare2, DiscChildFare3, NoAdultsFullFare, NoAdultsDiscFare1, NoAdultsDiscFare2, NoAdultsDiscFare3
,NoChildFullFare, NoChildDiscFare1, NoChildDiscFare2, NoChildDiscFare3, RailCard2, NoRailcard2, RailCard3, NoRailcard3
,NoGroupTicketsFullFare, NoGroupTicketsDiscFare, FullGroupFare, DiscGroupFare, CreatedDate, CreatedBy, LastModifiedDate
,LastModifiedBy)

SELECT SalesDetailID, CustomerID, SalesTransactionID, journeyid, tcsbookingid, TOCID, OrigStationID, DestStationID
,outdatedep, outdatearr, retdatedep, retdatearr, IsReturnIndicator, @InformationSourceID
,NoOfRailCards, TotalAdults, TotalChildren, TotalReturningAdults , totalreturningchildren, costoftickets
,totalcost, savingsmade, procode, journeyreference, IsOutboundInd, outboundmileage, AvailabilityCodeID
,DisabledInd, NoFullFareAdults, NoDiscFareAdults, NoFullFareChildren, NoDiscFareChildren, NoRailcard1, DateCreated
,DateUpdated, FareId, PromoCode, FullAdultFare, DiscAdultFare1, DiscAdultFare2, DiscAdultFare3, FullChildFare
,DiscChildFare1, DiscChildFare2, DiscChildFare3, NoAdultsFullFare, NoAdultsDiscFare1, NoAdultsDiscFare2, NoAdultsDiscFare3
,NoChildFullFare, NoChildDiscFare1, NoChildDiscFare2, NoChildDiscFare3, RailCard2, NoRailcard2, RailCard3, NoRailcard3
,NoGroupTicketsFullFare, NoGroupTicketsDiscFare, FullGroupFare, DiscGroupFare, @Now, 0, @Now, 0
FROM #Journey

UPDATE SD
SET SD.ProductID = J.ProductID
    ,SD.FulfilmentMethodID = J.FulfilmentMethodID
	,RailcardTypeID = J.RailCard 
FROM Staging.STG_SalesDetail AS SD
INNER JOIN #Journey AS J
ON  SD.SalesDetailID = J.SalesDetailID



