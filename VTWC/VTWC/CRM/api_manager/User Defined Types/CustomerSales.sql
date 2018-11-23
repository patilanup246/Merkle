CREATE TYPE [api_manager].[CustomerSales] AS TABLE (
    [CBECustomerId]          INT            NOT NULL,
    [SalesTransactionNumber] NVARCHAR (256) NOT NULL,
    [SalesTransactionDate]   DATETIME       NOT NULL,
    [LoyaltyCardSchemeCode]  NVARCHAR (256) NOT NULL,
    [LoyaltyCardNumber]      NVARCHAR (256) NOT NULL,
    [BonusCurrencyEarned]    INT            NULL);

