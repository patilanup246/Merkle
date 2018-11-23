CREATE PROCEDURE [Production].[Individual_CustomerType_Update]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @today                    DATE
    DECLARE @CustomerTypeID           INTEGER

	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	CREATE TABLE #tmp_type(
        IndividualID                       INTEGER,
        NoTransactionsLast12Mnths        INTEGER,
        NoTransactionsPrevious12Mnths    INTEGER,
)
    IF @today IS NULL
    BEGIN
        SELECT @today = CAST(GETDATE() AS DATE)
    END

    INSERT INTO #tmp_type
       (IndividualID,
        NoTransactionsLast12Mnths,
        NoTransactionsPrevious12Mnths
        )
    SELECT IndividualID,
           0,0
    FROM   Production.Individual

    UPDATE a
    SET NoTransactionsLast12Mnths = COALESCE(f.NoofTrans_L12M, 0)
    FROM #tmp_type a
    INNER JOIN (SELECT b.IndividualID,
                  COUNT(distinct CASE WHEN b.SalesTransactionDate > DATEADD(YY,-1,@today) and b.SalesTransactionDate <= @today
                                      THEN b.BookingReference END) AS NoofTrans_L12M
                FROM Staging.STG_SalesTransaction b
                WHERE b.SalesTransactionDate > DATEADD(YY,-2,@today)
            GROUP BY b.IndividualID) f ON a.IndividualID = f.IndividualID

    --CHANGE ME
	SELECT @today = CAST(GETDATE() AS DATE)--CAST('2016-05-16 12:17:29.000' AS date)

-- CLEAR THE EXISTING Individual TYPE
    UPDATE [Production].[Individual] SET CustomerTypeID = null;

--IndividualS
    -- Day of travel
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Individual','Day of travel')

	IF @CustomerTypeID IS NOT NULL
	BEGIN
	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
	    WHERE  CAST(DateNextTravelAny AS DATE) = @today and CustomerTypeID is null
    END

	-- Previously Lapsed Individual
	SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Individual','Previously Lapsed Individual')

	IF @CustomerTypeID IS NOT NULL
	BEGIN
		UPDATE cus
		SET	   CustomerTypeID = @CustomerTypeID
		from Production.Individual cus inner join
		(
		select b.IndividualID, b.SalesTransactionDate, row_number() over (partition by b.Individualid order by b.salestransactiondate desc) as rownum
		from Staging.STG_SalesTransaction b
		group by b.IndividualID, b.SalesTransactionDate) last_trans on cus.Individualid = last_trans.Individualid

		inner join
		(
		select b.IndividualID, b.SalesTransactionDate, row_number() over (partition by b.Individualid order by b.salestransactiondate desc) as rownum
		from Staging.STG_SalesTransaction b
		group by b.IndividualID, b.SalesTransactionDate) prev_trans on cus.IndividualID = prev_trans.IndividualID
		where last_trans.rownum = 1 and prev_trans.rownum = 2
		  and cus.DateNextTravelAny > GETDATE()
		  and DATEDIFF(MM, prev_trans.SalesTransactionDate, last_trans.SalesTransactionDate) >= 12
		  and cus.CustomerTypeID is null
	END

    -- Pre-travel
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Individual','Pre-travel')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
	    WHERE  DateNextTravelAny > @today and CustomerTypeID is null
    END

    -- Post Travel
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Individual','Post travel')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
	    WHERE  CAST(DateLastTravelAny AS DATE) BETWEEN DATEADD(D,-5,@today) and @today and CustomerTypeID is null
    END

    -- New Known Individual
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Individual','New Known Individual')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @CustomerTypeID
		FROM   [Production].[Individual] a left join #tmp_type b on a.Individualid = b.IndividualID
		WHERE  a.DateFirstPurchaseAny BETWEEN DATEADD(D,-21,@today) and @today
		AND    b.NoTransactionsLast12Mnths = 1 and CustomerTypeID is null
    END

    -- Nursery
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Individual','Nursery')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @CustomerTypeID
        FROM   [Production].[Individual] a left join #tmp_type b on a.Individualid = b.IndividualID
	    WHERE  b.NoTransactionsLast12Mnths = 1
		AND    DateFirstPurchaseAny BETWEEN  DATEADD(D,-90,@today) AND DATEADD(D,-21,@today) and CustomerTypeID is null
    END

    -- VIP
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Individual','VIP')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
	    WHERE  SalesAmountRail12Mnth >= 1200
        AND DATEDIFF(MM, DateLastPurchaseAny, @today) <= 3 and CustomerTypeID is null
    END

    -- Declining Individual
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Individual','Declining Individual')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @CustomerTypeID
        FROM   [Production].[Individual] a left join #tmp_type b on a.Individualid = b.IndividualID
	    WHERE  ((DateLastPurchaseAny >= DATEADD(M,-3,@today) AND b.NoTransactionsLast12Mnths BETWEEN 2 AND 4)
		    OR
               (DateLastPurchaseAny >= DATEADD(M,-9,@today) AND b.NoTransactionsLast12Mnths = 1))
        AND CustomerTypeID is null
    END

    -- VIP Lapser
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','VIP Lapser')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @CustomerTypeID
        FROM   [Production].[Individual] a left join #tmp_type b on a.Individualid = b.IndividualID
	    WHERE  DateLastPurchaseAny < DATEADD(M,-3,@today)
		AND    b.NoTransactionsLast12Mnths > 11 and CustomerTypeID is null
    END

    -- High Value Lapser
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','High value Lapser')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @CustomerTypeID
        FROM   [Production].[Individual] a left join #tmp_type b on a.Individualid = b.IndividualID
	    WHERE  DateLastPurchaseAny >= DATEADD(M,-4,@today)
		AND    b.NoTransactionsLast12Mnths  BETWEEN 5 AND 10 and CustomerTypeID is null
    END

    -- Medium Value Lapser
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','Medium value Lapser')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @CustomerTypeID
	    FROM   [Production].[Individual] a left join #tmp_type b on a.Individualid = b.IndividualID
        WHERE  DateLastPurchaseAny >= DATEADD(M,-6,@today)
		AND    b.NoTransactionsLast12Mnths BETWEEN 2 AND 4 and CustomerTypeID is null
    END

    -- Low Value Lapser
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','Low Value Lapser')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
        FROM Production.Individual a inner join (
            select Individualid, count(*) as Sales
            from Staging.STG_SalesTransaction
            where SalesTransactionDate between DATEDIFF(MM, -18, GETDATE()) and GETDATE()
            group by Individualid) b on a.IndividualID = b.IndividualID
	    WHERE  DateLastPurchaseAny < DATEADD(M,-13,@today) and b.Sales = 1 and CustomerTypeID is null
    END

    -- Active Individual
	SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Individual','Active Individual')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
	    WHERE  SalesAmount12Mnth > 0 and CustomerTypeID is null
    END

    -- Long Term Lapsed
	SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','Long Term Lapsed')

	IF @CustomerTypeID IS NOT NULL
	BEGIN
	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
	    WHERE  COALESCE(DateLastPurchaseAny, DateFirstPurchaseAny) < DATEADD(M,-12,@today) and CustomerTypeID is null
    END

-- PROSPECTS
    -- Prospect
    SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Prospect','Prospect')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
	    WHERE  DateFirstPurchaseAny IS NULL
		AND    DateRegistered >= DATEADD(D,-42,@today) and CustomerTypeID is null
    END

    -- Lapsing Prospect
	SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Prospect','Lapsing Prospect')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
	    WHERE  DateFirstPurchaseAny IS NULL
        AND DateRegistered BETWEEN DATEADD(D,-183,@today) AND DATEADD(D, -42, @today) and CustomerTypeID is null
    END

    -- Lapsed Prospect
	SELECT @CustomerTypeID = [Reference].[CustomerType_GetSubTypeID] ('Prospect','Lapsed Prospect')

	IF @CustomerTypeID IS NOT NULL
	BEGIN

	    UPDATE [Production].[Individual]
	    SET    CustomerTypeID = @CustomerTypeID
	    WHERE  DateFirstPurchaseAny IS NULL
        AND DateRegistered <= DATEADD(D, -184, @today) and CustomerTypeID is null
    END

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN
END