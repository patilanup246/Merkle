USE [CEM]
GO
/****** Object:  UserDefinedTableType [api_manager].[CustomerSales]    Script Date: 24/07/2018 14:20:05 ******/
CREATE TYPE [api_manager].[CustomerSales] AS TABLE(
	[CBECustomerId] [int] NOT NULL,
	[SalesTransactionNumber] [nvarchar](256) NOT NULL,
	[SalesTransactionDate] [datetime] NOT NULL,
	[LoyaltyCardSchemeCode] [nvarchar](256) NOT NULL,
	[LoyaltyCardNumber] [nvarchar](256) NOT NULL,
	[BonusCurrencyEarned] [int] NULL
)
GO
