CREATE TABLE [Production].[LegacyContactHistory] (
    [LegacyContactHistoryID] INT            IDENTITY (1, 1) NOT NULL,
    [LegacyCampaignID]       INT            NOT NULL,
    [CustomerID]             INT            NULL,
    [CreatedDate]            DATETIME       NOT NULL,
    [LastModifiedDate]       DATETIME       NOT NULL,
    [EmailAddress]           NVARCHAR (256) NULL,
    [ContactDate]            DATETIME       NOT NULL,
    [Segment]                INT            NULL,
    [SubSegment]             INT            NULL,
    [ControlCell]            BIT            DEFAULT ((0)) NULL,
    [VoucherCode]            NVARCHAR (50)  NULL,
    [VoucherValue]           NVARCHAR (10)  NULL,
    [TierNumber]             INT            NULL,
    [TierName]               NVARCHAR (256) NULL,
    [HomeStation]            NVARCHAR (256) NULL,
    [ECHomeStation]          NVARCHAR (256) NULL,
    [OrderID]                INT            NULL,
    [IndividualID]           INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_LegacyContactHistory] PRIMARY KEY CLUSTERED ([LegacyContactHistoryID] ASC),
    CONSTRAINT [FK_LegacyContactHistory_CampaignID] FOREIGN KEY ([LegacyCampaignID]) REFERENCES [Production].[LegacyCampaign] ([LegacyCampaignID]),
    CONSTRAINT [FK_LegacyContactHistory_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID])
);


GO
CREATE NONCLUSTERED INDEX [Missing_IXNC_LegacyContactHistory_LegacyCampaignID]
    ON [Production].[LegacyContactHistory]([LegacyCampaignID] ASC)
    INCLUDE([CustomerID]);


GO
CREATE NONCLUSTERED INDEX [lchIndividualId]
    ON [Production].[LegacyContactHistory]([ControlCell] ASC, [ContactDate] ASC, [IndividualID] ASC);


GO
CREATE NONCLUSTERED INDEX [lchCustomerID]
    ON [Production].[LegacyContactHistory]([ControlCell] ASC, [CustomerID] ASC, [ContactDate] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_LegacyContactHistory_OrderID]
    ON [Production].[LegacyContactHistory]([OrderID] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_LegacyContactHistory_IndividualID]
    ON [Production].[LegacyContactHistory]([IndividualID] ASC)
    INCLUDE([LegacyContactHistoryID], [LegacyCampaignID], [OrderID]);


GO
CREATE NONCLUSTERED INDEX [ix_LegacyContactHistory_CreatedDate]
    ON [Production].[LegacyContactHistory]([CreatedDate] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_LegacyContactHistory_CustomerID]
    ON [Production].[LegacyContactHistory]([CustomerID] ASC);


GO
CREATE NONCLUSTERED INDEX [DBA_NCI_EmailAddress]
    ON [Production].[LegacyContactHistory]([EmailAddress] ASC)
    INCLUDE([LegacyCampaignID]);

