CREATE TABLE [Staging].[STG_CustomerLoyaltyAccount] (
    [CustomerLoyaltyAccountID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]                     NVARCHAR (256)  NULL,
    [Description]              NVARCHAR (4000) NULL,
    [CreatedDate]              DATETIME        NOT NULL,
    [CreatedBy]                INT             NOT NULL,
    [LastModifiedDate]         DATETIME        NOT NULL,
    [LastModifiedBy]           INT             NOT NULL,
    [ArchivedInd]              BIT             DEFAULT ((0)) NOT NULL,
    [CustomerID]               INT             NOT NULL,
    [LoyaltyAccountID]         INT             NOT NULL,
    [StartDate]                DATETIME        NOT NULL,
    [EndDate]                  DATETIME        NULL,
    [InformationSourceID]      INT             NOT NULL,
    [ExtReference]             NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_LoyaltyAccountCustomer] PRIMARY KEY CLUSTERED ([CustomerLoyaltyAccountID] ASC),
    CONSTRAINT [FK_STG_CustomerLoyaltyAccount_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_CustomerLoyaltyAccount_LoyaltyAccountID] FOREIGN KEY ([LoyaltyAccountID]) REFERENCES [Staging].[STG_LoyaltyAccount] ([LoyaltyAccountID])
);

