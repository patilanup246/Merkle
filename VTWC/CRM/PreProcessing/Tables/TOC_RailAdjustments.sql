CREATE TABLE [PreProcessing].[TOC_RailAdjustments] (
    [TOC_RailAdjustmentsID] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description]           NVARCHAR (250) NULL,
    [Id]                    INT            NOT NULL,
    [DateUpdated]           DATETIME       NOT NULL,
    [DateCreated]           DATETIME       NOT NULL,
    [TransactionDate]       DATETIME       NOT NULL,
    [JourneyId]             INT            NOT NULL,
    [Reason]                NVARCHAR (5)   NOT NULL,
    [Amount]                DECIMAL (8, 2) NOT NULL,
    [AdultAmount]           DECIMAL (8, 2) NULL,
    [ChildAmount]           DECIMAL (8, 2) NULL,
    [AdultRailcardAmount]   DECIMAL (8, 2) NULL,
    [AdultRailcard2Amount]  DECIMAL (8, 2) NULL,
    [AdultRailcard3Amount]  DECIMAL (8, 2) NULL,
    [ChildRailcardAmount]   DECIMAL (8, 2) NULL,
    [ChildRailcard2Amount]  DECIMAL (8, 2) NULL,
    [ChildRailcard3Amount]  DECIMAL (8, 2) NULL,
    [ProCode]               NVARCHAR (10)  NULL,
    CONSTRAINT [cndx_PrimaryKey_TOC_RailAdjustments] PRIMARY KEY CLUSTERED ([TOC_RailAdjustmentsID] ASC)
);

