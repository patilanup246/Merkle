USE [CEM]
GO
/****** Object:  UserDefinedTableType [api_manager].[PurchasedProduct]    Script Date: 24/07/2018 14:20:06 ******/
CREATE TYPE [api_manager].[PurchasedProduct] AS TABLE(
	[SalesTransactionNumber] [nvarchar](256) NOT NULL,
	[ProductType] [nvarchar](256) NULL,
	[ProductCode] [nvarchar](256) NULL,
	[IncludesVTECLegInd] [bit] NULL,
	[NumberOfTravellers] [int] NULL,
	[ProductCost] [float] NULL,
	[AddonCost] [float] NULL,
	[TotalCost] [float] NOT NULL
)
GO
