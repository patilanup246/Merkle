USE [CEM]
GO
/****** Object:  User [p.andreas.liljeberg]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.andreas.liljeberg] FOR LOGIN [p.andreas.liljeberg] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.andreas.liljeberg]
GO
