USE [CEM]
GO
/****** Object:  User [p.haydn.barclay]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.haydn.barclay] FOR LOGIN [p.haydn.barclay] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.haydn.barclay]
GO
