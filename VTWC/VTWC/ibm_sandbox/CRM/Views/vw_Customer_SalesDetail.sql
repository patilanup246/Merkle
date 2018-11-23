CREATE VIEW [CRM].[vw_Customer_SalesDetail]
	AS
SELECT a.[SalesDetailID] 

      ,b.[CustomerID] 

      ,a.[SalesTransactionID] 

      ,b.[SalesTransactionDate] 

      ,a.[ProductID] 

      ,c.[Name]                 AS [ProductName] 

      ,c.[TicketTypeCode]       AS [ProductTypeCode] 

      ,a.[Quantity] 

      ,a.[UnitPrice] 

      ,a.[SalesAmount] 

      ,a.[IsTrainTicketInd] 

      ,a.[RailcardTypeID] 

      ,d.[Name]                 AS [RailCardType] 

      ,a.[ExtReference] 

      ,a.[FulfilmentMethodID] 

      ,a.[TransactionStatusID] 

      ,a.[OutTravelDate] 

      ,a.[ReturnTravelDate] 

      ,a.[IsReturnInferredInd] 

      ,c.[IsSeasonTicketInd] 

      ,a.[ValidityStartDate] 

      ,a.[ValidityEndDate] 

  FROM [$(CRMDB)].[Staging].[STG_SalesDetail]            a  with(nolock) 

  INNER JOIN [$(CRMDB)].[Staging].[STG_SalesTransaction] b  with(nolock) ON a.[SalesTransactionID] = b.[SalesTransactionID] 

  LEFT JOIN [$(CRMDB)].[Reference].[Product]             c  with(nolock) ON c.[ProductID] = a.[ProductID] 

  LEFT JOIN [$(CRMDB)].[Reference].[RailcardType]        d  with(nolock) ON d.[RailcardTypeID] = a.[RailcardTypeID] 

  WHERE a.ArchivedInd = 0 