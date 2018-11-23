CREATE TYPE [api_manager].[PaymentUsed] AS TABLE (
    [PaymentMethodType]      VARCHAR (256)  NULL,
    [Amount]                 FLOAT (53)     NULL,
    [SalesTransactionNumber] NVARCHAR (256) NOT NULL);

