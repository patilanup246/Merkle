CREATE VIEW [CRM].[vw_LegacyContactHistory]
AS
select 1 res
/*
  SELECT a.[CustomerID] 

          ,a.[IndividualID] 

          ,a.[LegacyContactHistoryID] 

          ,a.[LegacyCampaignID] 

          ,c.[LegacyProgramID] 

          ,c.[Name] AS [LegacyProgram] 

          ,b.[Name] AS [LegacyCampaign] 

          ,a.[EmailAddress] 

          ,a.[ContactDate] 

          ,a.[Segment] 

          ,a.[SubSegment] 

          ,a.[ControlCell] 

          ,a.[VoucherCode] 

          ,a.[VoucherValue] 

          ,a.[TierNumber] 

          ,a.[TierName] 

          ,a.[HomeStation] 

          ,a.[ECHomeStation] 

    FROM [$(CRMDB)].[Production].[LegacyContactHistory] a 

    INNER JOIN [$(CRMDB)].[Production].[LegacyCampaign] b ON b.LegacyCampaignID = a.LegacyCampaignID 

    LEFT JOIN  [$(CRMDB)].[Production].[LegacyProgram] c ON c.LegacyProgramID = b.LegacyProgramID 
*/