CREATE PROCEDURE [Production].[Individual_RFV_Update_2]
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

    --SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    ----Log start time--

    --EXEC [Operations].[LogTiming_Record] @userid         = @userid,
    --                                     @logsource      = @spname,
    --                                     @logtimingidnew = @logtimingidnew OUTPUT

    CREATE TABLE #tmp_segment(
        IndividualID                     INTEGER,
        SegmentID                        INTEGER,
        DateLastResponded                DATE,
        DateLastTravelled                DATE,
        DateLastPurchased                DATE,
        NoJourneysLast12Mnths            INTEGER,
        NoJourneysPrevious12Mnths        INTEGER,
        NoTransactionsLast12Mnths        INTEGER,
        NoTransactionsPrevious12Mnths    INTEGER,
        SalesAmountLast3Mnths            DECIMAL(14,2),
        SalesAmountLast12Mnths           DECIMAL(14,2),
        SalesAmountPrevious12Mnths       DECIMAL(14,2),
        Segmented                        VARCHAR(1)
)
    IF @today IS NULL
    BEGIN
        SELECT @today = CAST(GETDATE() AS DATE)
    END

    INSERT INTO #tmp_segment
       (IndividualID,
        NoJourneysLast12Mnths,
        NoJourneysPrevious12Mnths,
        NoTransactionsLast12Mnths,
        NoTransactionsPrevious12Mnths,
        SalesAmountLast3Mnths,
        SalesAmountLast12Mnths,
        SalesAmountPrevious12Mnths,
        Segmented
        )
    SELECT IndividualID,
           0,0,0,0,0,0,0, 'N'
    FROM   Production.Individual


    UPDATE a
    SET DateLastResponded = sub.LastResponseDate
    FROM #tmp_segment a
    INNER JOIN (select a.IndividualID, max(a.Response_Date) as LastResponseDate
    from (
--     select IndividualID, EventTimeStamp as Response_Date
--     from emm_sys.dbo.SP_Open
--     where EventTimeStamp <= getdate()
--     union
--     select IndividualID, EventTimeStamp as Response_Date
--     from emm_sys.dbo.SP_Click
--     where EventTimeStamp <= getdate()
--     union
    SELECT IndividualID, ResponseDate AS Response_Date
    FROM Production.LegacyCampaignResponse
    WHERE ResponseCodeID IN (1,2) and ResponseDate <= getdate() ) a
    group by a.IndividualID ) sub on a.IndividualID = sub.IndividualID


    UPDATE a
    SET DateLastTravelled = f.ReqDate
    FROM  #tmp_segment a
    INNER JOIN (SELECT b.IndividualID,MAX(c.OutTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
                     Staging.STG_SalesDetail c
                WHERE b.SalesTransactionID = c.SalesTransactionID
                AND   c.IsTrainTicketInd = 1
                AND   c.OutTravelDate <= @today
                GROUP BY b.IndividualID) f ON a.IndividualID = f.IndividualID

    UPDATE a
    SET DateLastPurchased = f.ReqDate
    FROM #tmp_segment a
    INNER JOIN (SELECT b.IndividualID,MAX(SalesTransactionDate) AS ReqDate
                FROM   Staging.STG_SalesTransaction b
                WHERE  b.SalesTransactionDate <= @today
                GROUP BY b.IndividualID) f ON a.IndividualID = f.IndividualID

    UPDATE a
    SET NoJourneysLast12Mnths = COALESCE(f.NoofJourneys_L12M, 0),
        NoJourneysPrevious12Mnths = COALESCE(f.NoofJourneys_P12M, 0)
    FROM #tmp_segment a
    INNER JOIN (SELECT b.IndividualID,
                  COUNT(distinct CASE WHEN bb.OutTravelDate > DATEADD(YY,-1,@today)
                                 THEN BookingReference END) AS NoofJourneys_L12M,
                  COUNT(distinct CASE WHEN bb.OutTravelDate > DATEADD(YY,-2,@today) AND bb.OutTravelDate <= DATEADD(YY,-1,@today)
                                 THEN BookingReference END) AS NoofJourneys_P12M
                FROM Staging.STG_SalesTransaction b
                INNER JOIN (SELECT SalesTransactionID, OutTravelDate
                           FROM   Staging.STG_SalesDetail c
                           WHERE  c.IsTrainTicketInd = 1
                           AND    c.OutTravelDate > DATEADD(YY,-2,@today)
                                  -- We are allowing future travel dates to count as a journey taken.
                           GROUP BY SalesTransactionID, OutTravelDate) bb ON b.SalesTransactionID = bb.SalesTransactionID
            GROUP BY b.IndividualID) f ON a.IndividualID = f.IndividualID

    UPDATE a
    SET NoTransactionsLast12Mnths = COALESCE(f.NoofTrans_L12M, 0),
        NoTransactionsPrevious12Mnths = COALESCE(f.NoofTrans_P12M, 0)
    FROM #tmp_segment a
    INNER JOIN (SELECT b.IndividualID,
                  COUNT(distinct CASE WHEN b.SalesTransactionDate > DATEADD(YY,-1,@today) and b.SalesTransactionDate <= @today
                                      THEN b.BookingReference END) AS NoofTrans_L12M,
                  COUNT(distinct CASE WHEN b.SalesTransactionDate > DATEADD(YY,-2,@today) AND b.salestransactiondate <= DATEADD(YY,-1,@today)
                                      THEN b.BookingReference END) AS NoofTrans_P12M
                FROM Staging.STG_SalesTransaction b
                WHERE b.SalesTransactionDate > DATEADD(YY,-2,@today)
            GROUP BY b.IndividualID) f ON a.IndividualID = f.IndividualID

    UPDATE a
    SET    SalesAmountLast3Mnths = COALESCE(f.RailSales_L3M, 0),
           SalesAmountLast12Mnths = COALESCE(f.RailSales_L12M, 0),
           SalesAmountPrevious12Mnths = COALESCE(f.RailSales_P12M, 0)
    FROM   #tmp_segment a
    INNER JOIN (SELECT b.IndividualID,
                       SUM(CASE WHEN b.SalesTransactionDate > DATEADD(M,-3,@today) and b.SalesTransactionDate <= @today
                         THEN (b.SalesAmountRail + b.SalesAmountNotRail) ELSE 0 END )AS RailSales_L3M,
                       SUM(CASE WHEN b.SalesTransactionDate > DATEADD(YY,-1,@today) and b.SalesTransactionDate <= @today
                         THEN (b.SalesAmountRail + b.SalesAmountNotRail) ELSE 0 END )AS RailSales_L12M,
                       SUM(CASE WHEN b.SalesTransactionDate > DATEADD(YY,-2,@today) AND b.salestransactiondate <= DATEADD(YY,-1,@today)
                         THEN (b.SalesAmountRail + b.SalesAmountNotRail) ELSE 0 END )AS RailSales_P12M
                FROM   [Staging].[STG_SalesTransaction] b
                WHERE  b.SalesTransactionDate > DATEADD(YY,-2,@today)
                GROUP  BY b.IndividualID) f ON  a.IndividualID = f.IndividualID

-- SET THE SEGMENTATION TIERS

-- RECENT HIGH VALUE BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Recent High Value Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE DateLastPurchased >= DATEADD(M,-3,@today) and DateLastPurchased <= @today       -- ADDED "TODAY" LIMITING CONDITION
--     WHERE DateLastPurchased >= DATEADD(D,-90,@today) and DateLastPurchased <= @today       -- ADDED "TODAY" LIMITING CONDITION
    AND   SalesAmountLast12Mnths > 1200
    and   segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- LAPSED HIGH VALUE BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Lapsed High Value Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE DateLastPurchased < DATEADD(M,-3,@today)
--     WHERE DateLastPurchased < DATEADD(D,-90,@today)
    AND   SalesAmountLast12Mnths > 1200
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid


-- LOW VALUE BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Low Value Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE NoTransactionsLast12Mnths > 0
    AND   SalesAmountLast12Mnths >=0 AND SalesAmountLast12Mnths < 10        -- CHANGED FROM >0
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- ACTIVE REPEAT BOOKER £500
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Active Repeat Booker £500'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE (NoTransactionsLast12Mnths > 1
            OR NoJourneysLast12Mnths > 1)
    AND    SalesAmountLast12Mnths >= 500
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- ACTIVE REPEAT BOOKER £250-499
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Active Repeat Booker £250-499'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE (NoTransactionsLast12Mnths > 1 OR NoJourneysLast12Mnths > 1)
    AND    (SalesAmountLast12Mnths >= 250 AND SalesAmountLast12Mnths < 500)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- ACTIVE REPEAT BOOKER <250
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Active Repeat Booker < £250'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE (NoTransactionsLast12Mnths > 1 OR NoJourneysLast12Mnths > 1)
        AND
          (SalesAmountLast12Mnths >= 0 AND SalesAmountLast12Mnths < 250)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- ACTIVE SINGLE BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Active Single Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE (NoTransactionsLast12Mnths + NoTransactionsPrevious12Mnths = 1)
         AND NoJourneysLast12Mnths > 0
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- DECLINING REPEAT BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Declining Repeat Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE (NoTransactionsLast12Mnths = 1 or a.NoJourneysLast12Mnths = 1)
          AND (NoTransactionsPrevious12Mnths > 1 or NoJourneysPrevious12Mnths >1)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- STABLE SINGLE BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Stable Single Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE (NoTransactionsLast12Mnths = 1 AND NoTransactionsPrevious12Mnths = 1)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- LAPSED REPEAT BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Lapsed Repeat Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE (NoTransactionsLast12Mnths = 0 OR NoTransactionsLast12Mnths IS NULL)
    AND   (NoJourneysPrevious12Mnths > 1 OR NoTransactionsPrevious12Mnths > 1)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

 -- LAPSED SINGLE BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Lapsed Single Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE (NoTransactionsLast12Mnths = 0 OR NoTransactionsLast12Mnths IS NULL)
    AND  (NoJourneysPrevious12Mnths = 1 OR NoTransactionsPrevious12Mnths = 1)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- RECENT PROSPECT
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Recent Prospect'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a,
         Staging.STG_Individual b
    WHERE a.IndividualID = b.IndividualID
    AND   a.DateLastPurchased IS NULL
    AND   b.SourceModifiedDate >= DATEADD(M,-3,@today)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- OLD PROSPECT
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Old Prospect'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a,
         Staging.STG_Individual b
    WHERE a.IndividualID = b.IndividualID
    AND   a.DateLastPurchased IS NULL
    AND   b.SourceModifiedDate BETWEEN DATEADD(M,-12,@today) AND DATEADD(M,-3,@today)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- DEADWOOD BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Deadwood Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE a.DateLastPurchased <= DATEADD(YY,-2,@today)
    AND   (a.DateLastTravelled   <= DATEADD(YY,-2,@today) OR a.DateLastTravelled is null)
    AND   a.DateLastResponded IS NULL
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- HISTORIC BOOKER
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Historic Booker'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a
    WHERE a.DateLastPurchased <= DATEADD(YY,-2,@today)
    AND  (a.DateLastTravelled   <= DATEADD(YY,-2,@today) OR a.DateLastTravelled is null)
    AND   a.DateLastResponded   >= DATEADD(YY,-2,@today)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- DEADWOOD PROSPECT
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Deadwood Prospect'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a,
         Staging.STG_Individual b
    WHERE a.IndividualID = b.IndividualID
    AND a.DateLastPurchased IS NULL
    AND   b.SourceModifiedDate <= DATEADD(YY,-2,@today)
    AND   a.DateLastResponded IS NULL
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

-- HISTORIC PROSPECT
    SELECT @segmentid = SegmentTierID
    FROM   Reference.SegmentTier
    WHERE  Name = 'Historic Prospect'

    UPDATE a
    SET    SegmentID = @segmentid
    FROM #tmp_segment a,
         Staging.STG_Individual b
    WHERE a.IndividualID = b.IndividualID
    AND a.DateLastPurchased IS NULL
    AND   b.SourceModifiedDate <= DATEADD(YY,-1,@today)
    AND   Segmented = 'N'

    UPDATE a
    SET   Segmented = 'Y'
    FROM #tmp_segment a
    WHERE SegmentID = @segmentid

	select * from #tmp_segment

    RETURN
END