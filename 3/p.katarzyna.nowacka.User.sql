USE [CEM]
GO
/****** Object:  User [p.katarzyna.nowacka]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.katarzyna.nowacka] FOR LOGIN [p.katarzyna.nowacka] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.katarzyna.nowacka]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [p.katarzyna.nowacka]
GO
