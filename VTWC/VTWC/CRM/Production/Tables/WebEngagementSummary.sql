CREATE TABLE [Production].[WebEngagementSummary] (
    [ID]                  BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate]         DATETIME DEFAULT (getdate()) NOT NULL,
    [CreatedBy]           INT      NULL,
    [LastModifiedDate]    DATETIME DEFAULT (getdate()) NOT NULL,
    [LastModifiedBy]      INT      NULL,
    [ArchivedInd]         INT      DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT      NULL,
    [IndividualID]        INT      NULL,
    [CustomerID]          INT      NULL,
    [PageViewsLast1Days]  INT      NULL,
    [PageViewsLast3Days]  INT      NULL,
    [PageViewsLast5Days]  INT      NULL,
    [SearchesLast1Days]   INT      NULL,
    [SearchesLast3Days]   INT      NULL,
    [SearchesLast5Days]   INT      NULL,
    CONSTRAINT [PK_WebEngagementSummary] PRIMARY KEY CLUSTERED ([ID] ASC)
);

