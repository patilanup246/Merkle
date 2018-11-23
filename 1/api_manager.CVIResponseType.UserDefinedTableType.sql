USE [CEM]
GO
/****** Object:  UserDefinedTableType [api_manager].[CVIResponseType]    Script Date: 24/07/2018 14:20:06 ******/
CREATE TYPE [api_manager].[CVIResponseType] AS TABLE(
	[QuestionId] [int] NULL,
	[GroupName] [nvarchar](250) NULL,
	[AnswerName] [nvarchar](250) NULL,
	[Response] [nvarchar](4000) NULL
)
GO
