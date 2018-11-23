CREATE TABLE [PreProcessing].[TOC_RailSupplement] (
    [TOC_RailSupplementID] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TransactionDate]      DATETIME       NOT NULL,
    [JourneyId]            INT            NOT NULL,
    [TotalCost]            DECIMAL (8, 2) NOT NULL,
    [LegId]                INT            NULL,
    [SupplementId]         INT            NOT NULL,
    [SutCode]              NVARCHAR (5)   NOT NULL,
    [SupLevel]             NCHAR (3)      NULL,
    [Cost]                 DECIMAL (8, 2) NOT NULL,
    [Quantity]             INT            NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_TOC_RailSupplement] PRIMARY KEY CLUSTERED ([TOC_RailSupplementID] ASC)
);

