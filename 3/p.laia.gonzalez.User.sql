USE [CEM]
GO
/****** Object:  User [p.laia.gonzalez]    Script Date: 24/07/2018 14:20:01 ******/
CREATE USER [p.laia.gonzalez] FOR LOGIN [p.laia.gonzalez] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.laia.gonzalez]
GO
