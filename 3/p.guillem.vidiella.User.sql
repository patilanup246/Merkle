USE [CEM]
GO
/****** Object:  User [p.guillem.vidiella]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.guillem.vidiella] FOR LOGIN [p.guillem.vidiella] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.guillem.vidiella]
GO
