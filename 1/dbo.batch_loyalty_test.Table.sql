USE [CEM]
GO
/****** Object:  Table [dbo].[batch_loyalty_test]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[batch_loyalty_test](
	[customerid] [int] NULL,
	[SalesTransactionDate] [datetime] NULL,
	[SalesTransactionId] [int] NULL,
	[LoyaltyCardSchemeName] [nvarchar](100) NULL,
	[LoyaltyCardNumber] [nvarchar](256) NULL,
	[ProductType] [nvarchar](256) NULL,
	[ProductCode] [nvarchar](256) NULL,
	[RailcardType] [nvarchar](256) NULL,
	[IncludesVTECLegInd] [bit] NULL,
	[Quantity] [int] NULL,
	[UnitPrice] [decimal](14, 2) NULL,
	[TotalPaid] [decimal](14, 2) NULL,
	[LoyaltyCurrency] [int] NULL
) ON [PRIMARY]

GO
