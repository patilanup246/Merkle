USE [CEM]
GO
/****** Object:  User [p.javier.calvo]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.javier.calvo] FOR LOGIN [p.javier.calvo] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.javier.calvo]
GO
