USE [CEM]
GO
/****** Object:  User [p.catalin.codrean]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.catalin.codrean] FOR LOGIN [p.catalin.codrean] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [p.catalin.codrean]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.catalin.codrean]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [p.catalin.codrean]
GO
