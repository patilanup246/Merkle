CREATE VIEW [Production].[SalesTransactionByPeriod] AS
    SELECT a.CustomerID         AS CustomerID
	      ,a.SalesTransactionID AS SalesTransactionID
		  ,a.SalesAmountTotal   AS SalesAmountTotal
		  ,b.PeriodID           AS PeriodID
	      ,b.Name               AS Period
    FROM  Staging.STG_SalesTransaction a,
          Reference.Period b
    WHERE b.datestart = DATEADD(q, DATEDIFF(q,0,SalesTransactionDate),0)