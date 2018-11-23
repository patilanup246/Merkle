CREATE  VIEW [Production].[LegacyResponse] AS

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
  FROM [Production].[LegacyCampaignResponse] a
  INNER JOIN [Reference].[ResponseCode] b ON b.[ResponseCodeID] = a.[ResponseCodeID]
  LEFT JOIN [Reference].[ResponseCodeType] c ON c.[ResponseCodeTypeID] = b.[ResponseCodeTypeID]