USE [CEM]
GO
/****** Object:  View [api_customer].[CustomerPreferenceValues]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- List of available Preferences on CEM ------------------------------------------

CREATE VIEW [api_customer].[CustomerPreferenceValues] AS
    (
	SELECT      c.CustomerID, km.CBECustomerID AS CBECustomerID, ea.EncrytpedAddress AS EncryptedEmail, po.PreferenceID, po.OptionID, po.OptionName, COALESCE (cp.PreferenceValue, po.DefaultValue) 
                AS PreferenceValue
	FROM        Staging.STG_Customer AS c WITH (NOLOCK) CROSS JOIN
                Staging.STG_PreferenceOptions AS po WITH (NOLOCK) INNER JOIN
                Staging.STG_Preference AS p WITH (NOLOCK) ON po.PreferenceID = p.PreferenceID LEFT OUTER JOIN
                Staging.STG_CustomerPreference AS cp WITH (NOLOCK) ON po.OptionID = cp.OptionID AND cp.CustomerID = c.CustomerID INNER JOIN
                Staging.STG_ElectronicAddress AS ea WITH (NOLOCK) ON c.CustomerID = ea.CustomerID AND ea.AddressTypeID = 3 AND ea.PrimaryInd = 1 LEFT OUTER JOIN
                Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.CustomerID = km.CustomerID
WHERE        	(ea.ArchivedInd = 0)
  AND 			(c.ArchivedInd = 0)
  AND 			(p.ArchivedInd = 0)
	)	

GO
