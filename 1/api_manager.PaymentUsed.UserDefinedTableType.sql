USE [CEM]
GO
/****** Object:  UserDefinedTableType [api_manager].[PaymentUsed]    Script Date: 24/07/2018 14:20:06 ******/
CREATE TYPE [api_manager].[PaymentUsed] AS TABLE(
	[PaymentMethodType] [varchar](256) NULL,
	[Amount] [float] NULL,
	[SalesTransactionNumber] [nvarchar](256) NOT NULL
)
GO
