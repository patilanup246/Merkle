CREATE VIEW [CRM].[vw_Customer_SalesDetail]
	AS
SELECT a.[SalesDetailID] 

      ,a.[CustomerID] 

      ,a.[SalesTransactionID] 

      ,a.[ProductID] 

      ,a.[Quantity] 

      ,a.[UnitPrice] 

      ,a.[SalesAmount] 

      ,a.[IsTrainTicketInd] 

      ,a.[RailcardTypeID] 

      ,a.[ExtReference] 

      ,a.[FulfilmentMethodID] 

      ,a.[TransactionStatusID] 

      ,a.[OutTravelDate] 

      ,a.[ReturnTravelDate] 

      ,a.[IsReturnInferredInd] 

      ,a.[ValidityStartDate] 

      ,a.[ValidityEndDate] 

	  ,a.[refundind]
      ,case when isdate(a.[refunddate])=1 and a.[refunddate]>convert(date,'1899-12-30') then a.[refunddate] else null end [refunddate]


  FROM [$(CRMDB)].[Staging].[STG_SalesDetail]            a  with(nolock) 

  WHERE a.ArchivedInd = 0 