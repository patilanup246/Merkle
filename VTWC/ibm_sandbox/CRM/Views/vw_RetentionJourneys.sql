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

     CAST(a.[OutArrivalDateTime] AS DATE) As DepartureDate, 

     pa.NearestStation, 

     f.[DateFirstTravelAny] 

     --,CASE WHEN h.Answer = 'Business' THEN 'Business' 
     --           WHEN (h.Answer like 'Leisure%'or h.Answer ='Visiting Friends/Relatives') THEN 'Leisure' 
     --           WHEN h.Answer LIKE 'OTHER:%' THEN 'Other' 
     --           ELSE 'None' 
     --END                                 AS Purpose 

	 ,z.Value [Purpose]

  FROM [$(CRMDB)].[Staging].[STG_Journey] a 
  INNER JOIN [$(CRMDB)].Staging.stg_journeyLeg l						 ON a.journeyid=l.JourneyID 
															  and l.tocid=31 /* VT */
															  and a.[ArchivedInd] = 0 
															  and a.[OutDepartureDateTime] > DATEADD(year,-1,GETDATE()) 
															  AND [IsOutboundInd] = 1 

  inner join [$(CRMDB)].[Reference].[Station] b with(nolock)			 on b.StationID = a.LocationIDOrigin 
  inner join [$(CRMDB)].[Reference].[Station] c with(nolock)           on c.StationID = a.LocationIDDestination 
  inner join [$(CRMDB)].[Staging].[STG_SalesDetail] d with(nolock)      on a.SalesDetailID = d.salesdetailid and istrainticketind = 1  
  inner join [$(CRMDB)].[Staging].[STG_SalesTransaction] e with(nolock) on d.salestransactionid = e.salestransactionid 
  inner join [$(CRMDB)].[Production].[Customer] f	with(nolock)		 on f.CustomerId = e.CustomerID 
   left join [$(CRMDB)].[Reference].[vwMasterPostCodeLookup]   pa        on f.[PostalDistrict]=pa.[PostCodeDistrict]  
	left  join [$(CRMDB)].[Staging].[STG_JourneyCVI]      x		with (nolock)	on x.JourneyId = a.JourneyID
	inner join [$(CRMDB)].[Reference].[CVIQuestion]	    y		with (nolock)	on x.CVIQuestionID=y.CVIQuestionID and y.Name='REASON_FOR_TRAVEL'
	inner join [$(CRMDB)].[Reference].[CVIStandardAnswer] z		with (nolock)	on x.[CVIAnswerID]=z.CVIAnswerID
GO