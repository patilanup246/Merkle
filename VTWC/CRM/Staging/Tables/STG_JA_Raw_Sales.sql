CREATE TABLE [Staging].[STG_JA_Raw_Sales] (
    [customerid]      INT          NULL,
    [action_datetime] DATETIME     NULL,
    [action_type]     VARCHAR (50) NULL,
    [Last_Sale]       DATETIME     NULL,
    [Last_Activity]   DATETIME     NULL
);


GO
CREATE NONCLUSTERED INDEX [journey_salesdate]
    ON [Staging].[STG_JA_Raw_Sales]([Last_Sale] ASC);


GO
CREATE NONCLUSTERED INDEX [journey_cust]
    ON [Staging].[STG_JA_Raw_Sales]([customerid] ASC);


GO
CREATE NONCLUSTERED INDEX [journey_actiondate]
    ON [Staging].[STG_JA_Raw_Sales]([action_datetime] ASC);

