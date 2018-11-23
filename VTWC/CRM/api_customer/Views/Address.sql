
  CREATE VIEW [api_customer].[Address] WITH SCHEMABINDING AS 
    SELECT ISNULL(a.CustomerID,0) as CustomerID,
           a.AddressLine1,
           a.AddressLine2,
           a.AddressLine3,
           a.AddressLine4,
           a.AddressLine5,
           a.TownCity AS City,
           a.County,
           a.PostalCode AS PostCode,
           ctr.Name Country,
           CONCAT(a.AddressLine1 + ' ', 
                  a.AddressLine2 + ' ', 
                  a.AddressLine3 + ' ', 
                  a.AddressLine4 + ' ', 
                  a.AddressLine5 + ' ', 
                  a.TownCity + ' ', 
                  a.County + ' ', 
                  a.PostalCode) as FullAddress,
		  a.PrimaryInd
      FROM Staging.STG_Address AS a INNER JOIN Reference.Country AS ctr
        ON a.CountryID = ctr.CountryID
     WHERE a.PrimaryInd = 1
	 
       AND a.ArchivedInd = 0
	   AND ctr.ArchivedInd = 0
	   
       AND a.CustomerID IS NOT NULL
GO


