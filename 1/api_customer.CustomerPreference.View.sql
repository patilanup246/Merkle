USE [CEM]
GO
/****** Object:  View [api_customer].[CustomerPreference]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- List of available Preferences on CEM ------------------------------------------

CREATE VIEW [api_customer].[CustomerPreference] AS
    
SELECT        c.CustomerID, km.CBECustomerID AS CBECustomerID, ea.EncrytpedAddress AS EncryptedEmail, p.PreferenceID, p.PreferenceName, dt.Name AS DataType
FROM          Staging.STG_Customer AS c WITH (NOLOCK) CROSS JOIN
              Staging.STG_Preference AS p WITH (NOLOCK) INNER JOIN
              Reference.DataType AS dt WITH (NOLOCK) ON dt.DataTypeID = p.PreferenceDataTypeID INNER JOIN
              Staging.STG_ElectronicAddress AS ea WITH (NOLOCK) ON c.CustomerID = ea.CustomerID AND ea.PrimaryInd = 1 AND ea.AddressTypeID = 3 LEFT OUTER JOIN
              Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.CustomerID = km.CustomerID
WHERE         (ea.ArchivedInd = 0)
  AND 		  (c.ArchivedInd = 0)
  AND 		  (p.ArchivedInd = 0)
		

GO
