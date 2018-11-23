CREATE VIEW [CRM].[vw_Journey]
	AS 
SELECT a.[JourneyID] 

      ,a.[SalesDetailID] 

      ,a.[LocationIDOrigin] 

      ,b.[CRSCode]                AS [CRSCodeOrigin]              

      ,a.[LocationIDDestination] 

      ,c.[CRSCode]                AS [CRSCodeDestination]    

      ,a.[ECJourneyScore] 

      ,a.[OutDepartureDateTime] 

      ,a.[TOCIDPrimary] 

      ,a.[NumberLegs] 

      ,a.[IsOutboundInd] 

      ,a.[IsReturnInd] 

      ,a.[IsReturnInferredInd] 

	  ,a.[PromoCode]

	  ,z.[Value]				  AS [reasonForTravel]

  FROM [$(CRMDB)].[Staging].[STG_Journey] a with (nolock) 

  LEFT JOIN [$(CRMDB)].[Reference].[Location] b with (nolock) ON b.[LocationID] = a.[LocationIDOrigin] 
  LEFT JOIN [$(CRMDB)].[Reference].[Location] c with (nolock) ON c.[LocationID] = a.[LocationIDDestination] 

  inner join [$(CRMDB)].[Staging].[STG_JourneyCVI]      x		with (nolock)	on x.JourneyId = a.JourneyID
  inner join [$(CRMDB)].[Reference].[CVIQuestion]	      y		with (nolock)	on x.CVIQuestionID=y.CVIQuestionID and y.Name='REASON_FOR_TRAVEL'
  inner join [$(CRMDB)].[Reference].[CVIStandardAnswer] z		with (nolock)	on x.[CVIAnswerID]=z.CVIAnswerID


  WHERE a.ArchivedInd = 0 