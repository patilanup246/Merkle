USE [CEM]
GO
/****** Object:  User [DanielaMoraes]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [DanielaMoraes] FOR LOGIN [DanielaMoraes] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DanielaMoraes]
GO
