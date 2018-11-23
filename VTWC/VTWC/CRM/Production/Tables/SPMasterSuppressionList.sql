CREATE TABLE [Production].[SPMasterSuppressionList] (
    [Email]         VARCHAR (80)  NULL,
    [OptInDate]     DATETIME      NULL,
    [OptedOut]      VARCHAR (13)  NOT NULL,
    [OptInDetails]  VARCHAR (255) NULL,
    [EmailType]     VARCHAR (4)   NOT NULL,
    [OptedOutDate]  DATETIME      NULL,
    [OptOutDetails] VARCHAR (255) NULL,
    [LoadDate]      DATE          NULL,
    [Archived]      BIT           NULL,
    [ArchivedDate]  DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [EmailMasterSuppression]
    ON [Production].[SPMasterSuppressionList]([Email] ASC);

