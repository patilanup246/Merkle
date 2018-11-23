CREATE TABLE [PreProcessing].[TOC_Transaction] (
    [TOC_TransactionID]       INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TransactionId]           INT            NOT NULL,
    [CustomerId]              INT            NOT NULL,
    [TransactionDate]         DATETIME       NOT NULL,
    [ChannelCode]             NVARCHAR (6)   NOT NULL,
    [BusinessOrLeisure]       NCHAR (1)      NULL,
    [TotalCostOfAllPurchases] DECIMAL (9, 2) NULL,
    [TotalNoOfAllPurchases]   DECIMAL (9, 2) NULL,
    [DateCreated]             DATETIME       NOT NULL,
    [DateUpdated]             DATETIME       NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_TOC_Transaction] PRIMARY KEY CLUSTERED ([TOC_TransactionID] ASC)
);

