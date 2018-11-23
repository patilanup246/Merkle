-- Customer Contact Information -----------------------------------------------

  CREATE VIEW [api_customer].[ContactInformation] AS
    SELECT        a.CustomerID, km.TCSCustomerID AS TCSCustomerID, d.Address AS ContactPhoneNumber, b.Address AS ContactEmail, b.[HashedAddress] AS EncryptedEmail, COALESCE (st.Name, '-') AS Segment
	FROM          Staging.STG_Customer AS a LEFT OUTER JOIN
                  Staging.STG_KeyMapping AS km WITH (NOLOCK) ON a.CustomerID = km.CustomerID AND a.ArchivedInd = 0 LEFT OUTER JOIN
                  Staging.STG_ElectronicAddress AS b WITH (NOLOCK) ON a.CustomerID = b.CustomerID AND b.PrimaryInd = 1 AND b.AddressTypeID = 3 AND b.ArchivedInd = 0 LEFT OUTER JOIN
                  Staging.STG_ElectronicAddress AS d WITH (NOLOCK) ON a.CustomerID = d.CustomerID AND d.PrimaryInd = 1 AND d.AddressTypeID = 4 AND d.ArchivedInd = 0 LEFT OUTER JOIN
                  Production.Customer AS pc WITH (NOLOCK) ON pc.CustomerID = a.CustomerID AND pc.ArchivedInd = 0 LEFT OUTER JOIN
                  Reference.SegmentTier AS st WITH (NOLOCK) ON pc.SegmentTierID = st.SegmentTierID AND st.ArchivedInd = 0