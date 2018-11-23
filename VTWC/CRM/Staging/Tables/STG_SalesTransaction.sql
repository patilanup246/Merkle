CREATE TABLE [Staging].[STG_SalesTransaction] (
    [SalesTransactionID]        INT             IDENTITY (1, 1) NOT NULL,
    [Name]                      NVARCHAR (256)  NULL,
    [Description]               NVARCHAR (4000) NULL,
    [CreatedDate]               DATETIME        NOT NULL,
    [CreatedBy]                 INT             NOT NULL,
    [LastModifiedDate]          DATETIME        NOT NULL,
    [LastModifiedBy]            INT             NOT NULL,
    [ArchivedInd]               BIT             DEFAULT ((0)) NOT NULL,
    [SourceCreatedDate]         DATETIME        NULL,
    [SourceModifiedDate]        DATETIME        NULL,
    [SalesTransactionDate]      DATETIME        NOT NULL,
    [SalesAmountTotal]          DECIMAL (14, 2) DEFAULT ((0)) NULL,
    [LoyaltyReference]          NVARCHAR (32)   NULL,
    [RetailChannelID]           INT             NULL,
    [LocationID]                INT             NULL,
    [CustomerID]                INT             NULL,
    [IndividualID]              INT             NULL,
    [ExtReference]              NVARCHAR (256)  NULL,
    [InformationSourceID]       INT             NOT NULL,
    [BookingReference]          NVARCHAR (256)  NULL,
    [FulfilmentMethodID]        INT             NULL,
    [NumberofAdults]            INT             NULL,
    [NumberofChildren]          INT             NULL,
    [FulfilmentDate]            DATETIME        NULL,
    [SuperSalesInd]             BIT             NULL,
    [SalesAmountNotRail]        DECIMAL (14, 2) DEFAULT ((0)) NULL,
    [SalesAmountRail]           DECIMAL (14, 2) DEFAULT ((0)) NULL,
    [BookingReferenceLong]      NVARCHAR (256)  NULL,
    [BookingSourceCd]           NVARCHAR (100)  NULL,
    [LoyaltySchemeName]         NVARCHAR (256)  NULL,
    [LoyaltyProgrammeTypeID]    INT             NULL,
    [SalesTransactionNumber]    NVARCHAR (256)  NULL,
    [paymenttype]               NVARCHAR (5)    NULL,
    [cardtype]                  NVARCHAR (15)   NULL,
    [voucherused]               NVARCHAR (3)    NULL,
    [channelcode]               NVARCHAR (25)   NULL,
    [CreatedExtractNumber]      INT             NULL,
    [LastModifiedExtractNumber] INT             NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_SalesTransaction] PRIMARY KEY CLUSTERED ([SalesTransactionID] ASC),
    CONSTRAINT [FK_STG_SalesTransaction_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_SalesTransaction_FulfilmentMethodID] FOREIGN KEY ([FulfilmentMethodID]) REFERENCES [Reference].[FulfilmentMethod] ([FulfilmentMethodID]),
    CONSTRAINT [FK_STG_SalesTransaction_IndividualID] FOREIGN KEY ([IndividualID]) REFERENCES [Staging].[STG_Individual] ([IndividualID]),
    CONSTRAINT [FK_STG_SalesTransaction_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_STG_SalesTransaction_LocationID] FOREIGN KEY ([LocationID]) REFERENCES [Reference].[Location] ([LocationID]),
    CONSTRAINT [FK_STG_SalesTransaction_LoyaltyProgrammeTypeID] FOREIGN KEY ([LoyaltyProgrammeTypeID]) REFERENCES [Reference].[LoyaltyProgrammeType] ([LoyaltyProgrammeTypeID]),
    CONSTRAINT [FK_STG_SalesTransaction_RetailChannelID] FOREIGN KEY ([RetailChannelID]) REFERENCES [Reference].[RetailChannel] ([RetailChannelID])
);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesTransaction_BookingReference]
    ON [Staging].[STG_SalesTransaction]([BookingReference] ASC);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesTransaction_CustomerID]
    ON [Staging].[STG_SalesTransaction]([CustomerID] ASC)
    INCLUDE([SalesTransactionID], [SalesTransactionDate], [SalesAmountRail]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesTransaction_ExtReference]
    ON [Staging].[STG_SalesTransaction]([ExtReference] ASC);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesTransaction_indiv_SalesTransactionDate]
    ON [Staging].[STG_SalesTransaction]([SalesTransactionDate] ASC)
    INCLUDE([SalesAmountTotal], [IndividualID], [BookingReference]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesTransaction_PromoCodes]
    ON [Staging].[STG_SalesTransaction]([BookingSourceCd] ASC)
    INCLUDE([SalesAmountTotal], [CustomerID], [BookingReference], [FulfilmentDate]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesTransaction_SalesTransactionDate]
    ON [Staging].[STG_SalesTransaction]([SalesTransactionDate] ASC)
    INCLUDE([SalesTransactionID], [CustomerID]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesTransaction_SourceCreatedDate]
    ON [Staging].[STG_SalesTransaction]([ArchivedInd] ASC, [SourceCreatedDate] ASC)
    INCLUDE([SalesTransactionID], [CreatedDate], [CustomerID]);
GO

CREATE NONCLUSTERED INDEX [Missing_IXNC_STG_SalesTransaction_SalesTransactionDate]
    ON [Staging].[STG_SalesTransaction]([SalesTransactionDate] ASC)
    INCLUDE([SalesTransactionID], [CustomerID], [NumberofAdults], [NumberofChildren], [SalesAmountNotRail], [SalesAmountRail]);
GO

CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIndex-20161207-181847]
    ON [Staging].[STG_SalesTransaction]([SalesTransactionID] ASC);
GO

CREATE NONCLUSTERED INDEX [STG_SalesTransaction_CustomerID]
    ON [Staging].[STG_SalesTransaction]([ArchivedInd] ASC)
    INCLUDE([SalesTransactionID], [SalesTransactionDate], [CustomerID]);
GO

