USE [CEM]
GO
/****** Object:  User [p.james.cullen]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.james.cullen] FOR LOGIN [p.james.cullen] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.james.cullen]
GO
