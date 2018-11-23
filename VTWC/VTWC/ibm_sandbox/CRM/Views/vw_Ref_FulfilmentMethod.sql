CREATE VIEW [CRM].[vw_Ref_FulfilmentMethod]
	AS 
SELECT [FulfilmentMethodID] 

      ,a.[Name] 

      ,a.[Description] 

      ,a.[InformationSourceID] 

      ,b.[Name] AS [InformationSource] 

      ,a.[ExtReference] 

  FROM [$(CRMDB)].[Reference].[FulfilmentMethod] a 

  LEFT JOIN [$(CRMDB)].[Reference].[InformationSource] b ON b.InformationSourceID = a.InformationSourceID 
