USE [CEM]
GO
/****** Object:  User [p.nadia.carmona]    Script Date: 24/07/2018 14:20:01 ******/
CREATE USER [p.nadia.carmona] FOR LOGIN [p.nadia.carmona] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.nadia.carmona]
GO
