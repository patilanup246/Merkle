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
CREATE UNIQUE CLUSTERED INDEX [idx_api_customer_personal_details_customer_id]
    ON [api_customer].[PersonalDetails]([CustomerID] ASC);

