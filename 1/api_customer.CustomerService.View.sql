USE [CEM]
GO
/****** Object:  View [api_customer].[CustomerService]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [api_customer].[CustomerService] AS
  SELECT cs.CustomerID,
		 km.CBECustomerID AS CBECustomerID,	
         ea.EncrytpedAddress as EncryptedEmail,
         cs.CaseReferenceNumber,
         cs.DateLogged,
         cs.DateResolved,
         toco.Name AS 'Origin',
         tocs.Name AS 'Status',
         cs.Category
    FROM Staging.STG_CustomerService cs WITH (NOLOCK) INNER JOIN Staging.STG_ElectronicAddress ea WITH (NOLOCK) ON cs.CustomerID = ea.CustomerID AND ea.AddressTypeID = 3 and ea.PrimaryInd = 1
										LEFT JOIN Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.CustomerID = km.CustomerID
										LEFT JOIN Reference.TOCRM_Origin AS toco WITH (NOLOCK) ON cs.Origin = toco.Value
										LEFT JOIN Reference.TOCRM_Category AS tocc WITH (NOLOCK) ON cs.Category = tocc.Name
										LEFT JOIN Reference.TOCRM_CaseState AS tocs WITH (NOLOCK) ON cs.Status = tocs.Value
   WHERE cs.ArchivedInd = 0
     AND ea.ArchivedInd = 0
	 AND tocc.ArchivedInd = 0
	 AND km.IsVerifiedInd = 1
	 AND km.VerifiedDate <= cs.DateLogged


GO
