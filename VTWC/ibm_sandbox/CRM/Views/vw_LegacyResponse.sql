CREATE VIEW [CRM].[vw_LegacyResponse]
	AS 
select 1 res
/*
SELECT a.[LegacyCampaignResponseID] 

      ,a.[LegacyCampaignID] 

      ,a.[LegacyContactHistoryID] 

      ,a.[CustomerID] 

      ,a.[IndividualID] 

      ,a.[ResponseDate] 

      ,a.[ResponseCodeID] 

      ,a.[OrderID] 

      ,b.[Name]         AS [ResponseCode] 

      ,b.[ExtReference] AS [ResponseCodeExtReference] 

      ,c.[Name]         AS [ResponseCodeType] 

      ,c.[ExtReference] AS [ResponseCodeTypeExtReference] 

      ,c.[IsHardBounceInd] 

  FROM [$(CRMDB)].[Production].[LegacyCampaignResponse] a 

  INNER JOIN [$(CRMDB)].[Reference].[ResponseCode] b ON b.[ResponseCodeID] = a.[ResponseCodeID] 

  LEFT JOIN [$(CRMDB)].[Reference].[ResponseCodeType] c ON c.[ResponseCodeTypeID] = b.[ResponseCodeTypeID] */