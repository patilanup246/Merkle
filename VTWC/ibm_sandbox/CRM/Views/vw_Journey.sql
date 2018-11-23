CREATE VIEW [CRM].[vw_Journey]
	AS 
SELECT a.[JourneyID] 

      ,a.[SalesDetailID] 
	  ,a.[SalesTransactionID]
	  ,a.[CustomerID]

      ,a.[LocationIDOrigin] 

      ,b.[CRSCode]                AS [CRSCodeOrigin]              

      ,a.[LocationIDDestination] 

      ,c.[CRSCode]                AS [CRSCodeDestination]    

      ,a.[OutDepartureDateTime] 
      ,cast(a.[OutDepartureDateTime] as date) [OutDepartureDate]
	  ,convert(varchar(5), a.[OutDepartureDateTime], 108) [OutDepartureTime]

      ,a.[OutArrivalDateTime] 
      ,cast(a.[OutArrivalDateTime] as date) [OutArrivalDate]
	  ,convert(varchar(5), a.[OutArrivalDateTime], 108) [OutArrivalTime]

	  ,a.TotalAdults
	  ,a.TotalChildren

	  ,a.TotalReturningAdults
	  ,a.TotalReturningChildren

	  ,a.RetDepartureDateTime
      ,cast(a.RetDepartureDateTime as date) RetDepartureDate
	  ,convert(varchar(5), a.RetDepartureDateTime, 108) RetDepartureTime

	  ,a.RetArrivalDateTime
      ,cast(a.RetArrivalDateTime as date) RetArrivalDate
	  ,convert(varchar(5), a.RetArrivalDateTime, 108) RetArrivalTime

	  ,a.TotalCost
	  ,a.CostofTickets
	  ,a.SavingsMade

      ,a.[TOCIDPrimary] 

      ,a.[NumberLegs] 

      ,a.[IsOutboundInd] 

      ,a.[IsReturnInd] 

      ,a.[IsReturnInferredInd] 

	  ,a.[PromoCode]		AS [PinCode]
	  ,a.ProCode

	  ,a.JourneyReference
	  ,a.TCSBookingID

  FROM [$(CRMDB)].[Staging].[STG_Journey] a with (nolock) 
  LEFT JOIN [$(CRMDB)].[Reference].[Location] b with (nolock) ON b.[LocationID] = a.[LocationIDOrigin] 
  LEFT JOIN [$(CRMDB)].[Reference].[Location] c with (nolock) ON c.[LocationID] = a.[LocationIDDestination] 

  WHERE a.ArchivedInd = 0 