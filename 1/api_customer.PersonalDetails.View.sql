USE [CEM]
GO
/****** Object:  View [api_customer].[PersonalDetails]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE VIEW [api_customer].[PersonalDetails] WITH SCHEMABINDING AS
    SELECT c.CustomerID, 
           c.Salutation, 
           c.FirstName  AS Forename,
           c.LastName   AS Surname,
           cast(NULL as date)    AS DOB,
           CONCAT(c.Salutation + ' ', c.FirstName + ' ',  c.LastName) as FullName
      FROM Staging.STG_Customer c
     WHERE c.ArchivedInd = 0


GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [idx_api_customer_personal_details_customer_id]    Script Date: 24/07/2018 14:20:08 ******/
CREATE UNIQUE CLUSTERED INDEX [idx_api_customer_personal_details_customer_id] ON [api_customer].[PersonalDetails]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
