USE [CEM]
GO
/****** Object:  User [p.jez.cox]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.jez.cox] FOR LOGIN [p.jez.cox] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [p.jez.cox]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.jez.cox]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [p.jez.cox]
GO
