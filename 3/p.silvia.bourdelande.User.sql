USE [CEM]
GO
/****** Object:  User [p.silvia.bourdelande]    Script Date: 24/07/2018 14:20:01 ******/
CREATE USER [p.silvia.bourdelande] FOR LOGIN [p.silvia.bourdelande] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [p.silvia.bourdelande]
GO
