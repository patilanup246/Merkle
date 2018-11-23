CREATE VIEW [CRM].[vw_CustomerJourney]
	AS 
    SELECT distinct a.CustomerID                                                 AS CustomerID, 

           a.SalesTransactionID                                                  AS SalesTransactionID,  

           a.salestransactiondate                                                AS SalesTransactionDate, 

           convert(date, c.OutDepartureDateTime)								 AS TravelDate, 
		   convert(varchar(5), c.[OutDepartureDateTime], 108)					 AS [TravelTime],

           case when f.Latitude<=g.Latitude then 'South' else 'North' end [DirectionInd],

           c.TotalAdults                                                      AS NumberofAdults, 

           c.TotalChildren                                                    AS NumberofChildren

	  ,c.TotalReturningAdults
	  ,c.TotalReturningChildren

	  ,c.RetDepartureDateTime
      ,cast(c.RetDepartureDateTime as date) RetDepartureDate
	  ,convert(varchar(5), c.RetDepartureDateTime, 108) RetDepartureTime

	  ,c.RetArrivalDateTime
      ,cast(c.RetArrivalDateTime as date) RetArrivalDate
	  ,convert(varchar(5), c.RetArrivalDateTime, 108) RetArrivalTime,


           CASE WHEN f.Name ='London Terminals' 
                THEN 'EUS' ELSE f.CRSCode 
           END                                                                   AS Origin_CRSCode, 

           f.Name                                                                AS Origin_Station, 

           CASE WHEN g.Name ='London Terminals' 
                THEN 'EUS' ELSE g.CRSCode 
           END                                                                   AS Destination_CRSCode, 

           g.Name                                                                 AS Destination_Station, 

           d.Name                                                                AS Product, 

           e.Name                                                                AS TicketClass, 

           d.TicketTypeCode                                                      AS TicketTypeCode, 

           CASE  
             WHEN l.JLType='O' THEN 
                 'Outbound Journey' 
             WHEN l.JLType='R' THEN 
                 'Return Journey' 
             ELSE  
                 'Return Journey' 
           END                                                                   AS JourneyType

		   ,isnull(replace((select STUFF((select ','+ltrim(rtrim(SeatReservation)) as 'data()'
					from [$(CRMDB)].Staging.STG_Leg
					where JourneyLegId=l.JourneyLegID and len(ltrim(rtrim(SeatReservation)))>1
					order by SeatReservation
					for xml path('')),1,1,'')),' ',''), case when len(ltrim(rtrim(l.SeatReservation)))>1 then l.SeatReservation else null end)				as Seat_Reservation

           ,case when c.JourneyReference like '%[A-Z]%' then c.[JourneyReference] else NULL end AS Ticket_Collection_Code 
           ,a.[FulfilmentMethodID]                                                as [FulfilmentMethodID] 
		   ,fm.Name as [FulfillmentMethod]

           ,toc.[Name]                                                           as TOC 

           ,l.rsid 

           ,a.ExtReference                                                   as BookingReference 

	   	  ,z.[Value]			AS [reasonForTravel]
		  ,b.businessorleisure  AS [BusinessOrLeisure]

      FROM [$(CRMDB)].Staging.STG_Journey c INNER JOIN [$(CRMDB)].Staging.stg_journeyLeg l          ON c.journeyid=l.JourneyID and l.tocid=31 -- l.tocid=9 => Virgin Trains East Coast 

                                     INNER JOIN [$(CRMDB)].Staging.STG_SalesDetail b         ON c.SalesDetailID = b.SalesDetailID AND IsTrainTicketInd = 1 

                                     INNER JOIN [$(CRMDB)].Staging.STG_SalesTransaction a    ON a.SalesTransactionID = b.SalesTransactionID  

                                     LEFT  JOIN [$(CRMDB)].Reference.Product d               ON d.ProductID = b.ProductID  

                                     LEFT  JOIN [$(CRMDB)].Reference.TicketClass e           ON e.TicketClassID = d.TicketClassID  

                                     LEFT JOIN [$(CRMDB)].Reference.Location f              ON f.LocationID = l.LocationIDOrigin  
--									 LEFT JOIN [$(CRMDB)].Reference.[Location_NLCCode_VW] h  on f.CRSCode = h.[CRSCode]

                                     LEFT JOIN [$(CRMDB)].Reference.Location g              ON g.LocationID = l.LocationIDDestination  
--									 LEFT JOIN [$(CRMDB)].Reference.Location_NLCCode_VW j  on g.CRSCode = j.[CRSCode] 

                                     LEFT  JOIN [$(CRMDB)].Reference.FulfilmentMethod fm     ON fm.FulfilmentMethodID = a.FulfilmentMethodID 

                                     LEFT  JOIN [$(CRMDB)].Reference.TOC toc                 ON l.tocid=toc.tocid 

									left  join [$(CRMDB)].[Staging].[STG_JourneyCVI]      x		with (nolock)	on x.JourneyId = c.JourneyID
									inner join [$(CRMDB)].[Reference].[CVIQuestion]	    y		with (nolock)	on x.CVIQuestionID=y.CVIQuestionID and y.Name='REASON_FOR_TRAVEL'
									inner join [$(CRMDB)].[Reference].[CVIStandardAnswer] z		with (nolock)	on x.[CVIAnswerID]=z.CVIAnswerID