USE [CEM]
GO
/****** Object:  UserDefinedTableType [api_manager].[RailCard]    Script Date: 24/07/2018 14:20:07 ******/
CREATE TYPE [api_manager].[RailCard] AS TABLE(
	[Code] [nvarchar](256) NULL,
	[Quantity] [int] NULL,
	[PurchasedProductCode] [nvarchar](256) NULL
)
GO
