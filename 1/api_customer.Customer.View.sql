USE [CEM]
GO
/****** Object:  View [api_customer].[Customer]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
  CREATE VIEW [api_customer].[Customer] AS 
    SELECT c.CustomerID,
      CAST(NULL AS VARCHAR(50)) AS Nectar,
      CAST(NULL AS VARCHAR(50)) AS VFC
      FROM Staging.STG_Customer c
	 WHERE c.ArchivedInd = 0

GO
