USE [CEM]
GO
/****** Object:  User [p.albert.sabater]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [p.albert.sabater] FOR LOGIN [p.albert.sabater] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.albert.sabater]
GO
