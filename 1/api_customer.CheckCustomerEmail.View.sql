USE [CEM]
GO
/****** Object:  View [api_customer].[CheckCustomerEmail]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
  CREATE VIEW [api_customer].[CheckCustomerEmail] AS
    SELECT ea.EncrytpedAddress AS EmailAddress 
      FROM Staging.STG_ElectronicAddress ea
           INNER JOIN Staging.STG_Customer c ON ea.CustomerID = c.CustomerID
     WHERE ea.PrimaryInd = 1 
       AND ea.AddressTypeID = 3
       AND ea.ArchivedInd = 0
       -- Valid addresses are those that have purchase something during the last 18 months
       AND c.DateLastPurchase >= Dateadd(Month, Datediff(Month, 0, DATEADD(m, -18, current_timestamp)), 0)


GO
