USE [CEM]
GO
/****** Object:  User [p.kristian.veslov]    Script Date: 24/07/2018 14:20:01 ******/
CREATE USER [p.kristian.veslov] FOR LOGIN [p.kristian.veslov] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.kristian.veslov]
GO
