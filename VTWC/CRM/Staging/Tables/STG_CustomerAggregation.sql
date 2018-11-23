CREATE TABLE [Staging].[STG_CustomerAggregation] (
    [CustomerID]                            INT NOT NULL,
    [TransactionsLast12MnthsFirst]          INT NOT NULL,
    [TransactionsLast12MnthsStandard]       INT NOT NULL,
    [TransactionsLast6MnthsFirst]           INT NOT NULL,
    [TransactionsLast6MnthsFirstWeekday]    INT NOT NULL,
    [TransactionsLast6MnthsFirstWeekend]    INT NOT NULL,
    [TransactionsLast6MnthsStandard]        INT NOT NULL,
    [TransactionsLast6MnthsStandardWeekday] INT NOT NULL,
    [TransactionsLast6MnthsStandardWeekend] INT NOT NULL,
    [TransactionsLast12MnthsFirstSolo]      INT NOT NULL,
    [TransactionsLast12MnthsStandardSolo]   INT NOT NULL,
    [TransactionsLast12MnthsFirstWeekday]   INT NOT NULL,
    [TransactionsLast12MnthsFirstWeekend]   INT NOT NULL,
    PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);

