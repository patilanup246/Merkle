CREATE VIEW [CRM].[vw_RetentionJourneys]
AS
SELECT 
--top 10
/*distinct*/

     e.CustomerID, 
     e.SalesTransactionID, 
     CAST(e.SalesTransactionDate AS DATE) as SalesTransactionDate, 

     (CASE WHEN b.Name like 'LONDON%' OR b.Name like '%LONDN' THEN 'LONDON' ELSE b.Name END) 
     + ' TO ' + (CASE WHEN c.Name LIKE 'LONDON%' OR c.Name like '%LONDN' THEN 'LONDON' ELSE c.Name END) as JourneyRoute, 

     CAST(a.[DepartureDateTime] AS DATE) As DepartureDate, 

     pa.NearestStation, 

     f.[DateFirstTravelAny] 

     --,CASE WHEN h.Answer = 'Business' THEN 'Business' 
     --           WHEN (h.Answer like 'Leisure%'or h.Answer ='Visiting Friends/Relatives') THEN 'Leisure' 
     --           WHEN h.Answer LIKE 'OTHER:%' THEN 'Other' 
     --           ELSE 'None' 
     --END                                 AS Purpose 

  FROM [$(CRM)].[Staging].[STG_Journey] a 
  INNER JOIN [$(CRM)].Staging.stg_journeyLeg l						 ON a.journeyid=l.JourneyID 
															  and l.tocid=31 /* VT */
															  and a.[ArchivedInd] = 0 
															  and a.[DepartureDateTime] > DATEADD(year,-1,GETDATE()) 
															  AND [IsOutboundInd] = 1 

  inner join [$(CRM)].[Reference].[Location] b with(nolock)			 on b.LocationId = a.LocationIDOrigin 
  inner join [$(CRM)].[Reference].[Location] c with(nolock)           on c.LocationId = a.LocationIDDestination 
  inner join [$(CRM)].[Staging].[STG_SalesDetail] d with(nolock)      on a.SalesDetailID = d.salesdetailid and istrainticketind = 1  
  inner join [$(CRM)].[Staging].[STG_SalesTransaction] e with(nolock) on d.salestransactionid = e.salestransactionid 
  inner join [$(CRM)].[Production].[Customer] f	with(nolock)		 on f.CustomerId = e.CustomerID 
   left join [$(CRM)].[Reference].[vwMasterPostCodeLookup]   pa        on f.[PostalDistrict]=pa.[PostCodeDistrict]  
--  LEFT JOIN Staging.STG_CVISalesTransaction    h  with(nolock)       ON e.SalesTransactionID = h.SalesTransactionID 
