CREATE VIEW [CRM].[vw_Customer_SalesTransaction]
	AS select 1 res
/*
SELECT a.[SalesTransactionID] 

      ,a.[Name] 

      ,a.[SourceCreatedDate] 

      ,a.[SourceModifiedDate] 

      ,a.[SalesTransactionDate] 

     ,a.[LoyaltyReference] 

      ,a.[RetailChannelID] 

      ,a.[LocationID] 

      ,a.[CustomerID] 

      ,a.[ExtReference] 

      ,a.[InformationSourceID] 

      ,a.[BookingReference] 

      ,a.[FulfilmentMethodID] 

      ,a.[NumberofAdults] 

      ,a.[NumberofChildren] 

      ,a.[FulfilmentDate] 

      ,a.[SuperSalesInd]  

      --,coalesce(c.[SalesAmountTotal],a.[SalesAmountTotal]) as [SalesAmountTotal] 
      ,a.[SalesAmountTotal]

      --,coalesce(c.[SalesAmountNotRail], a.[SalesAmountNotRail]) as [SalesAmountNotRail] 
      ,a.[SalesAmountNotRail]

      --,coalesce(c.[SalesAmountRail],a.[SalesAmountRail]) as [SalesAmountRail] 
      ,a.[SalesAmountRail]

--      ,b.[JourneyPurpose] 

      ,a.[BookingSourceCd]  

      ,a.SalesTransactionNumber 

FROM [$(CRMDB)].[Staging].[STG_SalesTransaction]                 a with (nolock)  

  --LEFT JOIN [CEM].vw_JourneyPurpose                           b ON a.SalesTransactionID = b.SalesTransactionID 
    --LEFT JOIN [emm_sandbox].[dbo].[tbl_TransactionSalesAmount]  c ON a.SalesTransactionID = c. SalesTransactionID 

  WHERE a.ArchivedInd = 0 
*/