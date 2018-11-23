﻿CREATE VIEW [Reference].[Location_NLCCode_VW]
AS
    WITH CTE_Locations
	AS (
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
			  ,ROW_NUMBER() OVER (partition by NLCCode ORDER BY [CATEType]) RANKING
              FROM [Reference].[Location]
        )

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
    FROM CTE_Locations
    WHERE Ranking = 1