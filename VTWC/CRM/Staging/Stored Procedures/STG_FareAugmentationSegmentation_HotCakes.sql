CREATE PROCEDURE [Staging].[STG_FareAugmentationSegmentation_HotCakes]
@userID INT
AS
BEGIN
	/* TODO: Juanjo Diaz (juanjo.diaz@cometgc.com) 
	         Error handling when a query and process control 
	         (i.e. When main query fail return error and stop process an log error message) */

	DECLARE @spname                        NVARCHAR(256)
	DECLARE @logtimingidnew                INTEGER
	DECLARE @logmessage                    NVARCHAR(MAX)
	DECLARE @SQLString                     nvarchar(500)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
 
	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
										  @logsource       = @spname,
										  @logmessage      = 'Fare Augmentation Segmentation - HotCakes process - START',
										  @logmessagelevel = 'DEBUG',
										  @messagetypecd   = NULL

--	IF EXISTS (SELECT CAST(1 AS BIT)
--	  		     FROM INFORMATION_SCHEMA.TABLES
--				WHERE TABLE_NAME = 'STG_CustomerID_HotCakesProgramme_DIM'
--				  AND TABLE_SCHEMA = 'Staging')
--	  BEGIN
--		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--											@logsource       = @spname,
--											@logmessage      = 'Table Staging.STG_CustomerID_HotCakesProgramme_DIM deleted',
--											@logmessagelevel = 'DEBUG',
--											@messagetypecd   = NULL
												
--	    DROP TABLE Staging.STG_CustomerID_HotCakesProgramme_DIM
--	  END

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										@logsource       = @spname,
--										@logmessage      = 'Table Staging.STG_CustomerID_HotCakesProgramme_DIM create - START',
--										@logmessagelevel = 'DEBUG',
--										@messagetypecd   = NULL

--	SELECT DISTINCT fas.CustomerID,
--		   CAST(0 AS bit) AS ActiveCustomersNoRecentWeekendTravel,
--		   CAST(0 AS bit) AS ActiveCustomersNoWeekendTravel,
--		   CAST(0 AS bit) AS ProspectsOnBoardWiFiUsersNonConverts,
--		   CAST(0 AS bit) AS ProspectsOnBoardWiFi,
--		   CAST(0 AS bit) AS ProspectsStationWiFi,
--		   CAST(0 AS bit) AS ProspectsWebSiteProspects,
--		   CAST(0 AS bit) AS PotentialHistoricBookers,
--		   CAST(0 AS bit) AS HistoricBookers,
--		   CAST(0 AS bit) AS LapsedBookers,
--		   CAST(0 AS bit) AS AdultGroupTravellers,
--		   CAST(0 AS bit) AS FamilyGroupTravellers
--	  INTO Staging.STG_CustomerID_HotCakesProgramme_DIM
--	  FROM dbo.temp_FareAugmentationSegmentation fas

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										@logsource       = @spname,
--										@logmessage      = 'Table Staging.STG_CustomerID_HotCakesProgramme_DIM create - FINISH',
--										@logmessagelevel = 'DEBUG',
--										@messagetypecd   = NULL
 
--	ALTER TABLE Staging.STG_CustomerID_HotCakesProgramme_DIM ALTER COLUMN CustomerID INT NOT NULL;

--	BEGIN
--		SET @SQLString = 'ALTER TABLE Staging.STG_CustomerID_HotCakesProgramme_DIM ADD PRIMARY KEY (CustomerID)';
--		EXECUTE sp_executesql @stmt= @SQLString
--	END

--	IF EXISTS (SELECT CAST(1 AS BIT)
--	  		     FROM INFORMATION_SCHEMA.TABLES
--				WHERE TABLE_NAME = 'STG_Individual_HotCakesProgramme_DIM'
--				  AND TABLE_SCHEMA = 'Staging')
--	  BEGIN
--		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--											@logsource       = @spname,
--											@logmessage      = 'Table Staging.STG_Individual_HotCakesProgramme_DIM deleted',
--											@logmessagelevel = 'DEBUG',
--											@messagetypecd   = NULL
												
--	    DROP TABLE Staging.STG_Individual_HotCakesProgramme_DIM
--	  END

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										@logsource       = @spname,
--										@logmessage      = 'Table Staging.STG_Individual_HotCakesProgramme_DIM create - START',
--										@logmessagelevel = 'DEBUG',
--										@messagetypecd   = NULL
  
--	-- Segmentation at Individual Level
--	SELECT DISTINCT km.IndividualID, 
--		   CAST(0 AS bit) AS ActiveCustomersNoRecentWeekendTravel,
--		   CAST(0 AS bit) AS ActiveCustomersNoWeekendTravel,
--		   CAST(0 AS bit) AS ProspectsOnBoardWiFiUsersNonConverts,
--		   CAST(0 AS bit) AS ProspectsOnBoardWiFi,
--		   CAST(0 AS bit) AS ProspectsStationWiFi,
--		   CAST(0 AS bit) AS ProspectsWebSiteProspects,
--		   CAST(0 AS bit) AS PotentialHistoricBookers,
--		   CAST(0 AS bit) AS HistoricBookers,
--		   CAST(0 AS bit) AS LapsedBookers,
--		   CAST(0 AS bit) AS AdultGroupTravellers,
--		   CAST(0 AS bit) AS FamilyGroupTravellers
--	  INTO Staging.STG_Individual_HotCakesProgramme_DIM
--	  FROM Staging.STG_KeyMapping km
--	 WHERE km.IndividualID IS NOT NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										@logsource       = @spname,
--										@logmessage      = 'Table Staging.STG_Individual_HotCakesProgramme_DIM create - FINISH',
--										@logmessagelevel = 'DEBUG',
--										@messagetypecd   = NULL

--	ALTER TABLE Staging.STG_Individual_HotCakesProgramme_DIM ALTER COLUMN IndividualID INT NOT NULL;

--	BEGIN
--		SET @SQLString = 'ALTER TABLE Staging.STG_Individual_HotCakesProgramme_DIM ADD PRIMARY KEY (IndividualID)';
--		EXECUTE sp_executesql @stmt= @SQLString
--	END

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on HotCakesProgramme - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - ActiveCustomersNoRecentWeekendTravel - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL
--	-- Active customers without recent weekend travel
--	UPDATE hc
--	   SET ActiveCustomersNoRecentWeekendTravel = CAST(1 AS BIT)
--	  FROM Staging.STG_CustomerID_HotCakesProgramme_DIM hc
--		   INNER JOIN dbo.temp_FareAugmentationSegmentation fas ON hc.CustomerID = fas.CustomerID
--	WHERE fas.NUM_TRANSACTION_BY_CUSTOMER_12Mnths >= 4
--	  AND NOT EXISTS (SELECT 1 
--						FROM dbo.temp_FareAugmentationSegmentation sub_fas
--					   WHERE sub_fas.SalesTransactionDate >= DATEADD(Month, -12, GETDATE())
--						 AND DATEPART(DW, sub_fas.SalesTransactionDate) IN (1,7)
--						 AND sub_fas.SalesTransactionID = fas.SalesTransactionID)
--	  AND EXISTS (SELECT 1
--					FROM dbo.temp_FareAugmentationSegmentation sub_fas
--				   WHERE sub_fas.SalesTransactionDate < DATEADD(Month, -12, GETDATE())
--					 AND DATEPART(DW, sub_fas.SalesTransactionDate) IN (1,7)
--					 AND sub_fas.SalesTransactionID = fas.SalesTransactionID)


--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - ActiveCustomersNoRecentWeekendTravel - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - ActiveCustomersNoWeekendTravel - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	-- Active customers without any weekend travel
--	UPDATE hc
--	   SET ActiveCustomersNoWeekendTravel = CAST(1 AS BIT)
--	  FROM Staging.STG_CustomerID_HotCakesProgramme_DIM hc
--		   INNER JOIN dbo.temp_FareAugmentationSegmentation fas ON hc.CustomerID = fas.CustomerID
--	WHERE fas.NUM_TRANSACTION_BY_CUSTOMER_12Mnths >= 4
--	  AND NOT EXISTS (SELECT 1 
--						FROM dbo.temp_FareAugmentationSegmentation sub_fas
--					   WHERE DATEPART(DW, SalesTransactionDate) IN (1,7)
--						 AND sub_fas.SalesTransactionID = fas.SalesTransactionID)


--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - ActiveCustomersNoWeekendTravel - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_Individual_HotCakesProgramme_DIM - ActiveCustomersNoWeekendTravel - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	-- Prospects - on board wi-fi users non converts
--	UPDATE hc
--	   SET ProspectsOnBoardWiFi = CAST(1 AS BIT)
--	  FROM Staging.STG_Individual_HotCakesProgramme_DIM hc
--		   INNER JOIN Staging.STG_Individual i ON i.IndividualID = hc.IndividualID
--		   INNER JOIN Reference.InformationSource InSo ON InSo.InformationSourceID = i.InformationSourceID 
--		   INNER JOIN emm_sandbox.[CEM].[vw_contact_history_live] ch ON ch.IndividualID = hc.IndividualID
--	 -- WIFI = Staging.STG_Individual were Information Source ID = ICOMERA
--	 WHERE InSo.Name = 'Icomera'
--	  AND ch.Campaign_Code = '139' -- Campaign Code = 139 => Nursery Programme

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_Individual_HotCakesProgramme_DIM - ActiveCustomersNoWeekendTravel - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_Individual_HotCakesProgramme_DIM - Prospects - on board wi-fi - N/A' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_Individual_HotCakesProgramme_DIM - Prospects - station wi-fi - N/A' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL


--	/* Unable to calculate that segment since we don't know when WiFi is OnBoard or Station*/
--	-- Prospects - on board wi-fi
--	-- Prospects - station wi-fi

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_Individual_HotCakesProgramme_DIM - ProspectsWebSiteProspects - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	-- Prospects --web site prospects
--	UPDATE hc
--	   SET hc.ProspectsWebSiteProspects = CAST(1 AS BIT)
--	  FROM Staging.STG_Individual_HotCakesProgramme_DIM hc
--	  INNER JOIN Staging.STG_KeyMapping km ON hc.IndividualID = km.IndividualID
--	 LEFT JOIN Staging.STG_SalesTransaction st ON km.CustomerID = st.CustomerID
--	WHERE km.CreatedDate >= DATEADD(Month, -12, GETDATE())
--	  AND st.CustomerID IS NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_Individual_HotCakesProgramme_DIM - ProspectsWebSiteProspects - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - PotentialHistoricBookers - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL
--	-- Potential Historic bookers
--	UPDATE hc
--	   SET HC.PotentialHistoricBookers = CAST(1 AS BIT) 
--	  FROM Staging.STG_CustomerID_HotCakesProgramme_DIM hc
--	 INNER JOIN dbo.temp_FareAugmentationSegmentation fas ON hc.CustomerID = fas.CustomerID
--	 INNER JOIN Staging.STG_CustomerPreference cp ON cp.CustomerID = hc.CustomerID
--	 INNER JOIN Staging.STG_PreferenceOptions po ON cp.OptionID = po.OptionID 
--	 WHERE fas.LatestTransaction = 1
--	   AND fas.SalesTransactionDate BETWEEN DATEADD(Month, -24, GETDATE() ) AND  DATEADD(Month, -22, GETDATE() )
--	   AND ((po.OptionName = 'Opt out from all channels' AND cp.PreferenceValue = 0)
--	   OR (po.OptionName != 'Opt out from all channels' AND cp.PreferenceValue = 1))

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - PotentialHistoricBookers - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - PotentialHistoricBookers - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

---- Historic bookers
--UPDATE hc
--   SET HC.PotentialHistoricBookers = CAST(1 AS BIT) 
--  FROM Staging.STG_CustomerID_HotCakesProgramme_DIM hc
-- INNER JOIN dbo.temp_FareAugmentationSegmentation fas ON hc.CustomerID = fas.CustomerID
-- INNER JOIN Staging.STG_CustomerPreference cp ON cp.CustomerID = hc.CustomerID
-- INNER JOIN Staging.STG_PreferenceOptions po ON cp.OptionID = po.OptionID 
-- WHERE fas.LatestTransaction = 1
--   AND fas.SalesTransactionDate BETWEEN DATEADD(Month, -26, GETDATE() ) AND  DATEADD(Month, -24, GETDATE() )
--   AND ((po.OptionName = 'Opt out from all channels' AND cp.PreferenceValue = 0)
--   OR (po.OptionName != 'Opt out from all channels' AND cp.PreferenceValue = 1))

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - PotentialHistoricBookers - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - PotentialHistoricBookers - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL
--	-- Lapsed bookers
--	UPDATE hc
--	   SET HC.PotentialHistoricBookers = CAST(1 AS BIT) 
--	  FROM Staging.STG_CustomerID_HotCakesProgramme_DIM hc
--	 INNER JOIN dbo.temp_FareAugmentationSegmentation fas ON hc.CustomerID = fas.CustomerID
--	 INNER JOIN Staging.STG_CustomerPreference cp ON cp.CustomerID = hc.CustomerID
--	 INNER JOIN Staging.STG_PreferenceOptions po ON cp.OptionID = po.OptionID 
--	 WHERE fas.LatestTransaction = 1
--	   AND fas.SalesTransactionDate BETWEEN DATEADD(Month, -13, GETDATE() ) AND  DATEADD(Month, -11, GETDATE() )
--	   AND ((po.OptionName = 'Opt out from all channels' AND cp.PreferenceValue = 0)
--	   OR (po.OptionName != 'Opt out from all channels' AND cp.PreferenceValue = 1))

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - PotentialHistoricBookers - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL


--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - AdultGroupTravellers - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL
--	-- Adult group travellers
--	UPDATE hc
--	   SET hc.AdultGroupTravellers = CAST(1 AS BIT)
--	  FROM Staging.STG_CustomerID_HotCakesProgramme_DIM hc
--	 INNER JOIN dbo.temp_FareAugmentationSegmentation fas ON hc.CustomerID = fas.CustomerID
--	 INNER JOIN Staging.STG_SalesDetail sd ON fas.SalesTransactionID = sd.SalesTransactionID
--	 WHERE fas.NumberofAdults >= 3
--	   AND fas.NumberofChildren = 0
--	   AND fas.SalesTransactionDate >= DATEADD(Month, -12, GETDATE())
--	   AND CAST(sd.OutTravelDate-fas.SalesTransactionDate AS INT) > 14
--	   AND fas.IsVTECJourneyInd = 1

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - AdultGroupTravellers - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - FamilyGroupTravellers - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL
--	-- Family group travellers
--	UPDATE hc
--	   SET hc.FamilyGroupTravellers = CAST(1 AS BIT)
--	  FROM Staging.STG_CustomerID_HotCakesProgramme_DIM hc
--	 INNER JOIN dbo.temp_FareAugmentationSegmentation fas ON hc.CustomerID = fas.CustomerID
--	 INNER JOIN Staging.STG_SalesDetail sd ON fas.SalesTransactionID = sd.SalesTransactionID
--	 WHERE fas.NumberofChildren > 0
--	   AND fas.SalesTransactionDate >= DATEADD(Month, -12, GETDATE())
--	   AND CAST(sd.OutTravelDate-fas.SalesTransactionDate AS INT) > 14
--	   AND fas.IsVTECJourneyInd = 1


--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on Staging.STG_CustomerID_HotCakesProgramme_DIM - FamilyGroupTravellers - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL
--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Update aggreations columns on HotCakesProgramme - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL
 
-- 	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Cleaning unnecessary rows at Individual level - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

-- 	DELETE FROM Staging.STG_Individual_HotCakesProgramme_DIM 
--	 WHERE ActiveCustomersNoRecentWeekendTravel = CAST(0 AS BIT)
--	   AND ActiveCustomersNoWeekendTravel = CAST(0 AS BIT)
--	   AND ProspectsOnBoardWiFiUsersNonConverts = CAST(0 AS BIT)
--	   AND ProspectsOnBoardWiFi = CAST(0 AS BIT)
--	   AND ProspectsStationWiFi = CAST(0 AS BIT)
--	   AND ProspectsWebSiteProspects = CAST(0 AS BIT)
--	   AND PotentialHistoricBookers = CAST(0 AS BIT)
--	   AND HistoricBookers = CAST(0 AS BIT)
--	   AND LapsedBookers = CAST(0 AS BIT)
--	   AND AdultGroupTravellers = CAST(0 AS BIT)
--	   AND FamilyGroupTravellers = CAST(0 AS BIT)

-- 	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Cleaning unnecessary rows at Individual level - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

-- 	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Cleaning unnecessary rows at CustomerID level - START' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL

--	DELETE FROM Staging.STG_CustomerID_HotCakesProgramme_DIM
--	 WHERE ActiveCustomersNoRecentWeekendTravel = CAST(0 AS BIT)
--	   AND ActiveCustomersNoWeekendTravel = CAST(0 AS BIT)
--	   AND ProspectsOnBoardWiFiUsersNonConverts = CAST(0 AS BIT)
--	   AND ProspectsOnBoardWiFi = CAST(0 AS BIT)
--	   AND ProspectsStationWiFi = CAST(0 AS BIT)
--	   AND ProspectsWebSiteProspects = CAST(0 AS BIT)
--	   AND PotentialHistoricBookers = CAST(0 AS BIT)
--	   AND HistoricBookers = CAST(0 AS BIT)
--	   AND LapsedBookers = CAST(0 AS BIT)
--	   AND AdultGroupTravellers = CAST(0 AS BIT)
--	   AND FamilyGroupTravellers = CAST(0 AS BIT)

-- 	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
--										  @logsource       = @spname,
--										  @logmessage      = 'Cleaning unnecessary rows at CustomerID level - FINISH' ,
--										  @logmessagelevel = 'DEBUG',
--										  @messagetypecd   = NULL


	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
										  @logsource       = @spname,
										  @logmessage      = 'Fare Augmentation Segmentation - HotCakes process - FINISH',
										  @logmessagelevel = 'DEBUG',
										  @messagetypecd   = NULL

END