USE [CEM]
GO
/****** Object:  User [p.lilian.moura]    Script Date: 24/07/2018 14:20:01 ******/
CREATE USER [p.lilian.moura] FOR LOGIN [p.lilian.moura] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.lilian.moura]
GO
