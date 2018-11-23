CREATE TABLE [Production].[LegacyCampaignResponse] (
    [LegacyCampaignResponseID] INT      IDENTITY (1, 1) NOT NULL,
    [LegacyCampaignID]         INT      NOT NULL,
    [LegacyContactHistoryID]   INT      NOT NULL,
    [CustomerID]               INT      NULL,
    [IndividualID]             INT      NULL,
    [CreatedDate]              DATETIME NOT NULL,
    [LastModifiedDate]         DATETIME NOT NULL,
    [ResponseDate]             DATETIME NOT NULL,
    [ResponseCodeID]           INT      NOT NULL,
    [OrderID]                  INT      NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_LegacyCampaignResponse] PRIMARY KEY CLUSTERED ([LegacyCampaignResponseID] ASC),
    CONSTRAINT [FK_LegacyCampaignResponse_CampaignID] FOREIGN KEY ([LegacyCampaignID]) REFERENCES [Production].[LegacyCampaign] ([LegacyCampaignID]),
    CONSTRAINT [FK_LegacyCampaignResponse_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_LegacyCampaignResponse_IndividualID] FOREIGN KEY ([IndividualID]) REFERENCES [Staging].[STG_Individual] ([IndividualID]),
    CONSTRAINT [FK_LegacyCampaignResponse_LegacyContactHistoryID] FOREIGN KEY ([LegacyContactHistoryID]) REFERENCES [Production].[LegacyContactHistory] ([LegacyContactHistoryID]),
    CONSTRAINT [FK_LegacyCampaignResponse_ResponseCodeID] FOREIGN KEY ([ResponseCodeID]) REFERENCES [Reference].[ResponseCode] ([ResponseCodeID])
);


GO
CREATE NONCLUSTERED INDEX [lcrResponseCode]
    ON [Production].[LegacyCampaignResponse]([ResponseCodeID] ASC, [ResponseDate] ASC)
    INCLUDE([CustomerID]);


GO
CREATE NONCLUSTERED INDEX [lcrIndividual]
    ON [Production].[LegacyCampaignResponse]([ResponseCodeID] ASC, [ResponseDate] ASC)
    INCLUDE([IndividualID]);


GO
CREATE NONCLUSTERED INDEX [ix_LegacyCampaignResponse_OrderID]
    ON [Production].[LegacyCampaignResponse]([OrderID] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_LegacyCampaignResponse_IndividualID]
    ON [Production].[LegacyCampaignResponse]([IndividualID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_LegacyCampaignResponse_Date_CodeID]
    ON [Production].[LegacyCampaignResponse]([ResponseDate] ASC, [ResponseCodeID] ASC)
    INCLUDE([CustomerID]);


GO
CREATE NONCLUSTERED INDEX [DBA_NCI_CustomerID]
    ON [Production].[LegacyCampaignResponse]([CustomerID] ASC);

