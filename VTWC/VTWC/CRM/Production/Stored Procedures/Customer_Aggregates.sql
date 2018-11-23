CREATE PROCEDURE [Production].[Customer_Aggregates](@userid INTEGER = 0)
AS

/*
 *	Created by: tomas.kostan@cometgc.com _1
 *		(based on the previous version of the procedure created by steve.forster@cometgc.com)
 *	Created on: 08/05/2017
 *
 *	Description:
 *		-Recalculates customer aggregates during CEM Refresh every day
 *

 *		Modify Counting based on Booking reference, now it's using salestransactionID
 *
 *
 */


     BEGIN
         SET NOCOUNT ON;
         DECLARE @informationsourceid INTEGER;
         DECLARE @spname NVARCHAR(256);
         DECLARE @spnameAgg NVARCHAR(256);
         DECLARE @recordcount INTEGER;
         DECLARE @recordcountAgg INTEGER;
         DECLARE @logtimingidnew INTEGER;
         DECLARE @logtimingidagg INTEGER;
         DECLARE @logmessage NVARCHAR(MAX);
         DECLARE @tableName NVARCHAR(256);
         DECLARE @columnName NVARCHAR(256);
         DECLARE @ticket_first INT;
         DECLARE @ticket_standard INT;
         SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID);
         DECLARE @today DATE= GETDATE();
         DECLARE @12MonthsAgo DATE= DATEADD(YY, -1, @today);
         DECLARE @6MonthsAgo DATE= DATEADD(MM, -6, @today);
         SELECT TOP 1 @ticket_first = tc.TicketClassID
         FROM Reference.TicketClass AS tc
         WHERE tc.Name = 'First';
         SELECT TOP 1 @ticket_standard = tc.TicketClassID
         FROM Reference.TicketClass AS tc
         WHERE tc.Name = 'Standard';

	--Log start time--

         EXEC [Operations].[LogTiming_Record]
              @userid = @userid,
              @logsource = @spname,
              @logtimingidnew = @logtimingidnew OUTPUT;
         EXEC [Operations].[TableBackup]
              @table_name = N'Staging.STG_CustomerAggregation';

	-- Delete old aggregates
         TRUNCATE TABLE Staging.STG_CustomerAggregation;
         INSERT INTO Staging.STG_CustomerAggregation
         (CustomerID,
          TransactionsLast12MnthsFirst,
          TransactionsLast12MnthsStandard,
          TransactionsLast6MnthsFirst,
          TransactionsLast6MnthsFirstWeekday,
          TransactionsLast6MnthsFirstWeekend,
          TransactionsLast6MnthsStandard,
          TransactionsLast6MnthsStandardWeekday,
          TransactionsLast6MnthsStandardWeekend,
          TransactionsLast12MnthsFirstSolo,
          TransactionsLast12MnthsStandardSolo,
			-- #65 Aggregates for Weekend Travel for the last 12 months
          TransactionsLast12MnthsFirstWeekday,
          TransactionsLast12MnthsFirstWeekend
         )
                SELECT agg.CustomerID,
                       ISNULL(agg.Trans_L12M_First, 0) AS TransactionsLast12MnthsFirst,
                       ISNULL(agg.Trans_L12M_Second, 0) AS TransactionsLast12MnthsStandard,
                       ISNULL(agg.Trans_L6M_First, 0) AS TransactionsLast6MnthsFirst,
                       ISNULL(agg.Trans_L6M_First_Weekday, 0) AS TransactionsLast6MnthsFirstWeekday,
                       ISNULL(agg.Trans_L6M_First_Weekend, 0) AS TransactionsLast6MnthsFirstWeekend,
                       ISNULL(agg.Trans_L6M_Second, 0) AS TransactionsLast6MnthsStandard,
                       ISNULL(agg.Trans_L6M_Second_Weekday, 0) AS TransactionsLast6MnthsStandardWeekday,
                       ISNULL(agg.Trans_L6M_Second_Weekend, 0) AS TransactionsLast6MnthsStandardWeekend,
                       ISNULL(agg.Trans_L12M_First_Solo, 0) AS TransactionsLast12MnthsFirstSolo,
                       ISNULL(agg.Trans_L12M_Second_Solo, 0) AS TransactionsLast12MnthsStandardSolo,
			-- #65 Aggregates for Weekend Travel for the last 12 months
                       ISNULL(agg.Trans_L12M_First_Weekday, 0) AS TransactionsLast12MnthsFirstWeekday,
                       ISNULL(agg.Trans_L12M_First_Weekend, 0) AS TransactionsLast12MnthsFirstWeekend
                FROM
                (
                    SELECT b.CustomerID,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_first
                                              THEN b.salestransactionID
                                          END) AS Trans_L12M_First,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_standard
                                              THEN b.salestransactionID
                                          END) AS Trans_L12M_Second,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                              THEN b.salestransactionID
                                          END) AS Trans_L6M,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_first
                                              THEN b.salestransactionID
                                          END) AS Trans_L6M_First,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_first
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) BETWEEN 2 AND 6
                                                        OR DATEPART(WEEKDAY, c.ReturnTravelDate) BETWEEN 2 AND 6)
                                              THEN b.salestransactionID
                                          END) AS Trans_L6M_First_Weekday,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_first
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) IN(1, 7)
                                          OR DATEPART(WEEKDAY, c.ReturnTravelDate) IN(1, 7))
                                              THEN b.salestransactionID
                                          END) AS Trans_L6M_First_Weekend,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_standard
                                              THEN b.salestransactionID
                                          END) AS Trans_L6M_Second,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_standard
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) BETWEEN 2 AND 6
                                                        OR DATEPART(WEEKDAY, c.ReturnTravelDate) BETWEEN 2 AND 6)
                                              THEN b.salestransactionID
                                          END) AS Trans_L6M_Second_Weekday,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_standard
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) IN(1, 7)
                                          OR DATEPART(WEEKDAY, c.ReturnTravelDate) IN(1, 7))
                                              THEN b.salestransactionID
                                          END) AS Trans_L6M_Second_Weekend,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_first
                                                   AND b.NumberofChildren = 0
                                              THEN b.salestransactionID
                                          END) AS Trans_L12M_First_Solo,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_standard
                                                   AND b.NumberofChildren = 0
                                              THEN b.salestransactionID
                                          END) AS Trans_L12M_Second_Solo,
						-- #65 Aggregates for Weekend Travel for the last 12 months
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_first
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) BETWEEN 2 AND 6
                                                        OR DATEPART(WEEKDAY, c.ReturnTravelDate) BETWEEN 2 AND 6)
                                              THEN b.salestransactionID
                                          END) AS Trans_L12M_First_Weekday,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND b.SalesTransactionDate < @today
                                                   AND d.TicketClassId = @ticket_first
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) IN(1, 7)
                                          OR DATEPART(WEEKDAY, c.ReturnTravelDate) IN(1, 7))
                                              THEN b.salestransactionID
                                          END) AS Trans_L12M_First_Weekend
                    FROM Staging.STG_SalesTransaction b
                         INNER JOIN Staging.STG_SalesDetail c ON b.salesTransactionId = c.SalestransactionId
                         INNER JOIN Reference.Product d ON c.productID = d.ProductID
                    WHERE b.SalesTransactionDate > @12MonthsAgo
                          AND b.ArchivedInd = 0
                          AND c.ArchivedInd = 0
                          AND d.ArchivedInd = 0
                    GROUP BY b.CustomerID
                ) agg;
         SELECT @recordcount = @@ROWCOUNT;
         EXEC [Operations].[CheckTableAndRestoreOnFailure]
              @table_name = N'Staging.STG_CustomerAggregation';

	--VTWC SPECIFIC

         IF OBJECT_ID('tempdb..#VtwcSales') IS NOT NULL
             DROP TABLE #VtwcSales;

	--Selects all sales detail IDs which have at least 1 VTWC ticket associated with them

         SELECT DISTINCT
                c.SalesDetailID
         INTO #VtwcSales
         FROM [Staging].[STG_SalesDetail] c
              INNER JOIN [Staging].[STG_Journey] jo ON jo.[SalesDetailID] = c.[SalesDetailID]
              INNER JOIN [Staging].[STG_JourneyLeg] jl ON jo.[JourneyID] = jl.[JourneyID]
                                                          AND [TOCID] = 9
         WHERE c.ArchivedInd = 0
               AND jo.ArchivedInd = 0
               AND jl.ArchivedInd = 0;
         EXEC [Operations].[TableBackup]
              @table_name = N'Staging.STG_VTWC_CustomerAggregation';
         TRUNCATE TABLE Staging.STG_VTWC_CustomerAggregation;
         INSERT INTO Staging.STG_VTWC_CustomerAggregation
         (CustomerID,
			--VTWC Specific
          [VTWC_SalesTransaction1Mnth],
          [VTWC_SalesTransaction3Mnth],
          [VTWC_SalesTransaction6Mnth],
          [VTWC_TransactionsLast6MnthsFirst],
          [VTWC_TransactionsLast6MnthsFirstWeekday],
          [VTWC_TransactionsLast6MnthsFirstWeekend],
          [VTWC_TransactionsLast6MnthsStandard],
          [VTWC_TransactionsLast6MnthsStandardWeekday],
          [VTWC_TransactionsLast6MnthsStandardWeekend],
          [VTWC_SalesTransaction12Mnth],
          [VTWC_TransactionsLast12MnthsFirstSolo],
          [VTWC_TransactionsLast12MnthsStandardSolo],
          [VTWC_TransactionsLast12MnthsFirst],
          [VTWC_TransactionsLast12MnthsStandard],
          [VTWC_SalesTransactionTotal],
			-- #65 Aggregates for Weekend Travel for the last 12 months
          [VTWC_TransactionsLast12MnthsFirstWeekday],
          [VTWC_TransactionsLast12MnthsFirstWeekend],				
			--Sales amounts
          [VTWC_SalesAmountTotal],
          [VTWC_SalesAmount3Mnth],
          [VTWC_SalesAmount6Mnth],
          [VTWC_SalesAmount12Mnth],						
			--Journey dates
          [VTWC_DateFirstTravelAny],
          [VTWC_DateLastTravelAny],
          [VTWC_DateNextTravelAny],
          [VTWC_DateFirstTravelFirst],
          [VTWC_DateLastTravelFirst],
          [VTWC_DateNextTravelFirst],
          [VTWC_DateFirstTravelStandard],
          [VTWC_DateLastTravelStandard],
          [VTWC_DateNextTravelStandard],			
			--Purchases
          [VTWC_DateFirstPurchaseAny],
          [VTWC_DateLastPurchaseAny],
          [VTWC_DateFirstPurchaseFirst],
          [VTWC_DateLastPurchaseFirst],
          [VTWC_DateFirstPurchaseStandard],
          [VTWC_DateLastPurchaseStandard]
         )
                SELECT
	--VTWC Specific
                vtwc.CustomerID,
                ISNULL(vtwc.VTWC_SalesTransaction1Mnth, 0) AS [VTWC_SalesTransaction1Mnth],
                ISNULL(vtwc.VTWC_SalesTransaction3Mnth, 0) AS [VTWC_SalesTransaction3Mnth],
                ISNULL(vtwc.VTWC_SalesTransaction6Mnth, 0) AS [VTWC_SalesTransaction6Mnth],
                ISNULL(vtwc.VTWC_Trans_L6M_First, 0) AS [VTWC_TransactionsLast6MnthsFirst],
                ISNULL(vtwc.VTWC_Trans_L6M_First_Weekday, 0) AS [VTWC_TransactionsLast6MnthsFirstWeekday],
                ISNULL(vtwc.VTWC_Trans_L6M_First_Weekend, 0) AS [VTWC_TransactionsLast6MnthsFirstWeekend],
                ISNULL(vtwc.VTWC_Trans_L6M_Second, 0) AS [VTWC_TransactionsLast6MnthsStandard],
                ISNULL(vtwc.VTWC_Trans_L6M_Second_Weekday, 0) AS [VTWC_TransactionsLast6MnthsStandardWeekday],
                ISNULL(vtwc.VTWC_Trans_L6M_Second_Weekend, 0) AS [VTWC_TransactionsLast6MnthsStandardWeekend],
                ISNULL(vtwc.VTWC_SalesTransaction12Mnth, 0) AS [VTWC_SalesTransaction12Mnth],
                ISNULL(vtwc.VTWC_Trans_L12M_First_Solo, 0) AS [VTWC_TransactionsLast12MnthsFirstSolo],
                ISNULL(vtwc.VTWC_Trans_L12M_Second_Solo, 0) AS [VTWC_TransactionsLast12MnthsStandardSolo],
                ISNULL(vtwc.VTWC_Trans_L12M_First, 0) AS [VTWC_TransactionsLast12MnthsFirst],
                ISNULL(vtwc.VTWC_Trans_L12M_Second, 0) AS [VTWC_TransactionsLast12MnthsStandard],
                ISNULL(vtwc.VTWC_SalesTransactionTotal, 0) AS [VTWC_SalesTransactionTotal],
			-- #65 Aggregates for Weekend Travel for the last 12 months
                ISNULL(vtwc.VTWC_Trans_L12M_First_Weekday, 0) AS [VTWC_TransactionsLast12MnthsFirstWeekday],
                ISNULL(vtwc.VTWC_Trans_L12M_First_Weekend, 0) AS [VTWC_TransactionsLast12MnthsFirstWeekend],
			--Sales amounts
                ISNULL(vtwc.VTWC_SalesAmountTotal, 0) AS [VTWC_SalesAmountTotal],
                ISNULL(vtwc.VTWC_SalesAmount3Mnth, 0) AS [VTWC_SalesAmount3Mnth],
                ISNULL(vtwc.VTWC_SalesAmount6Mnth, 0) AS [VTWC_SalesAmount6Mnth],
                ISNULL(vtwc.VTWC_SalesAmount12Mnth, 0) AS [VTWC_SalesAmount12Mnth],		
			
			--Journey dates
                vtwc.VTWC_DateFirstTravelAny AS [VTWC_DateFirstTravelAny],
                CASE
                    WHEN vtwc.VTWC_DateLastTravelAny_OUT > vtwc.VTWC_DateLastTravelAny_RET
                    THEN vtwc.VTWC_DateLastTravelAny_OUT
                    ELSE vtwc.VTWC_DateLastTravelAny_RET
                END AS [VTWC_DateLastTravelAny],
                CASE
                    WHEN vtwc.VTWC_DateNextTravelAny_OUT > vtwc.VTWC_DateNextTravelAny_RET
                    THEN vtwc.VTWC_DateNextTravelAny_RET
                    ELSE vtwc.VTWC_DateNextTravelAny_OUT
                END AS [VTWC_DateNextTravelAny],
                vtwc.VTWC_DateFirstTravelFirst AS [VTWC_DateFirstTravelFirst],
                CASE
                    WHEN vtwc.VTWC_DateLastTravelFirst_OUT > vtwc.VTWC_DateLastTravelFirst_RET
                    THEN VTWC_DateLastTravelFirst_OUT
                    ELSE vtwc.VTWC_DateLastTravelFirst_RET
                END AS [VTWC_DateLastTravelFirst],
                CASE
                    WHEN vtwc.VTWC_DateNextTravelFirst_OUT > vtwc.VTWC_DateNextTravelFirst_RET
                    THEN vtwc.VTWC_DateNextTravelFirst_RET
                    ELSE vtwc.VTWC_DateNextTravelFirst_OUT
                END AS [VTWC_DateNextTravelFirst],
                vtwc.VTWC_DateFirstTravelStandard AS [VTWC_DateFirstTravelStandard],
                CASE
                    WHEN vtwc.VTWC_DateLastTravelStandard_OUT > vtwc.VTWC_DateLastTravelStandard_RET
                    THEN vtwc.VTWC_DateLastTravelStandard_OUT
                    ELSE vtwc.VTWC_DateLastTravelStandard_RET
                END AS [VTWC_DateLastTravelStandard],
                CASE
                    WHEN vtwc.VTWC_DateLastTravelStandard_OUT > vtwc.VTWC_DateLastTravelStandard_RET
                    THEN vtwc.VTWC_DateNextTravelStandard_RET
                    ELSE vtwc.VTWC_DateNextTravelStandard_OUT
                END AS [VTWC_DateNextTravelStandard],

			--Purchases
                vtwc.VTWC_DateFirstPurchaseAny AS [VTWC_DateFirstPurchaseAny],
                vtwc.VTWC_DateLastPurchaseAny AS [VTWC_DateLastPurchaseAny],
                vtwc.VTWC_DateFirstPurchaseFirst AS [VTWC_DateFirstPurchaseFirst],
                vtwc.VTWC_DateLastPurchaseFirst AS [VTWC_DateLastPurchaseFirst],
                vtwc.VTWC_DateFirstPurchaseStandard AS [VTWC_DateFirstPurchaseStandard],
                vtwc.VTWC_DateLastPurchaseStandard AS [VTWC_DateLastPurchaseStandard]
                FROM
                (
                    SELECT b.CustomerID,
						--updated VTWC aggregates
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND d.TicketClassId = @ticket_first
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L12M_First,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND d.TicketClassId = @ticket_standard
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L12M_Second,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L6M,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND d.TicketClassId = @ticket_first
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L6M_First,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND d.TicketClassId = @ticket_first
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) BETWEEN 2 AND 6
                                                        OR DATEPART(WEEKDAY, c.ReturnTravelDate) BETWEEN 2 AND 6)
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L6M_First_Weekday,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND d.TicketClassId = @ticket_first
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) IN(1, 7)
                                          OR DATEPART(WEEKDAY, c.ReturnTravelDate) IN(1, 7))
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L6M_First_Weekend,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND d.TicketClassId = @ticket_standard
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L6M_Second,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND d.TicketClassId = @ticket_standard
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) BETWEEN 2 AND 6
                                                        OR DATEPART(WEEKDAY, c.ReturnTravelDate) BETWEEN 2 AND 6)
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L6M_Second_Weekday,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                                   AND d.TicketClassId = @ticket_standard
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) IN(1, 7)
                                          OR DATEPART(WEEKDAY, c.ReturnTravelDate) IN(1, 7))
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L6M_Second_Weekend,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND d.TicketClassId = @ticket_first
                                                   AND b.NumberofChildren = 0
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L12M_First_Solo,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND d.TicketClassId = @ticket_standard
                                                   AND b.NumberofChildren = 0
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L12M_Second_Solo,
						-- #65 Aggregates for Weekend Travel for the last 12 months
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND d.TicketClassId = @ticket_first
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) BETWEEN 2 AND 6
                                                        OR DATEPART(WEEKDAY, c.ReturnTravelDate) BETWEEN 2 AND 6)
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L12M_First_Weekday,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                                   AND d.TicketClassId = @ticket_first
                                                   AND (DATEPART(WEEKDAY, c.OutTravelDate) IN(1, 7)
                                          OR DATEPART(WEEKDAY, c.ReturnTravelDate) IN(1, 7))
                                              THEN b.salestransactionID
                                          END) AS VTWC_Trans_L12M_First_Weekend,
						-- VTWC_DateFirstPurchaseAny
                           MIN(b.SalesTransactionDate) AS VTWC_DateFirstPurchaseAny,
						-- VTWC_DateLastPurchaseAny
                           MAX(b.SalesTransactionDate) AS VTWC_DateLastPurchaseAny,
						-- VTWC_DateFirstPurchaseFirst
                           MIN(CASE
                                   WHEN d.TicketClassID = @ticket_first
                                   THEN b.SalesTransactionDate
                               END) AS VTWC_DateFirstPurchaseFirst,
						-- VTWC_DateLastPurchaseFirst
                           MAX(CASE
                                   WHEN d.TicketClassID = @ticket_first
                                   THEN b.SalesTransactionDate
                               END) AS VTWC_DateLastPurchaseFirst,
						-- VTWC_DateFirstPurchaseStandard
                           MIN(CASE
                                   WHEN d.TicketClassID = @ticket_standard
                                   THEN b.SalesTransactionDate
                               END) AS VTWC_DateFirstPurchaseStandard,
						-- VTWC_DateLastPurchaseStandard
                           MAX(CASE
                                   WHEN d.TicketClassID = @ticket_standard
                                   THEN b.SalesTransactionDate
                               END) AS VTWC_DateLastPurchaseStandard,
						-- VTWC_DateFirstTravelAny
                           MIN(CASE
                                   WHEN c.OutTravelDate < @today
                                   THEN c.OutTravelDate
                               END) AS VTWC_DateFirstTravelAny,

						--VTWC_DateLastTravelAny
                           MAX(CASE
                                   WHEN c.OutTravelDate < @today
                                   THEN c.OutTravelDate
                               END) AS VTWC_DateLastTravelAny_OUT,
                           MAX(CASE
                                   WHEN c.ReturnTravelDate IS NOT NULL
                                        AND c.ReturnTravelDate < @today
                                   THEN c.ReturnTravelDate
                               END) AS VTWC_DateLastTravelAny_RET,

						--VTWC_DateNextTravelAny
                           MIN(CASE
                                   WHEN c.OutTravelDate > @today
                                   THEN c.OutTravelDate
                               END) AS VTWC_DateNextTravelAny_OUT,
                           MIN(CASE
                                   WHEN c.ReturnTravelDate IS NOT NULL
                                        AND c.ReturnTravelDate > @today
                                   THEN c.ReturnTravelDate
                               END) AS VTWC_DateNextTravelAny_RET,
						--VTWC_DateFirstTravelFirst
                           MIN(CASE
                                   WHEN d.TicketClassId = @ticket_first
                                   THEN c.OutTravelDate
                               END) AS VTWC_DateFirstTravelFirst,

						--VTWC_DateLastTravelFirst
                           MAX(CASE
                                   WHEN c.OutTravelDate <= @today
                                        AND d.TicketClassID = @ticket_first
                                   THEN c.OutTravelDate
                               END) AS VTWC_DateLastTravelFirst_OUT,
                           MAX(CASE
                                   WHEN c.ReturnTravelDate IS NOT NULL
                                        AND c.ReturnTravelDate < @today
                                        AND d.TicketClassID = @ticket_first
                                   THEN c.ReturnTravelDate
                               END) AS VTWC_DateLastTravelFirst_RET,

						--VTWC_DateNextTravelFirst
                           MIN(CASE
                                   WHEN c.OutTravelDate > @today
                                        AND d.TicketClassID = @ticket_first
                                   THEN c.OutTravelDate
                               END) AS VTWC_DateNextTravelFirst_OUT,
                           MIN(CASE
                                   WHEN c.ReturnTravelDate IS NOT NULL
                                        AND c.ReturnTravelDate > @today
                                        AND d.TicketClassID = @ticket_first
                                   THEN c.ReturnTravelDate
                               END) AS VTWC_DateNextTravelFirst_RET,
						--VTWC_DateFirstTravelStandard
                           MIN(CASE
                                   WHEN d.TicketClassId = @ticket_standard
                                   THEN c.OutTravelDate
                               END) AS VTWC_DateFirstTravelStandard,
						--VTWC_DateLastTravelStandard
                           MAX(CASE
                                   WHEN c.OutTravelDate <= @today
                                        AND d.TicketClassID = @ticket_standard
                                   THEN c.OutTravelDate
                               END) AS VTWC_DateLastTravelStandard_OUT,
                           MAX(CASE
                                   WHEN c.ReturnTravelDate IS NOT NULL
                                        AND c.ReturnTravelDate < @today
                                        AND d.TicketClassID = @ticket_standard
                                   THEN c.ReturnTravelDate
                               END) AS VTWC_DateLastTravelStandard_RET,
						--VTWC_DateNextTravelStandard
                           MIN(CASE
                                   WHEN c.OutTravelDate > @today
                                        AND d.TicketClassID = @ticket_standard
                                   THEN c.OutTravelDate
                               END) AS VTWC_DateNextTravelStandard_OUT,
                           MIN(CASE
                                   WHEN c.ReturnTravelDate IS NOT NULL
                                        AND c.ReturnTravelDate > @today
                                        AND d.TicketClassID = @ticket_standard
                                   THEN c.ReturnTravelDate
                               END) AS VTWC_DateNextTravelStandard_RET,
                           SUM(c.SalesAmount) AS VTWC_SalesAmountTotal,
                           SUM(CASE
                                   WHEN b.SalesTransactionDate > DATEADD(MM, -3, @today)
                                   THEN c.SalesAmount
                               END) AS VTWC_SalesAmount3Mnth,
                           SUM(CASE
                                   WHEN b.SalesTransactionDate > @6MonthsAgo
                                   THEN c.SalesAmount
                               END) AS VTWC_SalesAmount6Mnth,
                           SUM(CASE
                                   WHEN b.SalesTransactionDate > @12MonthsAgo
                                   THEN c.SalesAmount
                               END) AS VTWC_SalesAmount12Mnth,
                           COUNT(DISTINCT b.salestransactionID) AS VTWC_SalesTransactionTotal,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > DATEADD(MM, -1, @today)
                                              THEN b.salestransactionID
                                          END) AS VTWC_SalesTransaction1Mnth,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > DATEADD(MM, -3, @today)
                                              THEN b.salestransactionID
                                          END) AS VTWC_SalesTransaction3Mnth,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @6MonthsAgo
                                              THEN b.salestransactionID
                                          END) AS VTWC_SalesTransaction6Mnth,
                           COUNT(DISTINCT CASE
                                              WHEN b.SalesTransactionDate > @12MonthsAgo
                                              THEN b.salestransactionID
                                          END) AS VTWC_SalesTransaction12Mnth
                    FROM Staging.STG_SalesTransaction b
                         INNER JOIN Staging.STG_SalesDetail c ON b.salesTransactionId = c.SalestransactionId
                         INNER JOIN Reference.Product d ON c.productID = d.ProductID
							--INNER JOIN [Reference].[TicketClass] tc		  ON d.[TicketClassID] = tc.[TicketClassID]
                         INNER JOIN #VtwcSales v ON v.SalesDetailID = c.SalesDetailID
                    WHERE b.ArchivedInd = 0
                          AND c.ArchivedInd = 0
                          AND d.ArchivedInd = 0
                          AND b.SalesTransactionDate < @today
                    GROUP BY b.CustomerID
                ) vtwc;
         SELECT @recordcount+=@@ROWCOUNT;
         EXEC [Operations].[CheckTableAndRestoreOnFailure]
              @table_name = N'Staging.STG_VTWC_CustomerAggregation';
	
	--Log end time

         ProcExit:
         EXEC [Operations].[LogTiming_Record]
              @userid = @userid,
              @logsource = @spname,
              @logtimingid = @logtimingidnew,
              @recordcount = @recordcount,
              @logtimingidnew = @logtimingidnew OUTPUT;
         RETURN;
     END;