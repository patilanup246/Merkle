USE [CEM]
GO
/****** Object:  View [api_customer].[Address]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
                  a.PostalCode) as FullAddress
      FROM Staging.STG_Address AS a INNER JOIN Reference.Country AS ctr
        ON a.CountryID = ctr.CountryID
     WHERE a.PrimaryInd = 1
	 
       AND a.ArchivedInd = 0
	   AND ctr.ArchivedInd = 0
	   
       AND a.CustomerID IS NOT NULL


GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [idx_api_customer_address_customer_id]    Script Date: 24/07/2018 14:20:08 ******/
CREATE UNIQUE CLUSTERED INDEX [idx_api_customer_address_customer_id] ON [api_customer].[Address]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
