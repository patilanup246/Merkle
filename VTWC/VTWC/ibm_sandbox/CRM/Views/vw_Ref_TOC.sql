CREATE VIEW [CRM].[vw_Ref_TOC] AS 

SELECT [TOCID] 
      ,[Name] 
      ,[Description] 
      ,[ShortCode] 
      ,[URLInformation] 

FROM   [$(CRMDB)].[Reference].[TOC] 
