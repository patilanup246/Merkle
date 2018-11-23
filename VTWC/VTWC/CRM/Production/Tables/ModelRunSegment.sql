CREATE TABLE [Production].[ModelRunSegment] (
    [ModelRunSegmentID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (256)  NOT NULL,
    [Description]       NVARCHAR (4000) NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [CreatedBy]         INT             NOT NULL,
    [LastModifiedDate]  DATETIME        NOT NULL,
    [LastModifiedBy]    INT             NOT NULL,
    [ArchivedInd]       BIT             DEFAULT ((0)) NOT NULL,
    [ModelDefinitionID] INT             NOT NULL,
    [ModelSegmentID]    INT             NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_ModelRunSegment] PRIMARY KEY CLUSTERED ([ModelRunSegmentID] ASC),
    CONSTRAINT [FK_ModelRunSegment_ModelDefinitionID] FOREIGN KEY ([ModelDefinitionID]) REFERENCES [Reference].[ModelDefinition] ([ModelDefinitionID]),
    CONSTRAINT [FK_ModelRunSegment_ModelSegmentID] FOREIGN KEY ([ModelSegmentID]) REFERENCES [Reference].[ModelSegment] ([ModelSegmentID])
);

