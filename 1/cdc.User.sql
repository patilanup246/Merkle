USE [CEM]
GO
/****** Object:  User [cdc]    Script Date: 24/07/2018 14:20:02 ******/
CREATE USER [cdc] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[cdc]
GO
ALTER ROLE [db_owner] ADD MEMBER [cdc]
GO
