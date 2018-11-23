  CREATE VIEW [api_customer].[Customer] AS 
    SELECT c.CustomerID,
      CAST(NULL AS VARCHAR(50)) AS Nectar,
      CAST(NULL AS VARCHAR(50)) AS VFC
      FROM Staging.STG_Customer c
	 WHERE c.ArchivedInd = 0