USE [CEM]
GO
/****** Object:  View [api_customer_competition].[Competition]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE VIEW [api_customer_competition].[Competition] AS
      SELECT CAST(NULL AS INT) CompetitionID,
             CAST(NULL AS VARCHAR(255)) EncryptedEmail,
             CAST(NULL AS VARCHAR(255)) Name,
             CAST(NULL AS VARCHAR(255)) Description,
             CAST(NULL AS DATETIME) registrationDate,
             CAST(NULL AS DATETIME) startDate,
             CAST(NULL AS DATETIME) endDate,
             CAST(NULL AS VARCHAR(50)) status

GO
