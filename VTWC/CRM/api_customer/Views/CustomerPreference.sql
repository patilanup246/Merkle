-- List of available Preferences on CEM ------------------------------------------

CREATE VIEW [api_customer].[CustomerPreference] AS
    
SELECT        c.CustomerID, km.TCSCustomerID AS TCSCustomerID, ea.[HashedAddress] AS EncryptedEmail, p.PreferenceID, p.PreferenceName, dt.Name AS DataType
FROM          Staging.STG_Customer AS c WITH (NOLOCK) CROSS JOIN
              Staging.STG_Preference AS p WITH (NOLOCK) INNER JOIN
              Reference.DataType AS dt WITH (NOLOCK) ON dt.DataTypeID = p.PreferenceDataTypeID INNER JOIN
              Staging.STG_ElectronicAddress AS ea WITH (NOLOCK) ON c.CustomerID = ea.CustomerID AND ea.PrimaryInd = 1 AND ea.AddressTypeID = 3 LEFT OUTER JOIN
              Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.CustomerID = km.CustomerID
WHERE         (ea.ArchivedInd = 0)
  AND 		  (c.ArchivedInd = 0)
  AND 		  (p.ArchivedInd = 0)