USE [CEM]
GO
/****** Object:  UserDefinedTableType [api_manager].[Channel]    Script Date: 24/07/2018 14:20:05 ******/
CREATE TYPE [api_manager].[Channel] AS TABLE(
	[short_name] [varchar](64) NOT NULL
)
GO
