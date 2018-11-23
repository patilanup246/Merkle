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
	@PkgExecKey INT = -1,
    @DebugPrint tinyint = 0, 
    @DebugRecordSet tinyint = 0 
AS 
    SET NOCOUNT ON; 
    SET XACT_ABORT ON; 

    BEGIN TRY 
        -- Your DDL starts here 
		DECLARE @ThisDb sysname = DB_NAME()
			   ,@ThisProc sysname = ISNULL(OBJECT_NAME(@@PROCID), 'Customer_RAG_update')
			   ,@SPID int = @@SPID

		EXEC dbo.uspAuditAddAudit
			 @AuditType='PROCESS START'
			,@Process=@ThisProc, @DatabaseName=@ThisDb, @SPID=@SPID, @PrintToScreen=1

		DECLARE   @ProcName		AS VARCHAR(50) = @ThisProc
				, @StepName		AS VARCHAR(50)
				, @ErrorNum		AS INT
				, @ErrorMsg		AS VARCHAR(2048)
				--, @dbName		AS VARCHAR(30) = DB_NAME()
				--, @StartDate	AS DATE = GETDATE()-1
				--, @EndDate		AS DATE = GETDATE()
				, @DayName		AS VARCHAR(20) = DATENAME(weekday, getdate())
				--, @Sunday       AS BIT = 0

		-- Only run once per week - Defaulting to Sunday ?
        BEGIN TRY
			SET @StepName = 'Check Sunday'
			EXEC dbo.uspSSISProcStepStart @ProcName, @StepName

			IF @DayName<>'Sunday' AND @DebugRecordSet=0
				BEGIN
					EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
					RETURN 0
				END
			ELSE
				EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
                SET @ErrorNum = ERROR_NUMBER()
                SET @ErrorMsg = ERROR_MESSAGE()
                EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
        END CATCH ;
        RAISERROR('',10,1) WITH NOWAIT

        BEGIN TRY
            SET @StepName = '#RetentionJourneys'
            EXEC dbo.uspSSISProcStepStart @ProcName, @StepName
		
			IF OBJECT_ID('tempdb..#RetentionJourneys', 'U') IS NOT NULL    
				drop table #RetentionJourneys; 

			CREATE TABLE #RetentionJourneys 
			(	   [CustomerID] int 
				  ,[SalesTransactionID] int 
				  ,[SalesTransactionDate] Date 
				  ,[JourneyRoute] nvarchar(1024) 
				  ,[DepartureDate] Date) 

			INSERT INTO #RetentionJourneys 
			SELECT  e.CustomerID, 
					e.SalesTransactionID, 
					CAST(e.SalesTransactionDate AS DATE) as SalesTransactionDate, 
					(CASE WHEN b.Name like 'LONDON%' OR b.Name like '%LONDN' THEN 'LONDON' ELSE b.Name END)
					+ ' TO ' + (CASE WHEN c.Name LIKE 'LONDON%' OR c.Name like '%LONDN' THEN 'LONDON' ELSE c.Name END) as JourneyRoute, 
					CAST(a.[OutDepartureDateTime] AS DATE) As DepartureDate
					FROM [Staging].[STG_Journey] a 
					INNER JOIN Staging.stg_journeyLeg l					ON a.journeyid=l.JourneyID 
																			and l.tocid=31 /* VT */
																			and a.[ArchivedInd] = 0 
																			and a.[OutDepartureDateTime] > DATEADD(year,-1,GETDATE()) 
																			AND [IsOutboundInd] = 1 

					inner join [Reference].[Location] b with(nolock)			on b.LocationId = a.LocationIDOrigin 
					inner join [Reference].[Location] c with(nolock)			on c.LocationId = a.LocationIDDestination 
					inner join [Staging].[STG_SalesDetail] d with(nolock)		on a.SalesDetailID = d.salesdetailid and istrainticketind = 1  
					inner join [Staging].[STG_SalesTransaction] e with(nolock)	on d.salestransactionid = e.salestransactionid;
            EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
                SET @ErrorNum = ERROR_NUMBER()
                SET @ErrorMsg = ERROR_MESSAGE()
                EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
        END CATCH ;
        RAISERROR('',10,1) WITH NOWAIT

		----create journey sequence to calculate days between the journeys for those who travelled 6 or more times in the last 12 months; 
        BEGIN TRY
            SET @StepName = '#RetentionAvgJourneys'
            EXEC dbo.uspSSISProcStepStart @ProcName, @StepName

			IF OBJECT_ID('tempdb..#RetentionAvgJourneys', 'U') IS NOT NULL    
				drop table #RetentionAvgJourneys; 

			CREATE TABLE #RetentionAvgJourneys 
			(			CustomerID int, 
						JourneyRoute nvarchar(1024), 
						[DepartureDate] Date, 
						JourneySeqRt int, 
						NextDepartureDateRt Date, 
						number_journeys_all int, 
						number_journeys_route int)

			;WITH JourneySeq 
			AS  
			(SELECT DISTINCT 
				 a.CustomerID, 
				 a.JourneyRoute, 
				 [DepartureDate], 
				 number_journeys_route, 
				 number_journeys_all, 
				 DENSE_RANK ()  OVER (PARTITION BY A.CustomerID, a.JourneyRoute ORDER BY DepartureDate) as JourneySeqRt 
			  FROM #RetentionJourneys a 

			  LEFT JOIN 
			   (select customerid, JourneyRoute, count (distinct DepartureDate) as number_journeys_route 
				from  #RetentionJourneys 
				group by CustomerID, JourneyRoute
			   ) b 
			   on a.CustomerId = b.CustomerId and a.JourneyRoute = b.JourneyRoute 

			   LEFT JOIN 
			   (select customerid, count (distinct DepartureDate) as number_journeys_all 
				from  #RetentionJourneys 
				group by CustomerID
				) c 
			   on a.CustomerId = c.CustomerId  
			)  
			INSERT INTO #RetentionAvgJourneys  
			SELECT DISTINCT 
						 a.CustomerID, 
						a.JourneyRoute, 
						a.[DepartureDate], 
						a.JourneySeqRt, 
						b.NextDepartureDateRt, 
						a.number_journeys_all, 
						a.number_journeys_route 
			FROM JourneySeq a 
			LEFT JOIN  
			(SELECT DISTINCT CustomerID, JourneyRoute, DepartureDate as NextDepartureDateRt, 
			(JourneySeqRt - 1) as JourneySeqRtNext 
			FROM JourneySeq
			) b 
			on a.CustomerId = b.CustomerID and a.JourneyRoute = b.JourneyRoute 
							and a.JourneySeqRt = b.JourneySeqRtNext 
			WHERE     number_journeys_all >= 6  

            EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
                SET @ErrorNum = ERROR_NUMBER()
                SET @ErrorMsg = ERROR_MESSAGE()
                EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
        END CATCH ;
        RAISERROR('',10,1) WITH NOWAIT


		---calculate moving averages and RAG status 
        BEGIN TRY
            SET @StepName = '#RetentionMA'
            EXEC dbo.uspSSISProcStepStart @ProcName, @StepName

			IF OBJECT_ID('tempdb..#RetentionMA', 'U') IS NOT NULL    
				drop table #RetentionMA; 

			CREATE TABLE #RetentionMA 
			(	CustomerID int,  
				JourneyRoute nvarchar(1024),  
				Average decimal(14,2),  
				SD decimal(14,2),  
				ControlLimit_1SD decimal(14,2),  
				ControlLimit_2SD decimal(14,2),  
				SMA2 decimal(14,2),  
				LMA5 decimal(14,2),  
				days_between_journeys int,  
				JourneySeqRt int,  
				DepartureDate Date,  
				NextDepartureDateRt Date,  
				RAGStatus varchar(20)
			) 

			INSERT INTO #RetentionMA 
			SELECT   CustomerID, JourneyRoute, Average, SD, SD +Average as ControlLimit_1SD, (2* SD) +Average as ControlLimit_2SD,  
							SMA2, LMA5, days_between_journeys, JourneySeqRt, DepartureDate, NextDepartureDateRt, 
							CASE WHEN SMA2 <= (SD+ Average) AND days_between_journeys <= (2*SD)+ Average THEN 'GREEN' 
							WHEN SMA2 > (2*SD)+ Average AND LMA5 > (SD+ Average) THEN 'RED' 
							WHEN days_between_journeys > (2*SD)+ Average OR SMA2 > (SD+ Average) THEN  'AMBER' END 
							AS RAGStatus 
			FROM 
			(SELECT  
					CustomerID, JourneyRoute, JourneySeqRt, DepartureDate, NextDepartureDateRt, number_journeys_route, 
					DATEDIFF(day,DepartureDate, CASE WHEN NextDepartureDateRt IS NULL THEN GETDATE() ELSE NextDepartureDateRt END) as days_between_journeys, 
					  CASE WHEN JourneySeqRt >= 2 THEN 
						   AVG (DATEDIFF(day,DepartureDate, CASE WHEN NextDepartureDateRt IS NULL THEN GETDATE() 
					  ELSE NextDepartureDateRt END) *1.0000)  
				   OVER (PARTITION BY CustomerID, JourneyRoute 
				   ORDER BY JourneySeqRt ASC 
				   ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) 
				   ELSE NULL END 
				   as SMA2, 

				   CASE WHEN JourneySeqRt >= 5 THEN 
					   AVG (DATEDIFF(day,DepartureDate, CASE WHEN NextDepartureDateRt IS NULL THEN GETDATE() ELSE NextDepartureDateRt END)*1.0000 )  
				   OVER (PARTITION BY CustomerID, JourneyRoute 
				   ORDER BY JourneySeqRt ASC 
				   ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) 

				   ELSE NULL END 

				   as LMA5, 

				  STDEV(DATEDIFF(day,DepartureDate, NextDepartureDateRt) *1.0000)  

				OVER (PARTITION BY CustomerID, JourneyRoute) as SD, 
				AVG (DATEDIFF(day,DepartureDate, NextDepartureDateRt) *1.0000)  
				OVER (PARTITION BY CustomerID, JourneyRoute) as Average 

			  FROM #RetentionAvgJourneys 
			) a 

			where NextDepartureDateRt is null and number_journeys_route >= 6  

            EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
                SET @ErrorNum = ERROR_NUMBER()
                SET @ErrorMsg = ERROR_MESSAGE()
                EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
        END CATCH ;
        RAISERROR('',10,1) WITH NOWAIT

		-------------------------------------LESS THAN 6 JOURNEYS PER ROUTE-------------------------------------------------------------- 

		--create cut off points for less travelled routes  
        BEGIN TRY
            SET @StepName = '#AvgLessFrequent'
            EXEC dbo.uspSSISProcStepStart @ProcName, @StepName

			IF OBJECT_ID('tempdb..#AvgLessFrequent', 'U') IS NOT NULL    
				drop table #AvgLessFrequent; 

			CREATE TABLE #AvgLessFrequent 
			(
				JourneyRouteGrouped nvarchar(1024), 
				JourneySeqRt int, 
				decile int, 
				days_between_journeys_max bigint
			) 
  

			INSERT INTO #AvgLessFrequent 
			select  JourneyRouteGrouped, JourneySeqRt, decile, max([days_between_journeys]) as [days_between_journeys_max] 
			from    
			( 
			(select    JourneySeqRt, CASE WHEN customers < 2000 THEN 'OTHER' ELSE a.JourneyRoute END as JourneyRouteGrouped, 
							DATEDIFF(day, [DepartureDate], NextDepartureDateRt) as [days_between_journeys],  
							ntile(20) over (partition by CASE WHEN customers < 2000 THEN 'OTHER' ELSE a.JourneyRoute END, JourneySeqRt 
							order by DATEDIFF(day, [DepartureDate], NextDepartureDateRt)) as decile 
					 from   #RetentionAvgJourneys a 
			LEFT JOIN  
			(SELECT  
						count (distinct CustomerID) as customers, 
						JourneyRoute 
						FROM #RetentionAvgJourneys 
						where  JourneySeqRt = 1 and nextdeparturedatert is not null 
						group by JourneyRoute) b 
					on a.JourneyRoute = b.JourneyRoute 
					where   NextDepartureDateRt is NOT NULL )) z 
			where JourneySeqRt <=5 and decile = 15 
			group by  JourneyRouteGrouped, JourneySeqRt, decile 
			order by  JourneyRouteGrouped, JourneySeqRt, decile 

            EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
                SET @ErrorNum = ERROR_NUMBER()
                SET @ErrorMsg = ERROR_MESSAGE()
                EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
        END CATCH ;
        RAISERROR('',10,1) WITH NOWAIT


        BEGIN TRY
            SET @StepName = '#RetentionSD'
            EXEC dbo.uspSSISProcStepStart @ProcName, @StepName

			IF OBJECT_ID('tempdb..#RetentionSD', 'U') IS NOT NULL    
				drop table #RetentionSD; 

			CREATE TABLE #RetentionSD 
			(	CustomerId int, 
				days_last_journey int,  
				DepartureDate Date, 
				JourneySeqRt int, 
				JourneyRouteGrouped nvarchar(1024), 
				days_75 int, 
				RAGStatus nvarchar(20)
			) 

			INSERT INTO #RetentionSD 
			SELECT CustomerId, 
			days_last_journey,  
			DepartureDate, 
			x.JourneySeqRt, 
			x.JourneyRouteGrouped, 
			days_75, 
			CASE WHEN days_last_journey > days_75  then 'AMBER'  
						ELSE 'GREEN'  
						END as RAGStatus 
			FROM  
			(SELECT  CustomerID, DATEDIFF(day,DepartureDate, GETDATE()) as days_last_journey, JourneySeqRt, DepartureDate, customers, 
			CASE WHEN customers < 2000 or customers is null THEN 'OTHER' ELSE a.JourneyRoute END as JourneyRouteGrouped 
			FROM #RetentionAvgJourneys a 
			LEFT JOIN  
			(SELECT  
						count (distinct CustomerID) as customers, 
						JourneyRoute 
						FROM #RetentionAvgJourneys a 
						where  JourneySeqRt = 1 and nextdeparturedatert is not null 
						group by JourneyRoute) y 
			on a.JourneyRoute = y.JourneyRoute 

			where NextDepartureDateRt is null and number_journeys_route < 6 and number_journeys_all >= 6) x 

			left join  

			(select JourneyRouteGrouped, JourneySeqRt,  days_between_journeys_max  as days_75 
			from #AvgLessFrequent 
			) y 
			on x.JourneyRouteGrouped = y.JourneyRouteGrouped AND x.JourneySeqRt = y.JourneySeqRt;  

            EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
                SET @ErrorNum = ERROR_NUMBER()
                SET @ErrorMsg = ERROR_MESSAGE()
                EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
        END CATCH ;
        RAISERROR('',10,1) WITH NOWAIT

		-----CREATE CUSTOMER LEVEL RAG - one for frequent journey and one for less frequent 
		-----for frequent journey select the most travelled route 
		-----for less frequent select the least severe status 
 
        BEGIN TRY
            SET @StepName = '#RetentionSD'
            EXEC dbo.uspSSISProcStepStart @ProcName, @StepName
			IF OBJECT_ID('Retention_RAG', 'U') IS NOT NULL    
				drop table CRM.Retention_RAG; 

			SELECT  ISNULL(b.CustomerID, d.CustomerID) as CustomerID, 
					FreqRoute_LastTravelled, FreqRoute_TimesTravelled, RAGStatus_FreqRoute, 
					LessFreqRoute_TimesTravelled,  LessFreqRoute_LastTravelled,  RAGStatus_LessFreqRoute 
			into	[CRM].[Retention_RAG] 
			FROM 
			(
			SELECT CustomerID, FreqRoute_LastTravelled, FreqRoute_TimesTravelled, RAGStatus as RAGStatus_FreqRoute 
			from  
				(select CustomerID, RAGStatus, JourneySeqRt as FreqRoute_TimesTravelled, DepartureDate as FreqRoute_LastTravelled, 
						ROW_NUMBER ()  OVER (PARTITION BY CustomerID ORDER BY JourneySeqRt desc) as route_freq_rank 
					from #RetentionMA
				) a 
			where route_freq_rank = 1) b 

			FULL OUTER JOIN 
			(SELECT CustomerID,  LessFreqRoute_TimesTravelled,  LessFreqRoute_LastTravelled, RAGStatus as RAGStatus_LessFreqRoute 

			FROM  
				(SELECT CustomerID, RAGStatus, JourneySeqRt as LessFreqRoute_TimesTravelled, DepartureDate as LessFreqRoute_LastTravelled, 
						ROW_NUMBER ()  OVER (PARTITION BY CustomerID ORDER BY RAGStatus asc, JourneySeqRt desc) as RAG_rank 
					from #RetentionSD 
				) c 
				where RAG_rank = 1 
			) d 
			ON b.CustomerId = d.CustomerID; 

            EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
                SET @ErrorNum = ERROR_NUMBER()
                SET @ErrorMsg = ERROR_MESSAGE()
                EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
        END CATCH ;
        RAISERROR('',10,1) WITH NOWAIT


        BEGIN TRY
            SET @StepName = 'Create IX_CustomerID'
            EXEC dbo.uspSSISProcStepStart @ProcName, @StepName

			CREATE INDEX IX_CustomerID ON crm.[Retention_RAG] (CustomerID); 

            EXEC dbo.uspSSISProcStepSuccess @ProcName, @StepName
        END TRY
        BEGIN CATCH
                SET @ErrorNum = ERROR_NUMBER()
                SET @ErrorMsg = ERROR_MESSAGE()
                EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
        END CATCH ;
        RAISERROR('',10,1) WITH NOWAIT

		--insert into [emm_sandbox].[Retention_RAG_History] 
		--select *, getdate() as DateCalculated 
		--from [emm_sandbox].[Retention_RAG];',  
		--        @database_name=N'emm_sandbox',  
		--        @flags=0 
		RETURN 0

        -- and ends here 
    END TRY 

    BEGIN CATCH 

        DECLARE @ErrorMessage VARCHAR(4000)= ERROR_MESSAGE()  , 
                @ErrorNumber INT = ERROR_NUMBER(), 
                @ErrorSeverity INT= ERROR_SEVERITY(), 
                @ErrorState INT = ERROR_STATE(), 
                @ErrorLine INT = ERROR_LINE(), 
                @ErrorProcedure VARCHAR(126)= ISNULL(ERROR_PROCEDURE(), 'N/A'); 

        --Rethrow the error 
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState) 

    END CATCH 

GO 

