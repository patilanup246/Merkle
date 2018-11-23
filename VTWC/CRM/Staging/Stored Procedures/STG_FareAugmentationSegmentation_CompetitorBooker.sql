CREATE PROCEDURE [Staging].[STG_FareAugmentationSegmentation_CompetitorBooker] 
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
										  @logmessage      = 'Fare Augmentation Segmentation - CompetitorBooker process - START',
										  @logmessagelevel = 'DEBUG',
										  @messagetypecd   = NULL


	--IF EXISTS (SELECT CAST(1 AS BIT)
	--			   FROM INFORMATION_SCHEMA.TABLES
	--			  WHERE TABLE_NAME = 'temp_FareAugmentationSegmentation'
	--				AND TABLE_SCHEMA = 'dbo')
	--BEGIN
	--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--										@logsource       = @spname,
	--										@logmessage      = 'Table dbo.temp_FareAugmentationSegmentation deleted',
	--										@logmessagelevel = 'DEBUG',
	--										@messagetypecd   = NULL
       
	--	DROP TABLE dbo.temp_FareAugmentationSegmentation
	--END

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Table dbo.temp_FareAugmentationSegmentation created - START' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	---- Assumptions: Null journey legs means not VTEC journeys
	--SELECT st.SalesTransactionID 
	--	  ,st.SalesTransactionDate 
	--	  ,st.CustomerID 
	--	  ,st.NumberofAdults
	--	  ,st.NumberofChildren
	--	  ,RANK() OVER(PARTITION BY st.[CustomerID] ORDER BY st.[SalesTransactionDate] DESC, st.SalesTransactionID ASC) AS LatestTransaction
	--	  ,MAX(CASE WHEN jo.JourneyID IS NOT NULL OR jr.JourneyID IS NOT NULL THEN 1 ELSE 0 END) IsVTECJourneyInd
	--  	  ,0 AS NUM_TRANSACTION_BY_CUSTOMER_12Mnths
	--	  ,COUNT(st.SalesTransactionID) OVER (PARTITION BY st.CustomerID) NUM_TRANSACTION_BY_CUSTOMER_24Mnths
	--	  ,0 AS NUM_VTEC_JOURNEY_12Mnths
	--	  ,0 AS NUM_NO_VTEC_JOURNEY_12Mnths
	--	  ,0 AS NUM_VTEC_JOURNEY_13_24Mnths
	--	  ,0 AS NUM_NO_VTEC_JOURNEY_13_24Mnths
	--INTO dbo.temp_FareAugmentationSegmentation
	--FROM Staging.STG_SalesTransaction st
 --   INNER JOIN Staging.STG_SalesDetail sd ON st.SalesTransactionID = sd.SalesTransactionID
	--INNER JOIN Staging.STG_Journey j      ON sd.SalesDetailID = j.SalesDetailID
	--LEFT  JOIN Staging.STG_JourneyLeg jo  ON jo.JourneyID = j.JourneyID and j.IsOutboundInd = 1
	--LEFT  JOIN Staging.STG_JourneyLeg jr  ON jr.JourneyID = j.JourneyID and j.IsReturnInd = 1
	--WHERE st.SalesTransactionDate >= DATEADD(Month, -24, GETDATE()) 
	--GROUP BY st.SalesTransactionID 
	--  		,st.SalesTransactionDate 
	--		,st.CustomerID 
	--		,st.NumberofAdults
	--		,st.NumberofChildren
	--		,st.CustomerID

	-- IF EXISTS (SELECT CAST(1 AS BIT)
	--			   FROM INFORMATION_SCHEMA.TABLES
	--			  WHERE TABLE_NAME = 'temp_FareAugmentationSegmentation'
	--				AND TABLE_SCHEMA = 'dbo')
	--BEGIN
	--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--										@logsource       = @spname,
	--										@logmessage      = 'Table dbo.temp_FareAugmentationSegmentation created - FINISH',
	--										@logmessagelevel = 'DEBUG',
	--										@messagetypecd   = NULL

	--END

	
	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Settig up temp_FareAugmentationSegmentation for indexing and primary key - START' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	---- Settig up temp_FareAugmentationSegmentation for indexing and primary key
	--ALTER TABLE dbo.temp_FareAugmentationSegmentation ALTER COLUMN SalesTransactionID INT NOT NULL;
	--ALTER TABLE dbo.temp_FareAugmentationSegmentation ALTER COLUMN CustomerID INT NOT NULL;
	--ALTER TABLE dbo.temp_FareAugmentationSegmentation ALTER COLUMN LatestTransaction BIGINT NOT NULL;
	---- Modify IsVTECJourneyInd to allow boolean (bit)
	--ALTER TABLE dbo.temp_FareAugmentationSegmentation ALTER COLUMN IsVTECJourneyInd BIT NOT NULL;
	---- Creating Primary Key
	--BEGIN
	--	SET @SQLString = 'ALTER TABLE dbo.temp_FareAugmentationSegmentation ADD PRIMARY KEY (SalesTransactionID, CustomerID)';
	--	EXECUTE sp_executesql @stmt= @SQLString
	--END

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Settig up temp_FareAugmentationSegmentation for indexing and primary key - FINISH' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL


	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - START' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL


	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_TRANSACTION_BY_CUSTOMER_12Mnths - START' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	---- Update aggreations columns on dbo.temp_FareAugmentationSegmentation
	--UPDATE fa
	--   SET fa.NUM_TRANSACTION_BY_CUSTOMER_12Mnths = (SELECT COUNT(sub_st.SalesTransactionID) 
	--												   FROM Staging.STG_SalesTransaction sub_st 
	--												  WHERE sub_st.CustomerID = fa.CustomerID
	--													AND sub_st.SalesTransactionDate >= DATEADD(Month, -12, GETDATE() ))
	-- FROM dbo.temp_FareAugmentationSegmentation fa;

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_TRANSACTION_BY_CUSTOMER_12Mnths - FINISH' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_VTEC_JOURNEY_12Mnths - START' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL
	
	--UPDATE fa
	--   SET fa.NUM_VTEC_JOURNEY_12Mnths = (SELECT COUNT(sub_fa.IsVTECJourneyInd) 
	--										FROM dbo.temp_FareAugmentationSegmentation sub_fa
	--									   WHERE sub_fa.CustomerID = fa.CustomerID
	--										 AND sub_fa.SalesTransactionDate >= DATEADD(Month, -12, GETDATE() ))
	-- FROM dbo.temp_FareAugmentationSegmentation fa;
	

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_VTEC_JOURNEY_12Mnths - FINISH' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_VTEC_JOURNEY_13_24Mnths - START' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL
	--UPDATE fa
	--   SET fa.NUM_VTEC_JOURNEY_13_24Mnths = (SELECT COUNT(sub_fa.IsVTECJourneyInd) 
	--										FROM dbo.temp_FareAugmentationSegmentation sub_fa
	--									   WHERE sub_fa.CustomerID = fa.CustomerID
	--										 AND sub_fa.SalesTransactionDate BETWEEN DATEADD(Month, -24, GETDATE() ) AND  DATEADD(Month, -13, GETDATE() ))
	-- FROM dbo.temp_FareAugmentationSegmentation fa;

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_VTEC_JOURNEY_13_24Mnths - FINISH' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_NO_VTEC_JOURNEY_12Mnths - START' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL
										  										  	
	--UPDATE fa
	--   SET fa.NUM_NO_VTEC_JOURNEY_12Mnths = (SELECT COUNT(~sub_fa.IsVTECJourneyInd) 
	--										   FROM dbo.temp_FareAugmentationSegmentation sub_fa
	--										  WHERE sub_fa.CustomerID = fa.CustomerID
	--											AND sub_fa.SalesTransactionDate >= DATEADD(Month, -12, GETDATE() ))
	-- FROM dbo.temp_FareAugmentationSegmentation fa;

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_NO_VTEC_JOURNEY_12Mnths - FINISH' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_NO_VTEC_JOURNEY_13_24Mnths - START' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL
										  											  	
	--UPDATE fa
	--   SET fa.NUM_NO_VTEC_JOURNEY_13_24Mnths = (SELECT COUNT(~sub_fa.IsVTECJourneyInd) 
	--											  FROM dbo.temp_FareAugmentationSegmentation sub_fa
	--											 WHERE sub_fa.CustomerID = fa.CustomerID
	--											   AND sub_fa.SalesTransactionDate BETWEEN DATEADD(Month, -24, GETDATE() ) AND  DATEADD(Month, -13, GETDATE() ))
	-- FROM dbo.temp_FareAugmentationSegmentation fa;


	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - NUM_NO_VTEC_JOURNEY_13_24Mnths - FINISH' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL


	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Update aggreations columns on dbo.temp_FareAugmentationSegmentation - FINISH' ,
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	--IF EXISTS (SELECT CAST(1 AS BIT)
	--			   FROM INFORMATION_SCHEMA.TABLES
	--			  WHERE TABLE_NAME = 'STG_CompetitorProgramme_DIM'
	--				AND TABLE_SCHEMA = 'Staging')
	--BEGIN
	--	EXEC [Operations].[LogMessage_Record] 
	--		@userid          = @userid,
	--		@logsource       = @spname,
	--		@logmessage      = 'Table Staging.STG_CompetitorProgramme_DIM deleted',
	--		@logmessagelevel = 'DEBUG',
	--		@messagetypecd   = NULL
       
	--	DROP TABLE Staging.STG_CompetitorProgramme_DIM
	--END

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Table Staging.STG_CompetitorProgramme_DIM created - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL

	--SELECT DISTINCT st.CustomerID,
	--	   CAST(0 AS bit) AS ConsistentCompetitorBooker12Mnths,
	--	   CAST(0 AS bit) AS ConsistentCompetitorBooker24Mnths,
	--	   CAST(0 AS bit) AS ConsistentCompetitorBooker,
	--	   CAST(0 AS bit) AS FirstTimeCompetitorBookerFirstBooking,
	--	   CAST(0 AS bit) AS FirstTimeCompetitorBooker,
	--	   CAST(0 AS bit) AS CompetitorVTECMixLast12Mnths,
	--	   CAST(0 AS bit) AS CompetitorVTECMixLast24Mnths,
	--	   CAST(0 AS bit) AS AllElse
	--  INTO Staging.STG_CompetitorProgramme_DIM
	--  FROM temp_FareAugmentationSegmentation st 


	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Table Staging.STG_CompetitorProgramme_DIM created - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Settig up Staging.STG_CompetitorProgramme_DIM for indexing and primary key - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL

	---- Settig up temp_FareAugmentationSegmentation for indexing and primary key
	--ALTER TABLE Staging.STG_CompetitorProgramme_DIM ALTER COLUMN CustomerID INT NOT NULL;
	---- Create Primary Key
	--BEGIN
	--	SET @SQLString = 'ALTER TABLE Staging.STG_CompetitorProgramme_DIM ADD PRIMARY KEY (CustomerID)';
	--	EXECUTE sp_executesql @stmt= @SQLString;
	--END

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Settig up Staging.STG_CompetitorProgramme_DIM for indexing and primary key - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL


	--/***************************************************************************
	--** Calculate Segments ******************************************************
	--***************************************************************************/

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Consistent competitor booker 12 months - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL
	---- Consistent competitor booker 12 months
	--UPDATE cp
	--   SET ConsistentCompetitorBooker12Mnths = CAST(1 AS BIT)
	--  FROM Staging.STG_CompetitorProgramme_DIM cp
	--	   INNER JOIN dbo.temp_FareAugmentationSegmentation tfa ON cp.CustomerID = tfa.CustomerID
	--  WHERE tfa.NUM_TRANSACTION_BY_CUSTOMER_24Mnths > 3 
	--  AND LatestTransaction >= 2                        
	--  AND tfa.IsVTECJourneyInd = 1                      
	--  AND SalesTransactionDate <= DATEADD(Month, -12, GETDATE())

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Consistent competitor booker 12 months - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL


	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Consistent competitor booker 24 months - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL			
	---- Consistent competitor booker 24 months
	--UPDATE cp
	--   SET ConsistentCompetitorBooker24Mnths = CAST(1 AS BIT)
	--  FROM Staging.STG_CompetitorProgramme_DIM cp
	--	   INNER JOIN dbo.temp_FareAugmentationSegmentation tfa ON cp.CustomerID = tfa.CustomerID
	--  WHERE tfa.NUM_TRANSACTION_BY_CUSTOMER_24Mnths > 3 
	--  AND LatestTransaction >= 2                        
	--  AND tfa.IsVTECJourneyInd = 1
	--  AND SalesTransactionDate BETWEEN DATEADD(Month, -24, GETDATE()) AND DATEADD(Month, -12, GETDATE())

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Consistent competitor booker 24 months - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL		


	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Consistent competitor booker - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL	
			
	---- Consistent competitor booker 
	--UPDATE cp
	--   SET ConsistentCompetitorBooker = CAST(1 AS BIT)
	--  FROM Staging.STG_CompetitorProgramme_DIM cp
	--	   INNER JOIN dbo.temp_FareAugmentationSegmentation tfa ON cp.CustomerID = tfa.CustomerID
	--  WHERE tfa.NUM_TRANSACTION_BY_CUSTOMER_24Mnths > 3 
	--  AND LatestTransaction >= 1                        
	--  AND tfa.IsVTECJourneyInd = 0
	--  AND SalesTransactionDate BETWEEN DATEADD(Month, -24, GETDATE()) AND DATEADD(Month, -12, GETDATE())

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Consistent competitor booker - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL	


	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Consistent competitor booker - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL	
	
	---- First time competitor booker (first booking)
	--UPDATE cp
	--   SET FirstTimeCompetitorBookerFirstBooking = CAST(1 AS BIT)
	--  FROM Staging.STG_CompetitorProgramme_DIM cp
	--	   INNER JOIN dbo.temp_FareAugmentationSegmentation tfa ON cp.CustomerID = tfa.CustomerID
	--  WHERE LatestTransaction = NUM_TRANSACTION_BY_CUSTOMER_24Mnths
	--	AND tfa.IsVTECJourneyInd = 1
	--	AND NUM_TRANSACTION_BY_CUSTOMER_24Mnths = 1

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Consistent competitor booker - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL	


	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - First time competitor booker - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL	
			
	---- First time competitor booker
	--UPDATE cp
	--   SET FirstTimeCompetitorBooker = CAST(1 AS BIT)
	--  FROM Staging.STG_CompetitorProgramme_DIM cp
	--	   INNER JOIN dbo.temp_FareAugmentationSegmentation tfa ON cp.CustomerID = tfa.CustomerID
	--  WHERE NUM_TRANSACTION_BY_CUSTOMER_24Mnths >= 3
	--	AND LatestTransaction = 1 
	--	AND tfa.IsVTECJourneyInd = 0
	--	AND NOT EXISTS (SELECT 1 
	--					  FROM temp_FareAugmentationSegmentation sub_tfa
	--					 WHERE sub_tfa.CustomerID = tfa.CustomerID
	--					   AND tfa.IsVTECJourneyInd = 1)

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - First time competitor booker - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL	

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Competitor  / VTEC mix - last 12mnths - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL		
	---- Competitor  / VTEC mix - last 12mnths
	--UPDATE cp
	--   SET CompetitorVTECMixLast12Mnths = CAST(1 AS BIT)
	--  FROM Staging.STG_CompetitorProgramme_DIM cp
	--	   INNER JOIN dbo.temp_FareAugmentationSegmentation tfa ON cp.CustomerID = tfa.CustomerID
	--  WHERE tfa.NUM_VTEC_JOURNEY_12Mnths > 2
	--	AND tfa.NUM_NO_VTEC_JOURNEY_12Mnths > 2

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Competitor  / VTEC mix - last 12mnths - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL	

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Competitor  / VTEC mix - last 24mnths - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL		
	---- Competitor  / VTEC mix - last 24mnths
	--UPDATE cp
	--   SET CompetitorVTECMixLast12Mnths = CAST(1 AS BIT)
	--  FROM Staging.STG_CompetitorProgramme_DIM cp
	--	   INNER JOIN dbo.temp_FareAugmentationSegmentation tfa ON cp.CustomerID = tfa.CustomerID
	--  WHERE tfa.NUM_VTEC_JOURNEY_13_24Mnths > 2
	--	AND tfa.NUM_VTEC_JOURNEY_13_24Mnths > 2

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Competitor  / VTEC mix - last 24mnths - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Competitor  / Else - START',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL
	---- Else
	--UPDATE cp
	--   SET AllElse = CAST(1 AS BIT)
	--  FROM Staging.STG_CompetitorProgramme_DIM cp
	--	   INNER JOIN dbo.temp_FareAugmentationSegmentation tfa ON cp.CustomerID = tfa.CustomerID
	--  WHERE cp.ConsistentCompetitorBooker12Mnths     = CAST(0 AS BIT)
	--	AND cp.ConsistentCompetitorBooker24Mnths     = CAST(0 AS BIT)
	--	AND cp.ConsistentCompetitorBooker            = CAST(0 AS BIT)
	--	AND cp.FirstTimeCompetitorBookerFirstBooking = CAST(0 AS BIT)
	--	AND cp.FirstTimeCompetitorBooker             = CAST(0 AS BIT)
	--	AND cp.CompetitorVTECMixLast12Mnths          = CAST(0 AS BIT)
	--	AND cp.CompetitorVTECMixLast24Mnths          = CAST(0 AS BIT)

	--EXEC [Operations].[LogMessage_Record] 
	--	@userid          = @userid,
	--	@logsource       = @spname,
	--	@logmessage      = 'Calculate Segments - Competitor  / Else - FINISH',
	--	@logmessagelevel = 'DEBUG',
	--	@messagetypecd   = NULL
    
	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Calculate Segments - FINISH',
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Cleaning unnecessary rows at CustomerID level - START',
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	--DELETE
	--  FROM Staging.STG_CompetitorProgramme_DIM 
	--  WHERE ConsistentCompetitorBooker12Mnths     = CAST(0 AS BIT)
	--	AND ConsistentCompetitorBooker24Mnths     = CAST(0 AS BIT)
	--	AND ConsistentCompetitorBooker            = CAST(0 AS BIT)
	--	AND FirstTimeCompetitorBookerFirstBooking = CAST(0 AS BIT)
	--	AND FirstTimeCompetitorBooker             = CAST(0 AS BIT)
	--	AND CompetitorVTECMixLast12Mnths          = CAST(0 AS BIT)
	--	AND CompetitorVTECMixLast24Mnths          = CAST(0 AS BIT)
	--	AND AllElse                               = CAST(0 AS BIT)

	--EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--									  @logsource       = @spname,
	--									  @logmessage      = 'Cleaning unnecessary rows at CustomerID level - FINISH',
	--									  @logmessagelevel = 'DEBUG',
	--									  @messagetypecd   = NULL

	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
										  @logsource       = @spname,
										  @logmessage      = 'Fare Augmentation Segmentation - CompetitorBooker process - FINISH',
										  @logmessagelevel = 'DEBUG',
										  @messagetypecd   = NULL

END