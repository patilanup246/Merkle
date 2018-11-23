CREATE TABLE [Staging].[STG_LoyaltyAllocation] (
    [LoyaltyAllocationID]   INT             IDENTITY (1, 1) NOT NULL,
    [Name]                  NVARCHAR (256)  NULL,
    [Description]           NVARCHAR (4000) NULL,
    [CreatedDate]           DATETIME        NOT NULL,
    [CreatedBy]             INT             NOT NULL,
    [LastModifiedDate]      DATETIME        NOT NULL,
    [LastModifiedBy]        INT             NOT NULL,
    [ArchivedInd]           BIT             DEFAULT ((0)) NOT NULL,
    [SourceCreatedDate]     DATETIME        NOT NULL,
    [SourceModifiedDate]    DATETIME        NOT NULL,
    [LoyaltyStatusID]       INT             NOT NULL,
    [LoyaltyAccountID]      INT             NOT NULL,
    [SalesTransactionID]    INT             NULL,
    [SalesTransactionDate]  DATETIME        NOT NULL,
    [SalesDetailID]         INT             NULL,
    [LoyaltyXChangeRateID]  INT             NULL,
    [QualifyingSalesAmount] DECIMAL (14, 2) NULL,
    [LoyaltyCurrencyAmount] DECIMAL (14, 2) NULL,
    [InformationSourceID]   INT             NOT NULL,
    [ExtReference]          NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_LoyaltyAllocation] PRIMARY KEY CLUSTERED ([LoyaltyAllocationID] ASC),
    CONSTRAINT [FK_STG_LoyaltyAllocation_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_STG_LoyaltyAllocation_LoyaltyAccountID] FOREIGN KEY ([LoyaltyAccountID]) REFERENCES [Staging].[STG_LoyaltyAccount] ([LoyaltyAccountID]),
    CONSTRAINT [FK_STG_LoyaltyAllocation_LoyaltyStatusID] FOREIGN KEY ([LoyaltyStatusID]) REFERENCES [Reference].[LoyaltyStatus] ([LoyaltyStatusID]),
    CONSTRAINT [FK_STG_LoyaltyAllocation_SalesDetailID] FOREIGN KEY ([SalesDetailID]) REFERENCES [Staging].[STG_SalesDetail] ([SalesDetailID]),
    CONSTRAINT [FK_STG_LoyaltyAllocation_SalesTransactionID] FOREIGN KEY ([SalesTransactionID]) REFERENCES [Staging].[STG_SalesTransaction] ([SalesTransactionID])
);


GO
CREATE NONCLUSTERED INDEX [ix_STG_LoyaltyAllocation_SalesTransactionId]
    ON [Staging].[STG_LoyaltyAllocation]([SalesTransactionID] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_STG_LoyaltyAllocation_SalesTransactionDate]
    ON [Staging].[STG_LoyaltyAllocation]([SalesTransactionDate] ASC)
    INCLUDE([LoyaltyAccountID], [QualifyingSalesAmount]);


GO
CREATE NONCLUSTERED INDEX [ix_STG_LoyaltyAllocation_ExtReference]
    ON [Staging].[STG_LoyaltyAllocation]([ExtReference] ASC);

