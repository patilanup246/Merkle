USE [CEM]
GO
/****** Object:  User [p.tables.email]    Script Date: 24/07/2018 14:20:01 ******/
CREATE USER [p.tables.email] FOR LOGIN [p.tables.email] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.tables.email]
GO
