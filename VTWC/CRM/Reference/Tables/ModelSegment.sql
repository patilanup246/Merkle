CREATE TABLE [Reference].[ModelSegment] (
    [ModelSegmentID]    INT             IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (256)  NOT NULL,
    [Description]       NVARCHAR (4000) NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [CreatedBy]         INT             NOT NULL,
    [LastModifiedDate]  DATETIME        NOT NULL,
    [LastModifiedBy]    INT             NOT NULL,
    [ArchivedInd]       BIT             DEFAULT ((0)) NOT NULL,
    [ModelDefinitionID] INT             NOT NULL,
    [SegmentCode]       NVARCHAR (256)  NOT NULL,
    [ExtReference]      NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_ModelSegment] PRIMARY KEY CLUSTERED ([ModelSegmentID] ASC),
    CONSTRAINT [FK_ModelSegment_ModelDefinitionID] FOREIGN KEY ([ModelDefinitionID]) REFERENCES [Reference].[ModelDefinition] ([ModelDefinitionID])
);

