CREATE VIEW [CRM].[vw_Retention_RAG]
	AS 
SELECT [CustomerID] 
      ,[FreqRoute_LastTravelled] 
      ,[FreqRoute_TimesTravelled] 
      ,[RAGStatus_FreqRoute] 
      ,[LessFreqRoute_TimesTravelled] 
      ,[LessFreqRoute_LastTravelled] 
      ,[RAGStatus_LessFreqRoute] 

  FROM CRM.Retention_RAG with(nolock)
