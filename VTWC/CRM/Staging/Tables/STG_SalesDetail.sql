CREATE TABLE [Staging].[STG_SalesDetail] (
    [SalesDetailID]             INT             IDENTITY (1, 1) NOT NULL,
    [Name]                      NVARCHAR (256)  NULL,
    [Description]               NVARCHAR (4000) NULL,
    [CreatedDate]               DATETIME        NOT NULL,
    [CreatedBy]                 INT             NOT NULL,
    [LastModifiedDate]          DATETIME        NOT NULL,
    [LastModifiedBy]            INT             NOT NULL,
    [ArchivedInd]               BIT             DEFAULT ((0)) NOT NULL,
    [SalesTransactionID]        INT             NOT NULL,
    [ProductID]                 INT             NOT NULL,
    [Quantity]                  INT             NULL,
    [UnitPrice]                 DECIMAL (14, 2) NULL,
    [SalesAmount]               DECIMAL (14, 2) NOT NULL,
    [IsTrainTicketInd]          BIT             DEFAULT ((0)) NOT NULL,
    [RailcardTypeID]            INT             NULL,
    [ExtReference]              BIGINT          NOT NULL,
    [InformationSourceID]       INT             NOT NULL,
    [FulfilmentMethodID]        INT             NULL,
    [TransactionStatusID]       INT             NULL,
    [OutTravelDate]             DATETIME        NULL,
    [ReturnTravelDate]          DATETIME        NULL,
    [IsReturnInferredInd]       BIT             DEFAULT ((0)) NOT NULL,
    [CustomerID]                INT             NULL,
    [ValidityStartDate]         DATETIME        NULL,
    [ValidityEndDate]           DATETIME        NULL,
    [FareTypeCd]                NVARCHAR (32)   NULL,
    [FareCategoryCd]            NVARCHAR (32)   NULL,
    [TicketRestrictionID]       INT             NULL,
    [businessorleisure]         NCHAR (1)       NULL,
    [refundind]                 BIT             NULL,
    [refunddate]                DATETIME        NULL,
    [CreatedExtractNumber]      INT             NULL,
    [LastModifiedExtractNumber] INT             NULL,
    [TCSBookingID]              INT             NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_SalesDetail] PRIMARY KEY CLUSTERED ([SalesDetailID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_STG_SalesDetail_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_SalesDetail_FulfilmentMethodID] FOREIGN KEY ([FulfilmentMethodID]) REFERENCES [Reference].[FulfilmentMethod] ([FulfilmentMethodID]),
    CONSTRAINT [FK_STG_SalesDetail_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_STG_SalesDetail_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Reference].[Product] ([ProductID]),
    CONSTRAINT [FK_STG_SalesDetail_RailcardTypeID] FOREIGN KEY ([RailcardTypeID]) REFERENCES [Reference].[RailcardType] ([RailcardTypeID]),
    CONSTRAINT [FK_STG_SalesDetail_SalesTransactionID] FOREIGN KEY ([SalesTransactionID]) REFERENCES [Staging].[STG_SalesTransaction] ([SalesTransactionID]),
    CONSTRAINT [FK_STG_SalesDetail_TicketRestrictionID] FOREIGN KEY ([TicketRestrictionID]) REFERENCES [Reference].[TicketRestriction] ([TicketRestrictionID]),
    CONSTRAINT [FK_STG_SalesDetail_TransactionStatusID] FOREIGN KEY ([TransactionStatusID]) REFERENCES [Reference].[TransactionStatus] ([TransactionStatusID])
);


GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesDetail_ArchivedInd]
    ON [Staging].[STG_SalesDetail]([ArchivedInd] ASC)
    INCLUDE([SalesTransactionID]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesDetail_ExtReference]
    ON [Staging].[STG_SalesDetail]([ExtReference] ASC);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesDetail_InformationSourceID]
    ON [Staging].[STG_SalesDetail]([IsTrainTicketInd] ASC, [InformationSourceID] ASC)
    INCLUDE([SalesDetailID], [ExtReference], [CustomerID]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesDetail_IsTrainTicketInd]
    ON [Staging].[STG_SalesDetail]([IsTrainTicketInd] ASC)
    INCLUDE([SalesTransactionID], [ProductID]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesDetail_ProductID]
    ON [Staging].[STG_SalesDetail]([ProductID] ASC)
    INCLUDE([SalesDetailID], [SalesTransactionID], [OutTravelDate]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_SalesDetail_SalesTransactionID]
    ON [Staging].[STG_SalesDetail]([SalesTransactionID] ASC);
GO

CREATE NONCLUSTERED INDEX [Missing_IXNC_STG_SalesDetail_IsTrainTicketInd_OutTravelDate]
    ON [Staging].[STG_SalesDetail]([IsTrainTicketInd] ASC, [OutTravelDate] ASC)
    INCLUDE([SalesTransactionID]);
GO

EXECUTE sp_addextendedproperty @name = N'TCSBookingID', @value = N'ID to link TCSBookingID in Journey', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_SalesDetail';
GO
CREATE NONCLUSTERED INDEX [dba_fnci_archiveInd_Includes]
    ON [Staging].[STG_SalesDetail]([ArchivedInd] ASC)
    INCLUDE([SalesDetailID], [SalesTransactionID], [ProductID], [SalesAmount], [OutTravelDate], [ReturnTravelDate]) WHERE ([ArchivedInd]=(0)) WITH (FILLFACTOR = 80);

