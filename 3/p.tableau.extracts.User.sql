USE [CEM]
GO
/****** Object:  User [p.tableau.extracts]    Script Date: 24/07/2018 14:20:01 ******/
CREATE USER [p.tableau.extracts] FOR LOGIN [p.tableau.extracts] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.tableau.extracts]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [p.tableau.extracts]
GO
