
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Railtimetable].[Update_Journeys] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @RECORDS INT;

-- Merge three journey stage tables into one
SELECT  [rid]
      ,[uid]
      ,[trainId]
      ,[ssd]
      ,[toc]
      ,[trainCat]
      ,isnull([isPassengerSvc],'true') [isPassengerSvc]
	  ,Stage
      ,[tpl]
      ,[act]
      ,[plat]
      ,[pta]
      ,[ptd]
      ,[wta]
      ,[wtd]
      ,[cancelReason]
INTO #TempJourney
FROM (
SELECT  [rid]
      ,[uid]
      ,[trainId]
      ,[ssd]
      ,[toc]
      ,[trainCat]
      ,[isPassengerSvc]
	  ,'IP' AS Stage
      ,[tpl]
      ,[act]
      ,[plat]
      ,[pta]
      ,[ptd]
      ,[wta]
      ,[wtd]
      ,[cancelReason]
  FROM [Railtimetable].[JourneyIP]
  UNION ALL
SELECT  [rid]
      ,[uid]
      ,[trainId]
      ,[ssd]
      ,[toc]
      ,[trainCat]
      ,[isPassengerSvc]
	  ,'OR' AS Stage
      ,[tpl]
      ,[act]
      ,[plat]
	  ,'' AS [pta]
      ,[ptd]
	  ,'' AS [wta]
      ,[wtd]
      ,[cancelReason]
  FROM [Railtimetable].[JourneyOR]
  UNION ALL
  SELECT  [rid]
      ,[uid]
      ,[trainId]
      ,[ssd]
      ,[toc]
      ,[trainCat]
      ,[isPassengerSvc]
	  ,'DT' AS Stage
      ,[tpl]
      ,[act]
      ,[plat]
      ,[pta]
      ,'' AS [ptd]
	  ,[wta]
	  ,'' AS [wtd]
      ,[cancelReason]
  FROM [Railtimetable].[JourneyDT] ) a

SET @RECORDS = (SELECT COUNT(*) FROM #TempJourney)

PRINT N'Number of records ' + CAST( @RECORDS as nvarchar(8));

UPDATE TimeTableLog 
SET Records_Added = @RECORDS
WHERE Records_Added is null

-- remove previous entries on existing rid in new load
 DELETE a 
 FROM  JourneyStages a
 INNER JOIN ( SELECT rid
  FROM #TempJourney
  GROUP BY rid) b
  ON a.rid = b.rid

-- Get latest timetableID
DECLARE @TimeTableID varchar(20);

SET @TimeTableID = (SELECT TOP 1 SUBSTRING(TimeTable, CHARINDEX('=',TimeTable,1) +2,14) AS ID
FROM TimeTableLog
ORDER BY logdate DESC)

PRINT N'TimeTableId ' + @TimeTableID

-- Insert all new Journey records
INSERT INTO JourneyStages
([rid]
      ,[uid]
      ,[trainId]
      ,[ssd]
      ,[toc]
      ,[trainCat]
      ,[isPassengerSvc]
	  ,Stage
      ,[tpl]
      ,[act]
      ,[plat]
      ,[pta]
      ,[ptd]
      ,[wta]
      ,[wtd]
      ,[cancelReason]
	  ,[TimeTableID]
	  ,[LocationID]
)
SELECT  [rid]
      ,[uid]
      ,[trainId]
      ,[ssd]
      ,[toc]
      ,[trainCat]
      ,[isPassengerSvc]
	  ,Stage
      ,[tpl]
      ,[act]
      ,[plat]
      ,[pta]
      ,[ptd]
      ,[wta]
      ,[wtd]
      ,[cancelReason]
	  ,@TimeTableID AS [TimeTableID]
	  ,l.[LocationID]
FROM #TempJourney t
left join [Reference].[Location] l on t.tpl=l.tiploc

DROP TABLE #TempJourney

END

---