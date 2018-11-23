  CREATE VIEW [api_customer].[CheckCustomerEmail] AS
    SELECT ea.[HashedAddress] AS EmailAddress 
      FROM Staging.STG_ElectronicAddress ea
           INNER JOIN Staging.STG_Customer c ON ea.CustomerID = c.CustomerID
     WHERE ea.PrimaryInd = 1 
       AND ea.AddressTypeID = 3
       AND ea.ArchivedInd = 0
       -- Valid addresses are those that have purchase something during the last 18 months
       AND c.DateLastPurchase >= Dateadd(Month, Datediff(Month, 0, DATEADD(m, -18, current_timestamp)), 0)