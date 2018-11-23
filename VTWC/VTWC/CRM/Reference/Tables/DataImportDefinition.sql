CREATE TABLE [Reference].[DataImportDefinition] (
    [DataImportDefinitionID] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                   NVARCHAR (256) NOT NULL,
    [Description]            NVARCHAR (MAX) NULL,
    [CreatedDate]            DATETIME       NOT NULL,
    [CreatedBy]              INT            NOT NULL,
    [LastModifiedDate]       DATETIME       NOT NULL,
    [LastModifiedBy]         INT            NOT NULL,
    [ArchivedInd]            BIT            DEFAULT ((0)) NOT NULL,
    [DataImportTypeID]       INT            NOT NULL,
    [QueryTemplate]          NVARCHAR (256) NULL,
    [ProcessingOrder]        INT            NOT NULL,
    [MaxBatchSize]           INT            NULL,
    [DestinationTable]       NVARCHAR (256) NULL,
    [QueryDefinition]        NVARCHAR (MAX) NULL,
    [TypeCode]               NVARCHAR (256) NULL,
    [SubQueryDefinition]     NVARCHAR (MAX) NULL,
    [LocalCopyInd]           BIT            CONSTRAINT [DF_DataDefinition_LocalCopyInd] DEFAULT ((0)) NULL,
    CONSTRAINT [cndx_PrimaryKey_DataImportDefinition] PRIMARY KEY CLUSTERED ([DataImportDefinitionID] ASC),
    CONSTRAINT [FK_DataImportDefinition_DataImportTypeID] FOREIGN KEY ([DataImportTypeID]) REFERENCES [Reference].[DataImportType] ([DataImportTypeID])
);

