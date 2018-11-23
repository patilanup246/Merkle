  CREATE VIEW [api_customer_competition].[Competition] AS
      SELECT CAST(NULL AS INT) CompetitionID,
             CAST(NULL AS VARCHAR(255)) EncryptedEmail,
             CAST(NULL AS VARCHAR(255)) Name,
             CAST(NULL AS VARCHAR(255)) Description,
             CAST(NULL AS DATETIME) registrationDate,
             CAST(NULL AS DATETIME) startDate,
             CAST(NULL AS DATETIME) endDate,
             CAST(NULL AS VARCHAR(50)) status