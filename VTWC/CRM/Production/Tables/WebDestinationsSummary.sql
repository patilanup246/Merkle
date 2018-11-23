CREATE TABLE [Production].[WebDestinationsSummary] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [CreatedDate]         DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]           INT            NULL,
    [LastModifiedDate]    DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastModifiedBy]      INT            NULL,
    [ArchivedInd]         INT            DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT            NULL,
    [IndividualID]        INT            NULL,
    [CustomerID]          INT            NULL,
    [RankLast1Days]       INT            NULL,
    [RankLast3Days]       INT            NULL,
    [RankLast5Days]       INT            NULL,
    [DestinationNLC]      NVARCHAR (256) NULL,
    CONSTRAINT [PK_WebDestinationsSummary] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [WebDest_Customer]
    ON [Production].[WebDestinationsSummary]([CustomerID] ASC);

