CREATE PROCEDURE [PreProcessing].[STG_Journey_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

--	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
--	                                     @logsource      = @spname,
--										 @logtimingidnew = @logtimingidnew OUTPUT

----OutBound - Singles

--    ;WITH CTE AS (
--        SELECT a.SalesDetailID
--              ,d.LocationID    AS [LocationIDOrigin_Out]
--              ,e.LocationID    AS [LocationIDDestination_Out]
--              ,a.OutTravelDate
--              ,DENSE_RANK() OVER (partition by b.BookingReference order by a.OutTravelDate) Ranking
--       FROM [Staging].[STG_SalesDetail] a
--	   INNER JOIN [Staging].[STG_SalesTransaction]   b ON a.SalesTransactionID = b.SalesTransactionID
--	   INNER JOIN [PreProcessing].[MSD_SalesOrder]   c ON CAST(c.SalesOrderId AS NVARCHAR(256)) = b.[ExtReference]
--	   LEFT JOIN  [Reference].[LocationAlias]        d ON d.Name = c.out_journeyorigin
--	   LEFT JOIN  [Reference].[LocationAlias]        e ON e.Name = c.out_journeydestination
--	   LEFT JOIN  [Staging].[STG_Journey]            f ON f.SalesDetailID = a.SalesDetailID
--	   WHERE a.IsTrainTicketInd = 1
--	   AND   c.out_journeyorigin IS NOT NULL
--	   AND   a.OutTravelDate IS NOT NULL
--	   AND   a.ReturnTravelDate IS NULL
--	   AND   a.IsReturnInferredInd = 0
--	   AND   c.DataImportDetailID = @dataimportdetailid
--	   AND   f.SalesDetailID IS NULL)

--    INSERT INTO [Staging].[STG_Journey]
--           ([CreatedDate]
--           ,[CreatedBy]
--           ,[LastModifiedDate]
--           ,[LastModifiedBy]
--           ,[ArchivedInd]
--           ,[SalesDetailID]
--           ,[LocationIDOrigin]
--           ,[LocationIDDestination]
--           ,[ECJourneyScore]
--           ,[DepartureDateTime]
--           ,[InferredDepartureInd]
--           ,[ArrivalDateTime]
--           ,[InferredArrivalInd]
--		   ,[IsOutboundInd])
--   SELECT GETDATE()
--         ,@userid
--		 ,GETDATE()
--		 ,@userid
--		 ,0
--		 ,SalesDetailID
--		 ,LocationIDOrigin_Out
--		 ,LocationIDDestination_Out
--		 ,0
--		 ,OutTravelDate
--		 ,0
--		 ,NULL
--		 ,0
--		 ,1
--   FROM CTE
--   WHERE Ranking = 1

----Return - Inferred Single

--   ;WITH CTE AS (
--        SELECT a.SalesDetailID
--              ,d.LocationID    AS [LocationIDOrigin_Out]
--              ,e.LocationID    AS [LocationIDDestination_Out]
--              ,a.OutTravelDate
--              ,DENSE_RANK() OVER (partition by b.BookingReference order by a.OutTravelDate) Ranking
--       FROM [Staging].[STG_SalesDetail] a
--	   INNER JOIN [Staging].[STG_SalesTransaction]   b ON a.SalesTransactionID = b.SalesTransactionID
--	   INNER JOIN [PreProcessing].[MSD_SalesOrder]   c ON CAST(c.SalesOrderId AS NVARCHAR(256)) = b.[ExtReference]
--	   LEFT JOIN  [Reference].[LocationAlias]        d ON d.Name = c.out_journeyorigin
--	   LEFT JOIN  [Reference].[LocationAlias]        e ON e.Name = c.out_journeydestination
--	   LEFT JOIN  [Staging].[STG_Journey]            f ON f.SalesDetailID = a.SalesDetailID
--	   WHERE a.IsTrainTicketInd = 1
--	   AND   c.out_journeyorigin IS NOT NULL
--	   AND   a.OutTravelDate IS NOT NULL
--	   AND   a.ReturnTravelDate IS NULL
--	   AND   a.IsReturnInferredInd = 0
--	   AND   c.DataImportDetailID = @dataimportdetailid
--	   AND   f.SalesDetailID IS NULL)

--    INSERT INTO [Staging].[STG_Journey]
--           ([CreatedDate]
--           ,[CreatedBy]
--           ,[LastModifiedDate]
--           ,[LastModifiedBy]
--           ,[ArchivedInd]
--           ,[SalesDetailID]
--           ,[LocationIDOrigin]
--           ,[LocationIDDestination]
--           ,[ECJourneyScore]
--           ,[DepartureDateTime]
--           ,[InferredDepartureInd]
--           ,[ArrivalDateTime]
--           ,[InferredArrivalInd]
--		   ,[IsReturnInd]
--		   ,[IsReturnInferredInd])
--   SELECT GETDATE()
--         ,@userid
--		 ,GETDATE()
--		 ,@userid
--		 ,0
--		 ,SalesDetailID
--		 ,LocationIDDestination_Out
--		 ,LocationIDOrigin_Out
--		 ,0
--		 ,OutTravelDate
--		 ,0
--		 ,NULL
--		 ,0
--		 ,0
--		 ,1
--   FROM CTE
--   WHERE Ranking = 1

----Returns - Outbound

--    INSERT INTO [Staging].[STG_Journey]
--           ([Name]
--           ,[Description]
--           ,[CreatedDate]
--           ,[CreatedBy]
--           ,[LastModifiedDate]
--           ,[LastModifiedBy]
--           ,[ArchivedInd]
--           ,[SalesDetailID]
--           ,[LocationIDOrigin]
--           ,[LocationIDDestination]
--           ,[ECJourneyScore]
--           ,[DepartureDateTime]
--           ,[InferredDepartureInd]
--           ,[ArrivalDateTime]
--           ,[InferredArrivalInd]
--		   ,[IsOutboundInd])
--     SELECT NULL
--           ,NULL
--           ,GETDATE()
--           ,@userid
--           ,GETDATE()
--           ,@userid
--           ,0
--           ,a.SalesDetailID
--           ,d.LocationID
--           ,e.LocationID
--           ,0
--           ,a.OutTravelDate
--           ,0
--           ,NULL
--           ,0
--		   ,1
--    FROM [Staging].[STG_SalesDetail] a
--	INNER JOIN [Staging].[STG_SalesTransaction]   b ON a.SalesTransactionID = b.SalesTransactionID
--	INNER JOIN [PreProcessing].[MSD_SalesOrder]   c ON CAST(c.SalesOrderId AS NVARCHAR(256)) = b.[ExtReference]
--	LEFT JOIN  [Reference].[LocationAlias]        d ON d.Name = c.out_journeyorigin
--	LEFT JOIN  [Reference].[LocationAlias]        e ON e.Name = c.out_journeydestination
--	LEFT JOIN  [Staging].[STG_Journey]            f ON f.SalesDetailID = a.SalesDetailID
--	WHERE a.IsTrainTicketInd = 1
--	AND   c.out_journeyorigin IS NOT NULL
--	AND   a.OutTravelDate IS NOT NULL
--	AND   a.ReturnTravelDate IS NOT NULL
--	AND   a.IsReturnInferredInd = 0
--	AND   c.DataImportDetailID = @dataimportdetailid
--	AND   f.SalesDetailID IS NULL

----Returns - Return

--    INSERT INTO [Staging].[STG_Journey]
--           ([Name]
--           ,[Description]
--           ,[CreatedDate]
--           ,[CreatedBy]
--           ,[LastModifiedDate]
--           ,[LastModifiedBy]
--           ,[ArchivedInd]
--           ,[SalesDetailID]
--           ,[LocationIDOrigin]
--           ,[LocationIDDestination]
--           ,[ECJourneyScore]
--           ,[DepartureDateTime]
--           ,[InferredDepartureInd]
--           ,[ArrivalDateTime]
--           ,[InferredArrivalInd]
--		   ,[IsReturnInd])
--     SELECT NULL
--           ,NULL
--           ,GETDATE()
--           ,@userid
--           ,GETDATE()
--           ,@userid
--           ,0
--           ,a.SalesDetailID
--           ,d.LocationID
--           ,e.LocationID
--           ,0
--           ,CASE WHEN a.IsReturnInferredInd = 1 THEN a.OutTravelDate
--		                                        ELSE a.ReturnTravelDate
--            END
--           ,0
--           ,NULL
--           ,0
--		   ,1
--    FROM [Staging].[STG_SalesDetail] a
--	INNER JOIN [Staging].[STG_SalesTransaction]   b ON a.SalesTransactionID = b.SalesTransactionID
--	INNER JOIN [PreProcessing].[MSD_SalesOrder]   c ON CAST(c.SalesOrderId AS NVARCHAR(256)) = b.[ExtReference]
--	LEFT JOIN  [Reference].[LocationAlias]        d ON d.Name = c.out_journeydestination
--	LEFT JOIN  [Reference].[LocationAlias]        e ON e.Name = c.out_journeyorigin
--	LEFT JOIN  [Staging].[STG_Journey]            f ON f.SalesDetailID = a.SalesDetailID
--    LEFT JOIN  [Staging].[STG_Journey]            g ON g.SalesDetailID = a.SalesDetailID AND f.JourneyID != g.JourneyID
--	WHERE a.IsTrainTicketInd = 1
--	AND   a.ReturnTravelDate IS NOT NULL
--    AND   f.IsOutboundInd = 1
--	AND   g.SalesDetailID IS NULL
--	AND   c.DataImportDetailID = @dataimportdetailid

--    --Log end time

--	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
--	                                     @logsource      = @spname,
--										 @logtimingid    = @logtimingidnew,
--										 @recordcount    = @recordcount,
--										 @logtimingidnew = @logtimingidnew OUTPUT
--	RETURN 
END