



CREATE PROCEDURE [Production].[Customer_RFV_Update]
    (
     @userid INTEGER = 0
    ,@today DATE = NULL
    )
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @segmentid INTEGER;

        DECLARE @spname NVARCHAR(256);
        DECLARE @recordcount INTEGER;
        DECLARE @logtimingidnew INTEGER;
        DECLARE @logmessage NVARCHAR(MAX);

        SELECT  @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.'
                + OBJECT_NAME(@@PROCID);

    --Log start time--

        EXEC [Operations].[LogTiming_Record] @userid = @userid,
            @logsource = @spname, @logtimingidnew = @logtimingidnew OUTPUT;


        UPDATE  [a]
        SET     [a].[RFV] = [b].[RFV]
               ,[a].[RFVsegmentRecency] = [b].[Recency]
               ,[a].[RFVsegmentValue] = [b].[Value]
               ,[a].[RFVsegmentFrequency] = [b].[Frequency]
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [CustomerID]
	--, ct0_12m, ct12_24m, ct24_36m -- DEBUG
	--, val0_12m, val12_24m, val24_36m -- DEBUG
                           ,[Recency]
                           ,[Value]
                           ,[Frequency]
                           ,CASE WHEN [Recency] = 'R' THEN [Recency] + '-' + [Value]
                                 ELSE [Recency] + '-' + [Value] + '-' + [Frequency]
                            END AS [RFV]
                    FROM    (
                             SELECT [CustomerID]
                                   ,[FirstRegDate]
                                   ,[FirstTransactionDT]
                                   ,[LastTransactionDT]
                                   ,[ctTransactions]
		--, ct0_12m, ct12_24m, ct24_36m -- DEBUG
		--, val0_12m, val12_24m, val24_36m -- DEBUG
                                   ,[sumRevenue]
                                   ,[Recency]
                                   ,CASE WHEN [Recency] = 'H'
                                              AND [ct0_12m] > 0
                                              AND [val0_12m] > 1000 THEN 'H'
                                         WHEN [Recency] = 'H'
                                              AND [ct0_12m] > 0
                                              AND [val0_12m] BETWEEN 250 AND 1000
                                         THEN 'M'
                                         WHEN [Recency] = 'H'
                                              AND [ct0_12m] > 0
                                              AND [val0_12m] <= 250 THEN 'L'
                                         WHEN [Recency] = 'M'
                                              AND [ct12_24m] > 0
                                              AND [val12_24m] > 1000 THEN 'H'
                                         WHEN [Recency] = 'M'
                                              AND [ct12_24m] > 0
                                              AND [val12_24m] BETWEEN 250 AND 1000
                                         THEN 'M'
                                         WHEN [Recency] = 'M'
                                              AND [ct12_24m] > 0
                                              AND [val12_24m] <= 250 THEN 'L'
                                         WHEN [Recency] = 'L'
                                              AND [ct24_36m] > 0
                                              AND [val24_36m] > 1000 THEN 'H'
                                         WHEN [Recency] = 'L'
                                              AND [ct24_36m] > 0
                                              AND [val24_36m] BETWEEN 250 AND 1000
                                         THEN 'M'
                                         WHEN [Recency] = 'L'
                                              AND [ct24_36m] > 0
                                              AND [val24_36m] <= 250 THEN 'L'
                                         WHEN [Recency] = 'R'
                                              AND [FirstRegDate] >= DATEADD(YEAR,
                                                              -1,
                                                              CONVERT(DATE, GETDATE()))
                                         THEN 'H'
                                         WHEN [Recency] = 'R'
                                              AND [FirstRegDate] BETWEEN DATEADD(YEAR,
                                                              -2,
                                                              CONVERT(DATE, GETDATE()))
                                                              AND
                                                              DATEADD(YEAR, -1,
                                                              CONVERT(DATE, GETDATE()))
                                         THEN 'M'
                                         WHEN [Recency] = 'R'
                                              AND [FirstRegDate] BETWEEN DATEADD(YEAR,
                                                              -3,
                                                              CONVERT(DATE, GETDATE()))
                                                              AND
                                                              DATEADD(YEAR, -2,
                                                              CONVERT(DATE, GETDATE()))
                                         THEN 'L'
                                         ELSE 'VL'
                                    END AS [Value]
                                   ,CASE WHEN [Recency] = 'H'
                                              AND [ct0_12m] > 10 THEN 'E'--'EST'
                                         WHEN [Recency] = 'H'
                                              AND [ct0_12m] BETWEEN 5 AND 10
                                         THEN 'F'--'FAM'
                                         WHEN [Recency] = 'H'
                                              AND [ct0_12m] BETWEEN 2 AND 4
                                         THEN 'T'--'TEN'
                                         WHEN [Recency] = 'H'
                                              AND [ct0_12m] < 2 THEN 'S' --'SOL'
                                         WHEN [Recency] = 'M'
                                              AND [ct12_24m] > 10 THEN 'E' --'EST'
                                         WHEN [Recency] = 'M'
                                              AND [ct12_24m] BETWEEN 5 AND 10
                                         THEN 'F' --'FAM'
                                         WHEN [Recency] = 'M'
                                              AND [ct12_24m] BETWEEN 2 AND 4
                                         THEN 'T' --'TEN'
                                         WHEN [Recency] = 'M'
                                              AND [ct12_24m] < 2 THEN 'S' --'SOL'
                                         WHEN [Recency] = 'L'
                                              AND [ct24_36m] > 10 THEN 'E' --'EST'
                                         WHEN [Recency] = 'L'
                                              AND [ct24_36m] BETWEEN 5 AND 10
                                         THEN 'F' --'FAM'
                                         WHEN [Recency] = 'L'
                                              AND [ct24_36m] BETWEEN 2 AND 4
                                         THEN 'T' --'TEN'
                                         WHEN [Recency] = 'L'
                                              AND [ct24_36m] < 2 THEN 'S' --'SOL'
                                         ELSE 'R' --'REG'
                                    END AS [Frequency]
                             FROM   (
                                     SELECT --top 1000
                                            [c].[CustomerID]
                                           ,MAX(CONVERT(DATE, [c].[DateRegistered], 103)) AS [FirstRegDate]
                                           ,ISNULL(MIN([SalesTransactionDate]),
                                                   '') AS [FirstTransactionDT]
                                           ,ISNULL(MAX([SalesTransactionDate]),
                                                   '') AS [LastTransactionDT]
                                           ,ISNULL(COUNT([SalesTransactionDate]),
                                                   0) AS [ctTransactions]
                                           ,SUM(ISNULL([b].[SalesAmountTotal], 0)) AS [sumRevenue]
                                           ,CASE WHEN MAX([SalesTransactionDate]) >= DATEADD(YEAR,
                                                              -1,
                                                              CONVERT(DATE, GETDATE()))
                                                 THEN 'H' --Live
                                                 WHEN MAX([SalesTransactionDate]) BETWEEN DATEADD(YEAR,
                                                              -2,
                                                              CONVERT(DATE, GETDATE()))
                                                              AND
                                                              DATEADD(YEAR, -1,
                                                              CONVERT(DATE, GETDATE()))
                                                 THEN 'M' -- Lapsed
                                                 WHEN MAX([SalesTransactionDate]) BETWEEN DATEADD(YEAR,
                                                              -3,
                                                              CONVERT(DATE, GETDATE()))
                                                              AND
                                                              DATEADD(YEAR, -2,
                                                              CONVERT(DATE, GETDATE()))
                                                 THEN 'L' -- Inactive
                                                 ELSE 'R' -- Registered
                                            END AS [Recency]
                                           ,SUM(CASE WHEN [SalesTransactionDate] >= DATEADD(YEAR,
                                                              -1,
                                                              CONVERT(DATE, GETDATE()))
                                                     THEN [b].[SalesAmountTotal]
                                                     ELSE 0
                                                END) AS [val0_12m]
                                           ,SUM(CASE WHEN [SalesTransactionDate] BETWEEN DATEADD(YEAR,
                                                              -2,
                                                              CONVERT(DATE, GETDATE()))
                                                              AND
                                                              DATEADD(YEAR, -1,
                                                              CONVERT(DATE, GETDATE()))
                                                     THEN [b].[SalesAmountTotal]
                                                     ELSE 0
                                                END) AS [val12_24m]
                                           ,SUM(CASE WHEN [SalesTransactionDate] BETWEEN DATEADD(YEAR,
                                                              -3,
                                                              CONVERT(DATE, GETDATE()))
                                                              AND
                                                              DATEADD(YEAR, -2,
                                                              CONVERT(DATE, GETDATE()))
                                                     THEN [b].[SalesAmountTotal]
                                                     ELSE 0
                                                END) AS [val24_36m]
                                           ,SUM(CASE WHEN [SalesTransactionDate] >= DATEADD(YEAR,
                                                              -1,
                                                              CONVERT(DATE, GETDATE()))
                                                     THEN 1
                                                     ELSE 0
                                                END) AS [ct0_12m]
                                           ,SUM(CASE WHEN [SalesTransactionDate] BETWEEN DATEADD(YEAR,
                                                              -2,
                                                              CONVERT(DATE, GETDATE()))
                                                              AND
                                                              DATEADD(YEAR, -1,
                                                              CONVERT(DATE, GETDATE()))
                                                     THEN 1
                                                     ELSE 0
                                                END) AS [ct12_24m]
                                           ,SUM(CASE WHEN [SalesTransactionDate] BETWEEN DATEADD(YEAR,
                                                              -3,
                                                              CONVERT(DATE, GETDATE()))
                                                              AND
                                                              DATEADD(YEAR, -2,
                                                              CONVERT(DATE, GETDATE()))
                                                     THEN 1
                                                     ELSE 0
                                                END) AS [ct24_36m]
                                     FROM   [Production].[Customer] [c] WITH (NOLOCK)
                                     LEFT JOIN [Staging].[STG_SalesTransaction] [b]
                                            WITH (NOLOCK)
                                     ON     [c].[CustomerID] = [b].[CustomerID]
                                            AND [c].[DateRegistered] IS NOT NULL
                                     GROUP BY [c].[CustomerID]
                                    ) [r]
                            ) [t]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];


	---Get RowCount
        SELECT  @recordcount = @@ROWCOUNT;

--    --Log end time

        EXEC [Operations].[LogTiming_Record] @userid = @userid,
            @logsource = @spname, @logtimingid = @logtimingidnew,
            @recordcount = @recordcount,
            @logtimingidnew = @logtimingidnew OUTPUT;
        RETURN;
    END;