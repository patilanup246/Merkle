USE [CEM]
GO
/****** Object:  User [CEMAPIDBUser]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [CEMAPIDBUser] FOR LOGIN [CEMAPIDBUser] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [CEMAPIDBUser]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [CEMAPIDBUser]
GO
