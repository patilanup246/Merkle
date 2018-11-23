



CREATE PROCEDURE [Production].[Customer_Inferred_HomeStation]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

		--delcare variables for CRM auditing
        DECLARE @spname NVARCHAR(256);
        DECLARE @recordcount INTEGER;
        DECLARE @logtimingidnew INTEGER;
        DECLARE @logmessage NVARCHAR(MAX);
        DECLARE @userid INTEGER;



		--set userid to be 0 to be consistent with the other calls to the stored proc 
        SET @userid = 0; 

		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

		--   --Log start time--

		EXEC [Operations].[LogTiming_Record] @userid         = @userid,
                                         @logsource      = @spname,
                                         @logtimingidnew = @logtimingidnew OUTPUT

        SELECT  [CustomerID]
               ,[Origin_Station]
               ,[Trips]
               ,[LocationID]
        INTO    [#tmp_loc]
        FROM    (
                 SELECT [CustomerID]
                       ,[Origin_Station]
                       ,[Trips]
                       ,[loc].[LocationID]
                       ,DENSE_RANK() OVER (PARTITION BY [CustomerID] ORDER BY [Trips] DESC, [Min_Date] ASC) AS [rank]
                 FROM   (
                         SELECT [CustomerID]
                               ,[Origin_Station]
                               ,COUNT(1) AS [Trips]
                               ,MIN([SalesTransactionDate]) AS [Min_Date]
                         FROM   (
                                 SELECT [c].[CustomerID] AS [CustomerID]
                                       ,CONVERT(DATE, [c].[OutDepartureDateTime]) AS [TravelDate]
                                       ,CASE WHEN [f].[Name] = 'London Terminals'
                                             THEN 'EUS'
                                             WHEN [f].[Name] = 'LONDON ST PANCRAS'
                                             THEN 'EUS'
                                             WHEN [f].[Name] LIKE '%LONDN'
                                             THEN 'EUS'
                                             ELSE [f].[CRSCode]
                                        END AS [Origin_Station]
                                       ,[f].[CRSCode] AS [Origin_CRSCode]
                                       ,[f].[Name] AS [Origin_Station_Name]
                                       ,CAST([SalesTransactionDate] AS DATE) AS [SalesTransactionDate]
                                       ,[c].[IsReturnInd]
                                       ,[c].[IsReturnInferredInd]
                                 FROM   [Staging].[STG_Journey] [c]
                                 INNER JOIN [Staging].[STG_SalesTransaction] [a]
                                 ON     [a].[SalesTransactionID] = [c].[SalesTransactionID]
                                 INNER JOIN [Reference].[Location] [f]
                                 ON     [f].[LocationID] = [c].[LocationIDOrigin]
                                 WHERE  DATEDIFF(MONTH,
                                                 CAST([SalesTransactionDate] AS DATE),
                                                 CAST(GETDATE() AS DATE)) <= 12
                                        AND [c].[IsOutboundInd] = 1
                                ) [st]
                         WHERE  [Origin_Station] IS NOT NULL
                         GROUP BY [CustomerID]
                               ,[Origin_Station]
                        ) [data]
                 LEFT JOIN [Reference].[Location] [loc]
                 ON     [data].[Origin_Station] = [loc].[CRSCode]
                ) [ranked]
        WHERE   [rank] = 1;

        UPDATE  [cus]
        SET     [cus].[LocationIDHomeInferred] = [tmp].[LocationID]
        FROM    [CRM].[Production].[Customer] [cus]
        INNER JOIN [#tmp_loc] [tmp]
        ON      [cus].[CustomerID] = [tmp].[CustomerID];


        EXEC [Operations].[LogTiming_Record] @userid = @userid,
            @logsource = @spname, @logtimingid = @logtimingidnew,
            @recordcount = @recordcount,
            @logtimingidnew = @logtimingidnew OUTPUT;

    END;