USE [CEM]
GO
/****** Object:  User [p.elizabeth.vons]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.elizabeth.vons] FOR LOGIN [p.elizabeth.vons] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.elizabeth.vons]
GO
