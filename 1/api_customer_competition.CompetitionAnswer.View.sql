USE [CEM]
GO
/****** Object:  View [api_customer_competition].[CompetitionAnswer]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE VIEW [api_customer_competition].[CompetitionAnswer] AS
    SELECT CAST(NULL AS INT) CustomerID,
           CAST(NULL AS VARCHAR(255)) EncryptedEmail,
           CAST(NULL AS INT) CompetitionID,
           CAST(NULL AS VARCHAR(255)) Answer

GO
