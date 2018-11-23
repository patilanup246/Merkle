CREATE TABLE [Production].[RFV_History] (
    [customerid]          INT          NULL,
    [rfv_segment]         VARCHAR (50) NULL,
    [effective_from_date] DATE         NULL,
    [effective_to_date]   DATE         NULL
);


GO
CREATE NONCLUSTERED INDEX [rfv_hist_to_date]
    ON [Production].[RFV_History]([effective_to_date] ASC);


GO
CREATE NONCLUSTERED INDEX [rfv_hist_segment]
    ON [Production].[RFV_History]([rfv_segment] ASC);


GO
CREATE NONCLUSTERED INDEX [rfv_hist_from_date]
    ON [Production].[RFV_History]([effective_from_date] ASC);


GO
CREATE NONCLUSTERED INDEX [rfv_hist_customer]
    ON [Production].[RFV_History]([customerid] ASC);

