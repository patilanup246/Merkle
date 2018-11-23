CREATE TABLE [PreProcessing].[TOC_Purchase] (
    [TOC_PurchaseID]    INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustomerId]        INT            NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [DateUpdated]       DATETIME       NOT NULL,
    [ChannelCode]       NVARCHAR (6)   NOT NULL,
    [PurchaseId]        INT            NOT NULL,
    [PurchaseCode]      NVARCHAR (6)   NOT NULL,
    [TransactionId]     INT            NOT NULL,
    [TransactionDate]   DATETIME       NOT NULL,
    [PurchaseValue]     DECIMAL (9, 2) NOT NULL,
    [NoOfItems]         INT            NOT NULL,
    [PurchaseDate]      DATETIME       NOT NULL,
    [BusinessOrLeisure] NCHAR (1)      NULL,
    [RefundInd]         NCHAR (1)      NOT NULL,
    [AmendedInd]        NCHAR (1)      NOT NULL,
    [RefundDate]        DATETIME       NULL,
    [AmendedDate]       DATETIME       NULL,
    CONSTRAINT [cndx_PrimaryKey_TOC_Purchase] PRIMARY KEY CLUSTERED ([TOC_PurchaseID] ASC)
);

