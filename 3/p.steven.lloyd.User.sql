USE [CEM]
GO
/****** Object:  User [p.steven.lloyd]    Script Date: 24/07/2018 14:20:01 ******/
CREATE USER [p.steven.lloyd] FOR LOGIN [p.steven.lloyd] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.steven.lloyd]
GO
