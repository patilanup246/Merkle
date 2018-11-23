CREATE VIEW [CRM].[vw_JourneyLeg]
AS
SELECT a.[JourneyLegID] 

      ,a.[JourneyID] 

      ,a.[LegNumber] 

      ,a.[SeatReservation] 

      ,a.[RSID] 

	  ,a.[DirectionCd]            AS [Direction] 

      ,a.[TicketClassID] 

      ,d.[Name]                   AS [TicketClass] 

      ,a.[LocationIDOrigin] 

      ,b.[CRSCode]                AS [CRSCodeOrigin] 

      ,a.[LocationIDDestination] 

      ,c.[CRSCode]                AS [CRSCodeDestination] 

      ,a.[TOCID] 

      ,e.[Name]                   AS [TOC] 

      ,a.InformationSourceID 

      ,a.DayPlusOne 

      ,a.CateringCode 

      ,a.JourneyTrainID 

      ,a.ExtReference 

      ,a.RecommendedXferTime 

      ,a.InferredArrivalInd 

      ,a.InferredDepartureInd 

      ,a.DepartureDateTime 

      ,a.ArrivalDateTime 

      ,a.WiFiCode 

	  ,a.[QuietZone_YN]
	  ,a.[TrainUID]
	  ,a.[JLType]

  FROM [$(CRMDB)].[Staging].[STG_JourneyLeg] a with (nolock) 

  LEFT JOIN [$(CRMDB)].[Reference].[Location] b with (nolock) ON b.[LocationID] = a.[LocationIDOrigin] 

  LEFT JOIN [$(CRMDB)].[Reference].[Location] c with (nolock) ON c.[LocationID] = a.[LocationIDDestination] 

  LEFT JOIN [$(CRMDB)].[Reference].[TicketClass] d with (nolock) ON d.[TicketClassID] = a.[TicketClassID] 

  LEFT JOIN [$(CRMDB)].[Reference].[TOC] e with (nolock) ON e.[TOCID] = a.[TOCID] 

  WHERE a.ArchivedInd = 0 