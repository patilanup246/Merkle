CREATE TABLE [Production].[ModelRun] (
    [ModelRunID]        INT             IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (256)  NOT NULL,
    [Description]       NVARCHAR (4000) NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [CreatedBy]         INT             NOT NULL,
    [LastModifiedDate]  DATETIME        NOT NULL,
    [LastModifiedBy]    INT             NOT NULL,
    [ArchivedInd]       BIT             DEFAULT ((0)) NOT NULL,
    [ModelDefinitionID] INT             NOT NULL,
    [ExecutionDate]     DATETIME        NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_ModelRun] PRIMARY KEY CLUSTERED ([ModelRunID] ASC),
    CONSTRAINT [FK_ModelRun_ModelDefinitionID] FOREIGN KEY ([ModelDefinitionID]) REFERENCES [Reference].[ModelDefinition] ([ModelDefinitionID])
);

