-- List of available Preferences on CEM ------------------------------------------

CREATE VIEW [api_customer].[CustomerPreferenceValues] AS
select 1 as One
--    (
--	SELECT      c.CustomerID, km.TCSCustomerID AS TCSCustomerID, ea.EncrytpedAddress AS EncryptedEmail, po.PreferenceID, po.OptionID, po.OptionName, COALESCE (cp.PreferenceValue, po.DefaultValue) 
--                AS PreferenceValue
--	FROM        Staging.STG_Customer AS c WITH (NOLOCK) CROSS JOIN
--                Staging.STG_PreferenceOptions AS po WITH (NOLOCK) INNER JOIN
--                Staging.STG_Preference AS p WITH (NOLOCK) ON po.PreferenceID = p.PreferenceID LEFT OUTER JOIN
--                Staging.STG_CustomerPreference AS cp WITH (NOLOCK) ON po.OptionID = cp.OptionID AND cp.CustomerID = c.CustomerID INNER JOIN
--                Staging.STG_ElectronicAddress AS ea WITH (NOLOCK) ON c.CustomerID = ea.CustomerID AND ea.AddressTypeID = 3 AND ea.PrimaryInd = 1 LEFT OUTER JOIN
--                Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.CustomerID = km.CustomerID
--WHERE        	(ea.ArchivedInd = 0)
--  AND 			(c.ArchivedInd = 0)
--  AND 			(p.ArchivedInd = 0)
--	)