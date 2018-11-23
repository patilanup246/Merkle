
CREATE PROCEDURE [Production].[Customer_RFV_Update]
(
    @userid         INTEGER = 0,
    @today          DATE    = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @segmentid              INTEGER

    DECLARE @spname                 NVARCHAR(256)
    DECLARE @recordcount            INTEGER
    DECLARE @logtimingidnew         INTEGER
    DECLARE @logmessage             NVARCHAR(MAX)

    SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    --Log start time--

    EXEC [Operations].[LogTiming_Record] @userid         = @userid,
                                         @logsource      = @spname,
                                         @logtimingidnew = @logtimingidnew OUTPUT

--    CREATE TABLE #tmp_segment(
--        CustomerID                       INTEGER,
--        SegmentID                        INTEGER,
--        DateLastResponded                DATE,
--        DateLastTravelled                DATE,
--        DateLastPurchased                DATE,
--        NoJourneysLast12Mnths            INTEGER,
--        NoJourneysPrevious12Mnths        INTEGER,
--        NoTransactionsLast12Mnths        INTEGER,
--        NoTransactionsPrevious12Mnths    INTEGER,
--        SalesAmountLast3Mnths            DECIMAL(14,2),
--        SalesAmountLast12Mnths           DECIMAL(14,2),
--        SalesAmountPrevious12Mnths       DECIMAL(14,2),
--        Segmented                        VARCHAR(1)
--)
--    IF @today IS NULL
--    BEGIN
--        SELECT @today = CAST(GETDATE() AS DATE)
--    END

--    INSERT INTO #tmp_segment
--       (CustomerID,
--        NoJourneysLast12Mnths,
--        NoJourneysPrevious12Mnths,
--        NoTransactionsLast12Mnths,
--        NoTransactionsPrevious12Mnths,
--        SalesAmountLast3Mnths,
--        SalesAmountLast12Mnths,
--        SalesAmountPrevious12Mnths,
--        Segmented
--        )
--    SELECT CustomerID,
--           0,0,0,0,0,0,0, 'N'
--    FROM   Production.Customer

--    -- TODO Need to include CRM Contact History in this as well
--    UPDATE a
--    SET DateLastResponded = sub.LastResponseDate
--    FROM #tmp_segment a
--    INNER JOIN (select a.customerid, max(a.Response_Date) as LastResponseDate
--    from (
--    select customerid, EventTimeStamp as Response_Date
--    from dbo.SP_Open
--    where EventTimeStamp <= getdate()
--    union
--    select customerid, EventTimeStamp as Response_Date
--    from dbo.SP_Click
--    where EventTimeStamp <= getdate()
--    union
--    SELECT CustomerID, ResponseDate AS Response_Date
--    FROM Production.LegacyCampaignResponse
--    WHERE ResponseCodeID IN (1,2) and ResponseDate <= getdate() ) a
--    group by a.customerid ) sub on a.CustomerID = sub.CustomerID

--	--THIS IS A TEMPORAY SOLUTION

--	UPDATE a
--	SET DateLastResponded = b.LastRespondDate
--    FROM #tmp_segment a,
--	     Migration.Zeta_Customer_MigrationInfo b,
--		 Staging.STG_KeyMapping c
--    WHERE a.CustomerID = c.CustomerID
--	AND   b.ZetaCustomerID = c.ZetaCustomerID
--	AND   a.DateLastResponded IS NULL

--    UPDATE a
--    SET DateLastTravelled = f.ReqDate
--    FROM  #tmp_segment a
--    INNER JOIN (SELECT b.CustomerID,MAX(c.OutTravelDate) As ReqDate
--                FROM Staging.STG_SalesTransaction b,
--                     Staging.STG_SalesDetail c
--                WHERE b.SalesTransactionID = c.SalesTransactionID
--                AND   c.IsTrainTicketInd = 1
--                AND   c.OutTravelDate <= @today
--                GROUP BY b.CustomerID) f ON a.CustomerID = f.CustomerID

--    UPDATE a
--    SET DateLastPurchased = f.ReqDate
--    FROM #tmp_segment a
--    INNER JOIN (SELECT b.CustomerID,MAX(SalesTransactionDate) AS ReqDate
--                FROM   Staging.STG_SalesTransaction b
--                WHERE  b.SalesTransactionDate <= @today
--                GROUP BY b.CustomerID) f ON a.CustomerID = f.CustomerID

--    --For customers who where there are no transactions information for those prior to MSD

--    UPDATE a
--    SET DateLastPurchased = b.DateLastPurchase
--    FROM #tmp_segment a,
--	     Staging.STG_Customer b
--    WHERE a.CustomerID = b.CustomerID
--	AND   a.DateLastPurchased IS NULL

--    UPDATE a
--    SET NoJourneysLast12Mnths = COALESCE(f.NoofJourneys_L12M, 0),
--        NoJourneysPrevious12Mnths = COALESCE(f.NoofJourneys_P12M, 0)
--    FROM #tmp_segment a
--    INNER JOIN (SELECT b.CustomerID,
--                  COUNT(distinct CASE WHEN cast(bb.OutTravelDate as date)> DATEADD(YY,-1,@today)
--                                 THEN b.SalesTransactionID END) AS NoofJourneys_L12M,
--                  COUNT(distinct CASE WHEN cast(bb.OutTravelDate as date) > DATEADD(YY,-2,@today) AND cast(bb.OutTravelDate as date) <= DATEADD(YY,-1,@today)
--                                 THEN b.SalesTransactionID END) AS NoofJourneys_P12M
--                FROM Staging.STG_SalesTransaction b
--                INNER JOIN (SELECT SalesTransactionID, OutTravelDate
--                           FROM   Staging.STG_SalesDetail c
--                           WHERE  c.IsTrainTicketInd = 1
--                           AND    cast(c.OutTravelDate as date) > DATEADD(YY,-2,@today)
--                                  -- We are allowing future travel dates to count as a journey taken.
--                           GROUP BY SalesTransactionID, OutTravelDate) bb ON b.SalesTransactionID = bb.SalesTransactionID
--            GROUP BY b.CustomerID) f ON a.CustomerID = f.CustomerID

--    UPDATE a
--    SET NoTransactionsLast12Mnths = COALESCE(f.NoofTrans_L12M, 0),
--        NoTransactionsPrevious12Mnths = COALESCE(f.NoofTrans_P12M, 0)
--    FROM #tmp_segment a
--    INNER JOIN (SELECT b.CustomerID,
--                  COUNT(distinct CASE WHEN cast(b.SalesTransactionDate as date) > DATEADD(YY,-1,@today) and cast(b.SalesTransactionDate as date) <= @today
--                                      THEN b.SalesTransactionID END) AS NoofTrans_L12M,
--                  COUNT(distinct CASE WHEN cast(b.SalesTransactionDate as date) > DATEADD(YY,-2,@today) AND cast(b.salestransactiondate as date) <= DATEADD(YY,-1,@today)
--                                      THEN b.SalesTransactionID END) AS NoofTrans_P12M
--                FROM Staging.STG_SalesTransaction b
--                WHERE cast(b.SalesTransactionDate as date) > DATEADD(YY,-2,@today)
--            GROUP BY b.CustomerID) f ON a.CustomerID = f.CustomerID

--    UPDATE a
--    SET    SalesAmountLast3Mnths = COALESCE(f.RailSales_L3M, 0),
--           SalesAmountLast12Mnths = COALESCE(f.RailSales_L12M, 0),
--           SalesAmountPrevious12Mnths = COALESCE(f.RailSales_P12M, 0)
--    FROM   #tmp_segment a
--    INNER JOIN (SELECT b.CustomerID,
--                       SUM(CASE WHEN cast(b.SalesTransactionDate as date) > DATEADD(M,-3,@today) and cast(b.SalesTransactionDate as date) <= @today
--                         THEN (b.SalesAmountRail + b.SalesAmountNotRail) ELSE 0 END )AS RailSales_L3M,
--                       SUM(CASE WHEN cast(b.SalesTransactionDate as date) > DATEADD(YY,-1,@today) and cast(b.SalesTransactionDate as date) <= @today
--                         THEN (b.SalesAmountRail + b.SalesAmountNotRail) ELSE 0 END )AS RailSales_L12M,
--                       SUM(CASE WHEN cast(b.SalesTransactionDate as date)> DATEADD(YY,-2,@today) AND cast(b.salestransactiondate as date) <= DATEADD(YY,-1,@today)
--                         THEN (b.SalesAmountRail + b.SalesAmountNotRail) ELSE 0 END )AS RailSales_P12M
--                FROM   [Staging].[STG_SalesTransaction] b
--                WHERE  cast(b.SalesTransactionDate as date) > DATEADD(YY,-2,@today)
--                GROUP  BY b.CustomerID) f ON  a.CustomerID = f.CustomerID

---- SET THE SEGMENTATION TIERS

---- RECENT HIGH VALUE BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Recent High Value Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE DateLastPurchased >= DATEADD(M,-3,@today) and DateLastPurchased <= @today
--    AND   SalesAmountLast12Mnths > 1200
--    and   segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- LAPSED HIGH VALUE BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--   WHERE  Name = 'Lapsed High Value Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE DateLastPurchased < DATEADD(M,-3,@today)
--    AND   SalesAmountLast12Mnths > 1200
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- LOW VALUE BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Low Value Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE NoTransactionsLast12Mnths > 0
--    AND   SalesAmountLast12Mnths >=0 AND SalesAmountLast12Mnths < 10
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- ACTIVE REPEAT BOOKER £500
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Active Repeat Booker £500'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE (NoTransactionsLast12Mnths > 1
--            OR NoJourneysLast12Mnths > 1)
--    AND    SalesAmountLast12Mnths >= 500
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- ACTIVE REPEAT BOOKER £250-499
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Active Repeat Booker £250-499'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE (NoTransactionsLast12Mnths > 1 OR NoJourneysLast12Mnths > 1)
--    AND    (SalesAmountLast12Mnths >= 250 AND SalesAmountLast12Mnths < 500)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- ACTIVE REPEAT BOOKER <250
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Active Repeat Booker < £250'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE (NoTransactionsLast12Mnths > 1 OR NoJourneysLast12Mnths > 1)
--        AND
--          (SalesAmountLast12Mnths >= 0 AND SalesAmountLast12Mnths < 250)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- ACTIVE SINGLE BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Active Single Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE (NoTransactionsLast12Mnths + NoTransactionsPrevious12Mnths = 1)
----          AND NoJourneysLast12Mnths > 0  REMOVED 17-10-2016 as we find some customers with transactions but no Outbound Journey Date
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- DECLINING REPEAT BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Declining Repeat Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE (NoTransactionsLast12Mnths = 1 or a.NoJourneysLast12Mnths = 1)
--          AND (NoTransactionsPrevious12Mnths > 1 or NoJourneysPrevious12Mnths >1)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- STABLE SINGLE BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Stable Single Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE (NoTransactionsLast12Mnths = 1 AND NoTransactionsPrevious12Mnths = 1)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- LAPSED REPEAT BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Lapsed Repeat Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE (NoTransactionsLast12Mnths = 0 OR NoTransactionsLast12Mnths IS NULL)
--    AND   (NoJourneysPrevious12Mnths > 1 OR NoTransactionsPrevious12Mnths > 1)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

-- -- LAPSED SINGLE BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Lapsed Single Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE (NoTransactionsLast12Mnths = 0 OR NoTransactionsLast12Mnths IS NULL)
--    AND  (NoJourneysPrevious12Mnths = 1 OR NoTransactionsPrevious12Mnths = 1)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- RECENT PROSPECT
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Recent Prospect'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a,
--         Staging.STG_Customer b
--    WHERE a.CustomerID = b.CustomerID
--    AND   a.DateLastPurchased IS NULL
--    AND   b.SourceModifiedDate >= DATEADD(M,-3,@today)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- OLD PROSPECT
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Old Prospect'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a,
--         Staging.STG_Customer b
--    WHERE a.CustomerID = b.CustomerID
--    AND   a.DateLastPurchased IS NULL
--    AND   b.SourceModifiedDate BETWEEN DATEADD(M,-12,@today) AND DATEADD(M,-3,@today)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- DEADWOOD BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Deadwood Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE a.DateLastPurchased <= DATEADD(YY,-2,@today)
--    AND   (a.DateLastTravelled   <= DATEADD(YY,-2,@today) OR a.DateLastTravelled is null)
--    AND   a.DateLastResponded IS NULL
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- HISTORIC BOOKER
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Historic Booker'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a
--    WHERE a.DateLastPurchased <= DATEADD(YY,-2,@today)
--    AND   (a.DateLastTravelled   <= DATEADD(YY,-2,@today) OR a.DateLastTravelled is null)
----    AND   a.DateLastResponded   >= DATEADD(YY,-2,@today)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- DEADWOOD PROSPECT
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Deadwood Prospect'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a,
--         Staging.STG_Customer b
--    WHERE a.CustomerID = b.CustomerID
--    AND a.DateLastPurchased IS NULL
--    AND   b.SourceModifiedDate <= DATEADD(YY,-2,@today)
--    AND   a.DateLastResponded IS NULL
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

---- HISTORIC PROSPECT
--    SELECT @segmentid = SegmentTierID
--    FROM   Reference.SegmentTier
--    WHERE  Name = 'Historic Prospect'

--    UPDATE a
--    SET    SegmentID = @segmentid
--    FROM #tmp_segment a,
--         Staging.STG_Customer b
--    WHERE a.CustomerID = b.CustomerID
--    AND a.DateLastPurchased IS NULL
--    AND   b.SourceModifiedDate <= DATEADD(YY,-1,@today)
--    AND   Segmented = 'N'

--    UPDATE a
--    SET   Segmented = 'Y'
--    FROM #tmp_segment a
--    WHERE SegmentID = @segmentid

----   -- CREATE A SEGMENTATION SUMMARY TABLE
----     IF OBJECT_ID('CRM.Production.Cust_RFV_Summary', 'U') IS NOT NULL
----       DROP TABLE CRM.Production.Cust_RFV_Summary
---- 
----     SELECT a.*, b.LastModifiedDate, b.SourceModifiedDate
----     INTO CRM.Production.Cust_RFV_Summary
----     FROM #tmp_segment a left join
----          Staging.STG_Customer b
----     on a.CustomerID = b.CustomerID

--    -- CLEAR EXISTING SEGMENTATION
--    UPDATE [Production].[Customer] SET SegmentTierID = null;

--    UPDATE cus
--    SET cus.SegmentTierID = tmp.SegmentID
--    FROM Production.Customer cus INNER JOIN #tmp_segment tmp ON cus.CustomerID = tmp.customerid
--    WHERE tmp.SegmentID <= 17; -- this ensures we're only populating Segments which are included in the Segment reference table

--    --Log end time

    EXEC [Operations].[LogTiming_Record] @userid         = @userid,
                                         @logsource      = @spname,
                                         @logtimingid    = @logtimingidnew,
                                         @recordcount    = @recordcount,
                                         @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END