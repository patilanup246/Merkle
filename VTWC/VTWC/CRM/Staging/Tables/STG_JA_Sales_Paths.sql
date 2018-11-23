CREATE TABLE [Staging].[STG_JA_Sales_Paths] (
    [customerid] INT            NULL,
    [Last_Sale]  DATETIME       NULL,
    [path]       NVARCHAR (MAX) NULL
);


GO
CREATE NONCLUSTERED INDEX [journey_sales_cust]
    ON [Staging].[STG_JA_Sales_Paths]([customerid] ASC);

