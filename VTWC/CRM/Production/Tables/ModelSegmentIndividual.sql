CREATE TABLE [Production].[ModelSegmentIndividual] (
    [ModelSegmentIndividualID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]                     NVARCHAR (256)  NOT NULL,
    [Description]              NVARCHAR (4000) NULL,
    [CreatedDate]              DATETIME        NOT NULL,
    [CreatedBy]                INT             NOT NULL,
    [LastModifiedDate]         DATETIME        NOT NULL,
    [LastModifiedBy]           INT             NOT NULL,
    [ArchivedInd]              BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID]      INT             NOT NULL,
    [IndividualID]             INT             NOT NULL,
    [ModelSegmentID]           INT             NOT NULL,
    [ModelRunID]               INT             NOT NULL,
    [Score]                    DECIMAL (14, 2) NULL,
    [RSID]                     NVARCHAR (256)  NULL,
    [TravelDate]               DATETIME        NULL,
    CONSTRAINT [cndx_PrimaryKey_ModelSegmentIndividual] PRIMARY KEY CLUSTERED ([ModelSegmentIndividualID] ASC),
    CONSTRAINT [FK_ModelSegmentIndividual_IndividualID] FOREIGN KEY ([IndividualID]) REFERENCES [Staging].[STG_Individual] ([IndividualID]),
    CONSTRAINT [FK_ModelSegmentIndividual_ModelRunID] FOREIGN KEY ([ModelRunID]) REFERENCES [Production].[ModelRun] ([ModelRunID]),
    CONSTRAINT [FK_ModelSegmentIndividual_ModelSegmentID] FOREIGN KEY ([ModelSegmentID]) REFERENCES [Reference].[ModelSegment] ([ModelSegmentID])
);

