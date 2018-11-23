------------------------------------------------------------------------------		
-- Customer Search by criteria -----------------------------------------------
-- Is a merged view of the following:
-- 01_Customer
-- 02_PersonalDetails
-- 03_ContactInformation
-- 04_Address
------------------------------------------------------------------------------

  CREATE VIEW [api_customer].[Search] AS
  SELECT        c.CustomerID, km.TCSCustomerID AS TCSCustomerID, CAST(NULL AS VARCHAR(50)) AS Nectar, CAST(NULL AS VARCHAR(50)) AS VFC, c.Salutation, c.FirstName AS Forename, c.LastName AS Surname, CAST(NULL 
                AS date) AS DOB, a.AddressLine1, a.AddressLine2, a.AddressLine3, a.AddressLine4, a.AddressLine5, a.TownCity AS City, a.County, a.PostalCode AS PostCode, ctr.Name AS Country, 
                d.Address AS ContactPhoneNumber, COALESCE (b.Address, '-') AS ContactEmail, b.[HashedAddress] AS EncryptedEmail, COALESCE (st.Name, '-') AS Segment
  FROM          Staging.STG_Customer AS c LEFT OUTER JOIN
                Staging.STG_KeyMapping AS km ON c.CustomerID = km.CustomerID LEFT OUTER JOIN
                Staging.STG_ElectronicAddress AS b ON c.CustomerID = b.CustomerID AND b.PrimaryInd = 1 AND b.AddressTypeID = 3 LEFT OUTER JOIN
                Staging.STG_ElectronicAddress AS d ON c.CustomerID = d.CustomerID AND d.PrimaryInd = 1 AND d.AddressTypeID = 4 LEFT OUTER JOIN
                Staging.STG_Address AS a ON c.CustomerID = a.CustomerID AND a.PrimaryInd = 1 LEFT OUTER JOIN
                Reference.Country AS ctr ON a.CountryID = ctr.CountryID LEFT OUTER JOIN
                Production.Customer AS pc ON pc.CustomerID = c.CustomerID LEFT OUTER JOIN
                Reference.SegmentTier AS st ON pc.SegmentTierID = st.SegmentTierID
  WHERE         (c.ArchivedInd = 0)
    AND 		(b.ArchivedInd = 0 OR b.ArchivedInd IS NULL)
    AND 		(d.ArchivedInd = 0 OR d.ArchivedInd IS NULL)
    AND 		(a.ArchivedInd = 0 OR a.ArchivedInd IS NULL)
    AND 		(ctr.ArchivedInd = 0 OR ctr.ArchivedInd IS NULL)
    AND 		(pc.ArchivedInd = 0 OR pc.ArchivedInd IS NULL)