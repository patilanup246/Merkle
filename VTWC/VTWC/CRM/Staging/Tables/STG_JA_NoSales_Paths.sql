CREATE TABLE [Staging].[STG_JA_NoSales_Paths] (
    [customerid] INT            NULL,
    [Last_Sale]  DATETIME       NULL,
    [path]       NVARCHAR (MAX) NULL
);


GO
CREATE NONCLUSTERED INDEX [journey_no_sales_cust]
    ON [Staging].[STG_JA_NoSales_Paths]([customerid] ASC);

