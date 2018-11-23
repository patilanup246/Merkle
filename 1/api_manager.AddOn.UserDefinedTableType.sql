USE [CEM]
GO
/****** Object:  UserDefinedTableType [api_manager].[AddOn]    Script Date: 24/07/2018 14:20:05 ******/
CREATE TYPE [api_manager].[AddOn] AS TABLE(
	[ProductType] [varchar](256) NULL,
	[ProductCode] [varchar](256) NULL,
	[NumberOfTravellers] [int] NULL,
	[Cost] [float] NULL,
	[PurchasedProductCode] [nvarchar](256) NULL
)
GO
