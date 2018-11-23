CREATE PROCEDURE [Production].[Customer_CustomerType_Update]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @today                    DATE
    DECLARE @customertypeid           INTEGER

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
        CustomerID                       INTEGER,
        NoTransactionsLast12Mnths        INTEGER,
        NoTransactionsPrevious12Mnths    INTEGER,
)
    IF @today IS NULL
    BEGIN
        SELECT @today = CAST(GETDATE() AS DATE)
    END

    INSERT INTO #tmp_type
       (CustomerID,
        NoTransactionsLast12Mnths,
        NoTransactionsPrevious12Mnths
        )
    SELECT CustomerID,
           0,0
    FROM   Production.Customer

    UPDATE a
    SET NoTransactionsLast12Mnths = COALESCE(f.NoofTrans_L12M, 0)
    FROM #tmp_type a
    INNER JOIN (SELECT b.CustomerID,
                  COUNT(distinct CASE WHEN b.SalesTransactionDate > DATEADD(YY,-1,@today) and b.SalesTransactionDate <= @today
                                      THEN b.BookingReference END) AS NoofTrans_L12M
                FROM Staging.STG_SalesTransaction b
                WHERE b.SalesTransactionDate > DATEADD(YY,-2,@today)
            GROUP BY b.CustomerID) f ON a.CustomerID = f.CustomerID

    --CHANGE ME
	SELECT @today = CAST(GETDATE() AS DATE)--CAST('2016-05-16 12:17:29.000' AS date)

-- CLEAR THE EXISTING CUSTOMER TYPE
    UPDATE [Production].[Customer] SET CustomerTypeID = null;

--CUSTOMERS
    -- Day of travel
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Customer','Day of travel')

	IF @customertypeid IS NOT NULL
	BEGIN
	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
	    WHERE  CAST(DateNextTravelAny AS DATE) = @today and CustomerTypeID is null
    END

	-- Previously Lapsed Customer
	SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Customer','Previously Lapsed Customer')

	IF @customertypeid IS NOT NULL
	BEGIN
		UPDATE cus
		SET	   CustomerTypeID = @customertypeid
		from cem.Production.Customer cus inner join
		(
		select b.CustomerID, b.SalesTransactionDate, row_number() over (partition by b.customerid order by b.salestransactiondate desc) as rownum
		from cem.Staging.STG_SalesTransaction b
		group by b.CustomerID, b.SalesTransactionDate) last_trans on cus.customerid = last_trans.customerid

		inner join
		(
		select b.CustomerID, b.SalesTransactionDate, row_number() over (partition by b.customerid order by b.salestransactiondate desc) as rownum
		from cem.Staging.STG_SalesTransaction b
		group by b.CustomerID, b.SalesTransactionDate) prev_trans on cus.CustomerID = prev_trans.CustomerID
		where last_trans.rownum = 1 and prev_trans.rownum = 2
		  and cus.DateNextTravelAny > GETDATE()
		  and DATEDIFF(MM, prev_trans.SalesTransactionDate, last_trans.SalesTransactionDate) >= 12
		  and cus.CustomerTypeID is null
	END

    -- Pre-travel
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Customer','Pre-travel')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
	    WHERE  DateNextTravelAny > @today and CustomerTypeID is null
    END

    -- Post Travel
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Customer','Post travel')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
	    WHERE  CAST(DateLastTravelAny AS DATE) BETWEEN DATEADD(D,-5,@today) and @today and CustomerTypeID is null
    END

    -- New Known Customer
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Customer','New Known Customer')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @customertypeid
		FROM   [Production].[Customer] a left join #tmp_type b on a.customerid = b.customerid
		WHERE  a.DateFirstPurchaseAny BETWEEN DATEADD(D,-21,@today) and @today
		AND    b.NoTransactionsLast12Mnths = 1 and CustomerTypeID is null
    END

    -- Nursery
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Customer','Nursery')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @customertypeid
        FROM   [Production].[Customer] a left join #tmp_type b on a.customerid = b.customerid
	    WHERE  b.NoTransactionsLast12Mnths = 1
		AND    DateFirstPurchaseAny BETWEEN  DATEADD(D,-90,@today) AND DATEADD(D,-21,@today) and CustomerTypeID is null
    END

    -- VIP
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Customer','VIP')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
	    WHERE  SalesAmountRail12Mnth >= 1200
        AND DATEDIFF(MM, DateLastPurchaseAny, @today) <= 3 and CustomerTypeID is null
    END

    -- Declining Customer
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Customer','Declining Customer')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @customertypeid
        FROM   [Production].[Customer] a left join #tmp_type b on a.customerid = b.customerid
	    WHERE  ((DateLastPurchaseAny >= DATEADD(M,-3,@today) AND b.NoTransactionsLast12Mnths BETWEEN 2 AND 4)
		    OR
               (DateLastPurchaseAny >= DATEADD(M,-9,@today) AND b.NoTransactionsLast12Mnths = 1))
        AND CustomerTypeID is null
    END

    -- VIP Lapser
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','VIP Lapser')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @customertypeid
        FROM   [Production].[Customer] a left join #tmp_type b on a.customerid = b.customerid
	    WHERE  DateLastPurchaseAny < DATEADD(M,-3,@today)
		AND    b.NoTransactionsLast12Mnths > 11 and CustomerTypeID is null
    END

    -- High Value Lapser
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','High value Lapser')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @customertypeid
        FROM   [Production].[Customer] a left join #tmp_type b on a.customerid = b.customerid
	    WHERE  DateLastPurchaseAny >= DATEADD(M,-4,@today)
		AND    b.NoTransactionsLast12Mnths  BETWEEN 5 AND 10 and CustomerTypeID is null
    END

    -- Medium Value Lapser
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','Medium value Lapser')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE a
	    SET    a.CustomerTypeID = @customertypeid
	    FROM   [Production].[Customer] a left join #tmp_type b on a.customerid = b.customerid
        WHERE  DateLastPurchaseAny >= DATEADD(M,-6,@today)
		AND    b.NoTransactionsLast12Mnths BETWEEN 2 AND 4 and CustomerTypeID is null
    END

    -- Low Value Lapser
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','Low Value Lapser')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
        FROM Production.Customer a inner join (
            select customerid, count(*) as Sales
            from cem.Staging.STG_SalesTransaction
            where SalesTransactionDate between DATEDIFF(MM, -18, GETDATE()) and GETDATE()
            group by customerid) b on a.CustomerID = b.CustomerID
	    WHERE  DateLastPurchaseAny < DATEADD(M,-13,@today) and b.Sales = 1 and CustomerTypeID is null
    END

    -- Active Customer
	SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Customer','Active Customer')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
	    WHERE  SalesAmount12Mnth > 0 and CustomerTypeID is null
    END

    -- Long Term Lapsed
	SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Lapsed','Long Term Lapsed')

	IF @customertypeid IS NOT NULL
	BEGIN
	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
	    WHERE  COALESCE(DateLastPurchaseAny, DateFirstPurchaseAny) < DATEADD(M,-12,@today) and CustomerTypeID is null
    END

-- PROSPECTS
    -- Prospect
    SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Prospect','Prospect')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
	    WHERE  DateFirstPurchaseAny IS NULL
		AND    DateRegistered >= DATEADD(D,-42,@today) and CustomerTypeID is null
    END

    -- Lapsing Prospect
	SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Prospect','Lapsing Prospect')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
	    WHERE  DateFirstPurchaseAny IS NULL
        AND DateRegistered BETWEEN DATEADD(D,-183,@today) AND DATEADD(D, -42, @today) and CustomerTypeID is null
    END

    -- Lapsed Prospect
	SELECT @customertypeid = [Reference].[CustomerType_GetSubTypeID] ('Prospect','Lapsed Prospect')

	IF @customertypeid IS NOT NULL
	BEGIN

	    UPDATE [Production].[Customer]
	    SET    CustomerTypeID = @customertypeid
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