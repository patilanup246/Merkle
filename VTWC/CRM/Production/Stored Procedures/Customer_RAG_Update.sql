


/*=========================================================================================== 

Name:           Customer_RAG_update
Purpose:        Update RAG Status for Customers based on Journeys 
Parameters:     @DebugPrint - Displays debug information to the message pane. 
                @DebugRecordSet - When implmented, used to control displaying debug recordset information 
                                  to screen, or storing debug recordsets to global temp tables. 
Notes:              

Created:        2018-08-15    Steve Forster 

Modified:         

Peer Review:     

Call script:    EXEC Production.[Customer_RAG_update] 

=================================================================================================*/ 

CREATE PROCEDURE [Production].[Customer_RAG_update]
    @PkgExecKey INT = -1
   ,@DebugPrint TINYINT = 0
   ,@DebugRecordSet TINYINT = 0
AS
    SET NOCOUNT ON; 
    SET XACT_ABORT ON; 

    BEGIN TRY 
        -- Your DDL starts here 


		--delcare variables for CRM auditing
        DECLARE @spname NVARCHAR(256);
        DECLARE @recordcount INTEGER;
        DECLARE @logtimingidnew INTEGER;
        DECLARE @logmessage NVARCHAR(MAX);
        DECLARE @userid INTEGER;


		---declare variables for DBA auditing
        DECLARE @ThisDb sysname = DB_NAME()
           ,@ThisProc sysname = ISNULL(OBJECT_NAME(@@PROCID),
                                       'Customer_RAG_update')
           ,@SPID INT = @@SPID;

        SELECT  @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.'
                + OBJECT_NAME(@@PROCID);

		--set userid to be 0 to be consistent with the other calls to the stored proc 
        SET @userid = 0; 

		----Log start time CRM Auditing--

        EXEC [Operations].[LogTiming_Record] @userid = @userid,
            @logsource = @spname, @logtimingidnew = @logtimingidnew OUTPUT;


		----Log start time DBA auditing


        EXEC [dbo].[uspAuditAddAudit] @AuditType = 'PROCESS START',
            @Process = @ThisProc, @DatabaseName = @ThisDb, @SPID = @SPID,
            @PrintToScreen = 1;

        DECLARE @ProcName AS VARCHAR(50) = @ThisProc
           ,@StepName AS VARCHAR(50)
           ,@ErrorNum AS INT
           ,@ErrorMsg AS VARCHAR(2048)
				--, @dbName		AS VARCHAR(30) = DB_NAME()
				--, @StartDate	AS DATE = GETDATE()-1
				--, @EndDate		AS DATE = GETDATE()
           ,@DayName AS VARCHAR(20) = DATENAME(WEEKDAY, GETDATE());
				--, @Sunday       AS BIT = 0

		-- Only run once per week - Defaulting to Sunday ?
        BEGIN TRY
            SET @StepName = 'Check Sunday';
            EXEC [dbo].[uspSSISProcStepStart] @ProcName, @StepName;

            IF @DayName <> 'Sunday'
                AND @DebugRecordSet = 0
                BEGIN
                    EXEC [dbo].[uspSSISProcStepSuccess] @ProcName, @StepName;
                    RETURN 0;
                END;
            ELSE
                EXEC [dbo].[uspSSISProcStepSuccess] @ProcName, @StepName;
        END TRY
        BEGIN CATCH
            SET @ErrorNum = ERROR_NUMBER();
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC [dbo].[uspSSISProcStepFailed] @ProcName, @StepName, @ErrorNum,
                @ErrorMsg, @PkgExecKey;
        END CATCH;
        RAISERROR('',10,1) WITH NOWAIT;

        BEGIN TRY
            SET @StepName = '#RetentionJourneys';
            EXEC [dbo].[uspSSISProcStepStart] @ProcName, @StepName;
		
            IF OBJECT_ID('tempdb..#RetentionJourneys', 'U') IS NOT NULL
                DROP TABLE [#RetentionJourneys]; 

			CREATE TABLE #RetentionJourneys 
			(	   [CustomerID] int 
				  ,[JourneyRoute] nvarchar(1024) 
				  ,[DepartureDate] Date) 

            INSERT  INTO [#RetentionJourneys]
            SELECT  [a].[CustomerID]
                   ,(CASE WHEN [b].[Name] LIKE 'LONDON%'
                               OR [b].[Name] LIKE '%LONDN' THEN 'LONDON'
                          ELSE [b].[Name]
                     END) + ' TO '
                    + (CASE WHEN [c].[Name] LIKE 'LONDON%'
                                 OR [c].[Name] LIKE '%LONDN' THEN 'LONDON'
                            ELSE [c].[Name]
                       END) AS [JourneyRoute]
                   ,CAST([a].[OutDepartureDateTime] AS DATE) AS [DepartureDate]
            FROM    [Staging].[STG_Journey] [a]
            INNER JOIN [Staging].[STG_JourneyLeg] [l]
            ON      [a].[JourneyID] = [l].[JourneyID]
                    AND [l].[TOCID] = 31 /* VT */
                    AND [a].[ArchivedInd] = 0
                    AND [a].[OutDepartureDateTime] > DATEADD(YEAR, -1, GETDATE())
                    AND [IsOutboundInd] = 1
            INNER JOIN [Reference].[Location] [b] WITH (NOLOCK)
            ON      [b].[LocationID] = [a].[LocationIDOrigin]
            INNER JOIN [Reference].[Location] [c] WITH (NOLOCK)
            ON      [c].[LocationID] = [a].[LocationIDDestination]

            EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
            SET @ErrorNum = ERROR_NUMBER();
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC [dbo].[uspSSISProcStepFailed] @ProcName, @StepName, @ErrorNum,
                @ErrorMsg, @PkgExecKey;
        END CATCH;
        RAISERROR('',10,1) WITH NOWAIT;

		----create journey sequence to calculate days between the journeys for those who travelled 6 or more times in the last 12 months; 
        BEGIN TRY
            SET @StepName = '#RetentionAvgJourneys';
            EXEC [dbo].[uspSSISProcStepStart] @ProcName, @StepName;

            IF OBJECT_ID('tempdb..#RetentionAvgJourneys', 'U') IS NOT NULL
                DROP TABLE [#RetentionAvgJourneys]; 

            CREATE TABLE [#RetentionAvgJourneys]
                (
                 [CustomerID] INT
                ,[JourneyRoute] NVARCHAR(1024)
                ,[DepartureDate] DATE
                ,[JourneySeqRt] INT
                ,[NextDepartureDateRt] DATE
                ,[number_journeys_all] INT
                ,[number_journeys_route] INT
                );
                WITH    [JourneySeq]
                          AS (
                              SELECT DISTINCT
                                        [a].[CustomerID]
                                       ,[a].[JourneyRoute]
                                       ,[DepartureDate]
                                       ,[number_journeys_route]
                                       ,[number_journeys_all]
                                       ,DENSE_RANK() OVER (PARTITION BY [a].[CustomerID],
                                                           [a].[JourneyRoute] ORDER BY [DepartureDate]) AS [JourneySeqRt]
                              FROM      [#RetentionJourneys] [a]
                              LEFT JOIN (
                                         SELECT [CustomerID]
                                               ,[JourneyRoute]
                                               ,COUNT(DISTINCT [DepartureDate]) AS [number_journeys_route]
                                         FROM   [#RetentionJourneys]
                                         GROUP BY [CustomerID]
                                               ,[JourneyRoute]
                                        ) [b]
                              ON        [a].[CustomerID] = [b].[CustomerID]
                                        AND [a].[JourneyRoute] = [b].[JourneyRoute]
                              LEFT JOIN (
                                         SELECT [CustomerID]
                                               ,COUNT(DISTINCT [DepartureDate]) AS [number_journeys_all]
                                         FROM   [#RetentionJourneys]
                                         GROUP BY [CustomerID]
                                        ) [c]
                              ON        [a].[CustomerID] = [c].[CustomerID]
                             )
                INSERT  INTO [#RetentionAvgJourneys]
                SELECT DISTINCT
                        [a].[CustomerID]
                       ,[a].[JourneyRoute]
                       ,[a].[DepartureDate]
                       ,[a].[JourneySeqRt]
                       ,[b].[NextDepartureDateRt]
                       ,[a].[number_journeys_all]
                       ,[a].[number_journeys_route]
                FROM    [JourneySeq] [a]
                LEFT JOIN (
                           SELECT DISTINCT
                                    [CustomerID]
                                   ,[JourneyRoute]
                                   ,[DepartureDate] AS [NextDepartureDateRt]
                                   ,([JourneySeqRt] - 1) AS [JourneySeqRtNext]
                           FROM     [JourneySeq]
                          ) [b]
                ON      [a].[CustomerID] = [b].[CustomerID]
                        AND [a].[JourneyRoute] = [b].[JourneyRoute]
                        AND [a].[JourneySeqRt] = [b].[JourneySeqRtNext]
                WHERE   [number_journeys_all] >= 6;  

            EXEC [dbo].[uspSSISProcStepSuccess] @ProcName, @StepName;
        END TRY
        BEGIN CATCH
            SET @ErrorNum = ERROR_NUMBER();
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC [dbo].[uspSSISProcStepFailed] @ProcName, @StepName, @ErrorNum,
                @ErrorMsg, @PkgExecKey;
        END CATCH;
        RAISERROR('',10,1) WITH NOWAIT;


		---calculate moving averages and RAG status 
        BEGIN TRY
            SET @StepName = '#RetentionMA';
            EXEC [dbo].[uspSSISProcStepStart] @ProcName, @StepName;

            IF OBJECT_ID('tempdb..#RetentionMA', 'U') IS NOT NULL
                DROP TABLE [#RetentionMA]; 

            CREATE TABLE [#RetentionMA]
                (
                 [CustomerID] INT
                ,[JourneyRoute] NVARCHAR(1024)
                ,[Average] DECIMAL(14, 2)
                ,[SD] DECIMAL(14, 2)
                ,[ControlLimit_1SD] DECIMAL(14, 2)
                ,[ControlLimit_2SD] DECIMAL(14, 2)
                ,[SMA2] DECIMAL(14, 2)
                ,[LMA5] DECIMAL(14, 2)
                ,[days_between_journeys] INT
                ,[JourneySeqRt] INT
                ,[DepartureDate] DATE
                ,[NextDepartureDateRt] DATE
                ,[RAGStatus] VARCHAR(20)
                ); 

            INSERT  INTO [#RetentionMA]
            SELECT  [CustomerID]
                   ,[JourneyRoute]
                   ,[Average]
                   ,[SD]
                   ,[SD] + [Average] AS [ControlLimit_1SD]
                   ,(2 * [SD]) + [Average] AS [ControlLimit_2SD]
                   ,[SMA2]
                   ,[LMA5]
                   ,[days_between_journeys]
                   ,[JourneySeqRt]
                   ,[DepartureDate]
                   ,[NextDepartureDateRt]
                   ,CASE WHEN [SMA2] <= ([SD] + [Average])
                              AND [days_between_journeys] <= (2 * [SD]) + [Average]
                         THEN 'GREEN'
                         WHEN [SMA2] > (2 * [SD]) + [Average]
                              AND [LMA5] > ([SD] + [Average]) THEN 'RED'
                         WHEN [days_between_journeys] > (2 * [SD]) + [Average]
                              OR [SMA2] > ([SD] + [Average]) THEN 'AMBER'
                    END AS [RAGStatus]
            FROM    (
                     SELECT [CustomerID]
                           ,[JourneyRoute]
                           ,[JourneySeqRt]
                           ,[DepartureDate]
                           ,[NextDepartureDateRt]
                           ,[number_journeys_route]
                           ,DATEDIFF(DAY, [DepartureDate],
                                     CASE WHEN [NextDepartureDateRt] IS NULL
                                          THEN GETDATE()
                                          ELSE [NextDepartureDateRt]
                                     END) AS [days_between_journeys]
                           ,CASE WHEN [JourneySeqRt] >= 2
                                 THEN AVG(DATEDIFF(DAY, [DepartureDate],
                                                   CASE WHEN [NextDepartureDateRt] IS NULL
                                                        THEN GETDATE()
                                                        ELSE [NextDepartureDateRt]
                                                   END) * 1.0000) OVER (PARTITION BY [CustomerID],
                                                              [JourneyRoute] ORDER BY [JourneySeqRt] ASC 
				   ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
                                 ELSE NULL
                            END AS [SMA2]
                           ,CASE WHEN [JourneySeqRt] >= 5
                                 THEN AVG(DATEDIFF(DAY, [DepartureDate],
                                                   CASE WHEN [NextDepartureDateRt] IS NULL
                                                        THEN GETDATE()
                                                        ELSE [NextDepartureDateRt]
                                                   END) * 1.0000) OVER (PARTITION BY [CustomerID],
                                                              [JourneyRoute] ORDER BY [JourneySeqRt] ASC 
				   ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
                                 ELSE NULL
                            END AS [LMA5]
                           ,STDEV(DATEDIFF(DAY, [DepartureDate],
                                           [NextDepartureDateRt]) * 1.0000) OVER (PARTITION BY [CustomerID],
                                                              [JourneyRoute]) AS [SD]
                           ,AVG(DATEDIFF(DAY, [DepartureDate],
                                         [NextDepartureDateRt]) * 1.0000) OVER (PARTITION BY [CustomerID],
                                                              [JourneyRoute]) AS [Average]
                     FROM   [#RetentionAvgJourneys]
                    ) [a]
            WHERE   [NextDepartureDateRt] IS NULL
                    AND [number_journeys_route] >= 6;  

            EXEC [dbo].[uspSSISProcStepSuccess] @ProcName, @StepName;
        END TRY
        BEGIN CATCH
            SET @ErrorNum = ERROR_NUMBER();
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC [dbo].[uspSSISProcStepFailed] @ProcName, @StepName, @ErrorNum,
                @ErrorMsg, @PkgExecKey;
        END CATCH;
        RAISERROR('',10,1) WITH NOWAIT;

		-------------------------------------LESS THAN 6 JOURNEYS PER ROUTE-------------------------------------------------------------- 

		--create cut off points for less travelled routes  
        BEGIN TRY
            SET @StepName = '#AvgLessFrequent';
            EXEC [dbo].[uspSSISProcStepStart] @ProcName, @StepName;

            IF OBJECT_ID('tempdb..#AvgLessFrequent', 'U') IS NOT NULL
                DROP TABLE [#AvgLessFrequent]; 

            CREATE TABLE [#AvgLessFrequent]
                (
                 [JourneyRouteGrouped] NVARCHAR(1024)
                ,[JourneySeqRt] INT
                ,[decile] INT
                ,[days_between_journeys_max] BIGINT
                ); 
  

            INSERT  INTO [#AvgLessFrequent]
            SELECT  [JourneyRouteGrouped]
                   ,[JourneySeqRt]
                   ,[decile]
                   ,MAX([days_between_journeys]) AS [days_between_journeys_max]
            FROM    ( (
                       SELECT   [JourneySeqRt]
                               ,CASE WHEN [customers] < 2000 THEN 'OTHER'
                                     ELSE [a].[JourneyRoute]
                                END AS [JourneyRouteGrouped]
                               ,DATEDIFF(DAY, [DepartureDate],
                                         [NextDepartureDateRt]) AS [days_between_journeys]
                               ,NTILE(20) OVER (PARTITION BY CASE
                                                              WHEN [customers] < 2000
                                                              THEN 'OTHER'
                                                              ELSE [a].[JourneyRoute]
                                                             END, [JourneySeqRt] ORDER BY DATEDIFF(DAY,
                                                              [DepartureDate],
                                                              [NextDepartureDateRt])) AS [decile]
                       FROM     [#RetentionAvgJourneys] [a]
                       LEFT JOIN (
                                  SELECT    COUNT(DISTINCT [CustomerID]) AS [customers]
                                           ,[JourneyRoute]
                                  FROM      [#RetentionAvgJourneys]
                                  WHERE     [JourneySeqRt] = 1
                                            AND [NextDepartureDateRt] IS NOT NULL
                                  GROUP BY  [JourneyRoute]
                                 ) [b]
                       ON       [a].[JourneyRoute] = [b].[JourneyRoute]
                       WHERE    [NextDepartureDateRt] IS NOT NULL
                      ) ) [z]
            WHERE   [JourneySeqRt] <= 5
                    AND [decile] = 15
            GROUP BY [JourneyRouteGrouped]
                   ,[JourneySeqRt]
                   ,[decile]
            ORDER BY [JourneyRouteGrouped]
                   ,[JourneySeqRt]
                   ,[decile]; 

            EXEC [dbo].[uspSSISProcStepSuccess] @ProcName, @StepName;
        END TRY
        BEGIN CATCH
            SET @ErrorNum = ERROR_NUMBER();
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC [dbo].[uspSSISProcStepFailed] @ProcName, @StepName, @ErrorNum,
                @ErrorMsg, @PkgExecKey;
        END CATCH;
        RAISERROR('',10,1) WITH NOWAIT;


        BEGIN TRY
            SET @StepName = '#RetentionSD';
            EXEC [dbo].[uspSSISProcStepStart] @ProcName, @StepName;

            IF OBJECT_ID('tempdb..#RetentionSD', 'U') IS NOT NULL
                DROP TABLE [#RetentionSD]; 

            CREATE TABLE [#RetentionSD]
                (
                 [CustomerId] INT
                ,[days_last_journey] INT
                ,[DepartureDate] DATE
                ,[JourneySeqRt] INT
                ,[JourneyRouteGrouped] NVARCHAR(1024)
                ,[days_75] INT
                ,[RAGStatus] NVARCHAR(20)
                ); 

            INSERT  INTO [#RetentionSD]
            SELECT  [CustomerId]
                   ,[days_last_journey]
                   ,[DepartureDate]
                   ,[x].[JourneySeqRt]
                   ,[x].[JourneyRouteGrouped]
                   ,[days_75]
                   ,CASE WHEN [days_last_journey] > [days_75] THEN 'AMBER'
                         ELSE 'GREEN'
                    END AS [RAGStatus]
            FROM    (
                     SELECT [CustomerID]
                           ,DATEDIFF(DAY, [DepartureDate], GETDATE()) AS [days_last_journey]
                           ,[JourneySeqRt]
                           ,[DepartureDate]
                           ,[customers]
                           ,CASE WHEN [customers] < 2000
                                      OR [customers] IS NULL THEN 'OTHER'
                                 ELSE [a].[JourneyRoute]
                            END AS [JourneyRouteGrouped]
                     FROM   [#RetentionAvgJourneys] [a]
                     LEFT JOIN (
                                SELECT  COUNT(DISTINCT [CustomerID]) AS [customers]
                                       ,[JourneyRoute]
                                FROM    [#RetentionAvgJourneys] [a]
                                WHERE   [JourneySeqRt] = 1
                                        AND [NextDepartureDateRt] IS NOT NULL
                                GROUP BY [JourneyRoute]
                               ) [y]
                     ON     [a].[JourneyRoute] = [y].[JourneyRoute]
                     WHERE  [NextDepartureDateRt] IS NULL
                            AND [number_journeys_route] < 6
                            AND [number_journeys_all] >= 6
                    ) [x]
            LEFT JOIN (
                       SELECT   [JourneyRouteGrouped]
                               ,[JourneySeqRt]
                               ,[days_between_journeys_max] AS [days_75]
                       FROM     [#AvgLessFrequent]
                      ) [y]
            ON      [x].[JourneyRouteGrouped] = [y].[JourneyRouteGrouped]
                    AND [x].[JourneySeqRt] = [y].[JourneySeqRt];  

            EXEC [dbo].[uspSSISProcStepSuccess] @ProcName, @StepName;
        END TRY
        BEGIN CATCH
            SET @ErrorNum = ERROR_NUMBER();
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC [dbo].[uspSSISProcStepFailed] @ProcName, @StepName, @ErrorNum,
                @ErrorMsg, @PkgExecKey;
        END CATCH;
        RAISERROR('',10,1) WITH NOWAIT;

		-----CREATE CUSTOMER LEVEL RAG - one for frequent journey and one for less frequent 
		-----for frequent journey select the most travelled route 
		-----for less frequent select the least severe status 
 
        BEGIN TRY
            SET @StepName = '#RetentionSD';
            EXEC [dbo].[uspSSISProcStepStart] @ProcName, @StepName;
            IF OBJECT_ID('[ibm_sandbox].CRM.Retention_RAG', 'U') IS NOT NULL
                DROP TABLE [ibm_sandbox].[CRM].[Retention_RAG]; 

            SELECT  ISNULL([b].[CustomerID], [d].[CustomerID]) AS [CustomerID]
                   ,[FreqRoute_LastTravelled]
                   ,[FreqRoute_TimesTravelled]
                   ,[RAGStatus_FreqRoute]
                   ,[LessFreqRoute_TimesTravelled]
                   ,[LessFreqRoute_LastTravelled]
                   ,[RAGStatus_LessFreqRoute]
            INTO    [ibm_sandbox].[CRM].[Retention_RAG]
            FROM    (
                     SELECT [CustomerID]
                           ,[FreqRoute_LastTravelled]
                           ,[FreqRoute_TimesTravelled]
                           ,[RAGStatus] AS [RAGStatus_FreqRoute]
                     FROM   (
                             SELECT [CustomerID]
                                   ,[RAGStatus]
                                   ,[JourneySeqRt] AS [FreqRoute_TimesTravelled]
                                   ,[DepartureDate] AS [FreqRoute_LastTravelled]
                                   ,ROW_NUMBER() OVER (PARTITION BY [CustomerID] ORDER BY [JourneySeqRt] DESC) AS [route_freq_rank]
                             FROM   [#RetentionMA]
                            ) [a]
                     WHERE  [route_freq_rank] = 1
                    ) [b]
            FULL OUTER JOIN (
                             SELECT [CustomerId]
                                   ,[LessFreqRoute_TimesTravelled]
                                   ,[LessFreqRoute_LastTravelled]
                                   ,[RAGStatus] AS [RAGStatus_LessFreqRoute]
                             FROM   (
                                     SELECT [CustomerId]
                                           ,[RAGStatus]
                                           ,[JourneySeqRt] AS [LessFreqRoute_TimesTravelled]
                                           ,[DepartureDate] AS [LessFreqRoute_LastTravelled]
                                           ,ROW_NUMBER() OVER (PARTITION BY [CustomerId] ORDER BY [RAGStatus] ASC, [JourneySeqRt] DESC) AS [RAG_rank]
                                     FROM   [#RetentionSD]
                                    ) [c]
                             WHERE  [RAG_rank] = 1
                            ) [d]
            ON      [b].[CustomerID] = [d].[CustomerID]; 

            EXEC [dbo].[uspSSISProcStepSuccess] @ProcName, @StepName;
        END TRY
        BEGIN CATCH
            SET @ErrorNum = ERROR_NUMBER();
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC [dbo].[uspSSISProcStepFailed] @ProcName, @StepName, @ErrorNum,
                @ErrorMsg, @PkgExecKey;
        END CATCH;
        RAISERROR('',10,1) WITH NOWAIT;


        BEGIN TRY
            SET @StepName = 'Create IX_CustomerID';
            EXEC [dbo].[uspSSISProcStepStart] @ProcName, @StepName;

            CREATE INDEX [IX_CustomerID] ON [ibm_sandbox].[CRM].[Retention_RAG] ([CustomerID]); 

            EXEC [dbo].[uspSSISProcStepSuccess] @ProcName, @StepName;
        END TRY
        BEGIN CATCH
            SET @ErrorNum = ERROR_NUMBER();
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC [dbo].[uspSSISProcStepFailed] @ProcName, @StepName, @ErrorNum,
                @ErrorMsg, @PkgExecKey;
        END CATCH;
        RAISERROR('',10,1) WITH NOWAIT;

		--insert into [emm_sandbox].[Retention_RAG_History] 
		--select *, getdate() as DateCalculated 
		--from [emm_sandbox].[Retention_RAG];',  
		--        @database_name=N'emm_sandbox',  
		--        @flags=0 

		--    --Log end time

        EXEC [Operations].[LogTiming_Record] @userid = @userid,
            @logsource = @spname, @logtimingid = @logtimingidnew,
            @recordcount = @recordcount,
            @logtimingidnew = @logtimingidnew OUTPUT;


        RETURN 0;

        -- and ends here 
    END TRY 

    BEGIN CATCH 

        DECLARE @ErrorMessage VARCHAR(4000)= ERROR_MESSAGE()
           ,@ErrorNumber INT = ERROR_NUMBER()
           ,@ErrorSeverity INT= ERROR_SEVERITY()
           ,@ErrorState INT = ERROR_STATE()
           ,@ErrorLine INT = ERROR_LINE()
           ,@ErrorProcedure VARCHAR(126)= ISNULL(ERROR_PROCEDURE(), 'N/A'); 

        --Rethrow the error 
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState); 

    END CATCH; 
GO 

