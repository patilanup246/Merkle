DECLARE @dataimportdetailid INT = 561 

--Create temporary table with location information to aid performance
IF OBJECT_ID(N'tempdb..#tmp_NLCCode_LU') IS NOT NULL
DROP TABLE #tmp_NLCCode_LU
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

SELECT *
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