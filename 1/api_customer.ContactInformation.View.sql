USE [CEM]
GO
/****** Object:  View [api_customer].[ContactInformation]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Customer Contact Information -----------------------------------------------

  CREATE VIEW [api_customer].[ContactInformation] AS
    SELECT        a.CustomerID, km.CBECustomerID AS CBECustomerID, d.Address AS ContactPhoneNumber, b.Address AS ContactEmail, b.EncrytpedAddress AS EncryptedEmail, COALESCE (st.Name, '-') AS Segment
	FROM          Staging.STG_Customer AS a LEFT OUTER JOIN
                  Staging.STG_KeyMapping AS km WITH (NOLOCK) ON a.CustomerID = km.CustomerID AND a.ArchivedInd = 0 LEFT OUTER JOIN
                  Staging.STG_ElectronicAddress AS b WITH (NOLOCK) ON a.CustomerID = b.CustomerID AND b.PrimaryInd = 1 AND b.AddressTypeID = 3 AND b.ArchivedInd = 0 LEFT OUTER JOIN
                  Staging.STG_ElectronicAddress AS d WITH (NOLOCK) ON a.CustomerID = d.CustomerID AND d.PrimaryInd = 1 AND d.AddressTypeID = 4 AND d.ArchivedInd = 0 LEFT OUTER JOIN
                  Production.Customer AS pc WITH (NOLOCK) ON pc.CustomerID = a.CustomerID AND pc.ArchivedInd = 0 LEFT OUTER JOIN
                  Reference.SegmentTier AS st WITH (NOLOCK) ON pc.SegmentTierID = st.SegmentTierID AND st.ArchivedInd = 0


GO
