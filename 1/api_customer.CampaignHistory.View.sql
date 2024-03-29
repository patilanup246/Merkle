USE [CEM]
GO
/****** Object:  View [api_customer].[CampaignHistory]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [api_customer].[CampaignHistory] AS
    SELECT ch.CustomerID,
		   km.CustomerID	   AS CBECustomerID,	
           ch.LegacyCampaignID AS CampaignID,
           ch.ContactDate      AS ContactDate,
           c.Name              AS CampaignName,
           'Email'             AS Channel,
           c.Description       AS Proposition,
           ea.EncrytpedAddress AS EncryptedEmail
    FROM Production.LegacyContactHistory ch INNER JOIN Production.LegacyCampaign c WITH (NOLOCK) ON CH.LegacyCampaignID = C.LegacyCampaignID 
											INNER JOIN Staging.STG_ElectronicAddress ea WITH (NOLOCK) ON ea.CustomerID = ch.CustomerID and ea.PrimaryInd = 1 and ea.AddressTypeID = 3
											LEFT JOIN Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.CustomerID = km.CustomerID
	WHERE ea.ArchivedInd = 0
		

GO
