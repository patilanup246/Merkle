CREATE VIEW [Production].[CustomerJourney] AS
    SELECT a.CustomerID
	      ,a.SalesTransactionID
          ,a.SalesTransactionDate
	      ,a.NumberofAdults
	      ,a.NumberofChildren
	      ,a.SalesAmountRail                    AS SalesAmount_Rail
	      ,a.SalesAmountNotRail                 AS SalesAmount_NotRail
	      ,[Staging].[Text_ProperCase] (f.Name) AS Origin_Station
	      --,f.NLCCode                          AS Origin_NLCCode
	      ,f.CRSCode                            AS Origin_CRSCode
	      ,[Staging].[Text_ProperCase] (g.Name) AS Destination_Station
          --,g.NLCCode                          AS Destination_NLCCode
	      ,g.CRSCode                            AS Destination_CRSCode
	      ,d.Name                               AS Product
	      ,e.Name                               AS TicketClass
	      ,d.TicketTypeCode                     AS TicketTypeCode
	      ,CASE c.IsOutboundInd WHEN 1 THEN 'Outbound Journey'
	                                   ELSE 'Return Journey'
		  END                                   AS JourneyType
FROM [Staging].[STG_SalesTransaction] a
INNER JOIN [Staging].[STG_SalesDetail] b ON a.SalesTransactionID = b.SalesTransactionID
LEFT  JOIN [Staging].[STG_Journey] c ON c.SalesDetailID = b.SalesDetailID
LEFT  JOIN [Reference].[Product] d ON d.ProductID = b.ProductID
LEFT  JOIN [Reference].[TicketClass] e ON e.TicketClassID = d.TicketClassID
LEFT  JOIN [Reference].[Location] f ON f.LocationID = c.LocationIDOrigin
LEFT  JOIN [Reference].[Location] g ON g.LocationID = c.LocationIDDestination
WHERE LocationIDOrigin IS NOT NULL
AND   LocationIDDestination IS NOT NULL