CREATE VIEW [CRM].[vw_CustomerJourney]
	AS 
    SELECT distinct a.CustomerID                                                 AS CustomerID, 

           a.SalesTransactionID                                                  AS SalesTransactionID,  

           a.salestransactiondate                                                AS SalesTransactionDate, 

           convert(date, c.OutDepartureDateTime)									 AS TravelDate, 
           --convert(date, CEM.Staging.GetUKTime(c.DepartureDateTime))             AS TravelDate, 

           SUBSTRING(CAST(convert(time, c.OutDepartureDateTime) AS nvarchar(8)),1,5) AS TravelTime, 
           --SUBSTRING(CAST(convert(time, CEM.Staging.GetUKTime(c.DepartureDateTime)) AS nvarchar(8)),1,5) AS TravelTime, 

           L.DirectionCd                                                         AS DirectionInd, 

           a.NumberofAdults                                                      AS NumberofAdults, 

           a.NumberofChildren                                                    AS NumberofChildren, 

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

            -- WHEN c.IsReturnInferredInd = 1 THEN 

             --WHEN ROW_NUMBER() OVER(PARTITION BY a.CustomerID ORDER BY c.DepartureDateTime) = 1 THEN 

             WHEN c.IsOutboundInd = 1 THEN 

                 'Outbound Journey' 

             ELSE  

                 'Return Journey' 

           END                                                                   AS JourneyType, 

           l.SeatReservation                                                     AS Seat_Reservation, 

           CASE WHEN fm.Name = 'TOD' THEN a.BookingReference ELSE null        END   AS Ticket_Collection_Code, 

           a.[FulfilmentMethodID]                                                as [FulfilmentMethodID] 

           ,toc.[Name]                                                           as TOC 

           ,l.rsid 

           ,a.BookingReference                                                   as BookingReference 

      FROM [$(CRMDB)].Staging.STG_Journey c INNER JOIN [$(CRMDB)].Staging.stg_journeyLeg l          ON c.journeyid=l.JourneyID and l.tocid=35 -- l.tocid=9 => Virgin Trains East Coast 

                                     INNER JOIN [$(CRMDB)].Staging.STG_SalesDetail b         ON c.SalesDetailID = b.SalesDetailID AND IsTrainTicketInd = 1 

                                     INNER JOIN [$(CRMDB)].Staging.STG_SalesTransaction a    ON a.SalesTransactionID = b.SalesTransactionID  

                                     LEFT  JOIN [$(CRMDB)].Reference.Product d               ON d.ProductID = b.ProductID  

                                     LEFT  JOIN [$(CRMDB)].Reference.TicketClass e           ON e.TicketClassID = d.TicketClassID  

                                     INNER JOIN [$(CRMDB)].Reference.Location f              ON f.LocationID = l.LocationIDOrigin  

                                     INNER JOIN [$(CRMDB)].Reference.Location g              ON g.LocationID = l.LocationIDDestination  

--                                     LEFT  JOIN Staging.STG_CVISalesTransaction q ON a.SalesTransactionID = q.[SalesTransactionID] and q.CVIQuestionID in (11,12)  

                                     LEFT  JOIN [$(CRMDB)].Reference.FulfilmentMethod fm     ON fm.FulfilmentMethodID = a.FulfilmentMethodID 

                                     LEFT  JOIN [$(CRMDB)].Reference.TOC toc                 ON l.tocid=toc.tocid 
