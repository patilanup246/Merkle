﻿CREATE TABLE [Operations].[DataImportDetail] (
    [DataImportDetailID]        INT            IDENTITY (1, 1) NOT NULL,
    [Name]                      NVARCHAR (256) NOT NULL,
    [Description]               NVARCHAR (MAX) NULL,
    [CreatedDate]               DATETIME       NOT NULL,
    [CreatedBy]                 INT            NOT NULL,
    [LastModifiedDate]          DATETIME       NOT NULL,
    [LastModifiedBy]            INT            NOT NULL,
    [ArchivedInd]               BIT            DEFAULT ((0)) NOT NULL,
    [DataImportLogID]           INT            NOT NULL,
    [DataImportDefinitionID]    INT            NOT NULL,
    [OperationalStatusID]       INT            NOT NULL,
    [ImportFileName]            NVARCHAR (256) NOT NULL,
    [ProcessingOrder]           INT            NOT NULL,
    [DestinationTable]          NVARCHAR (256) NOT NULL,
    [QueryFileName]             NVARCHAR (256) NULL,
    [QueryDefinition]           NVARCHAR (MAX) NULL,
    [StartTimePreprocessing]    DATETIME       NULL,
    [EndTimePreprocessing]      DATETIME       NULL,
    [StartTimeImport]           DATETIME       NULL,
    [EndTimeImport]             DATETIME       NULL,
    [TotalCountPreprocessing]   INT            NULL,
    [SuccessCountPreprocessing] INT            NULL,
    [ErrorCountPreprocessing]   INT            NULL,
    [TotalCountImport]          INT            NULL,
    [SuccessCountImport]        INT            NULL,
    [ErrorCountImport]          INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_DataImportDetail] PRIMARY KEY CLUSTERED ([DataImportDetailID] ASC),
    CONSTRAINT [FK_DataImportDetail_DataImportDefinitionID] FOREIGN KEY ([DataImportDefinitionID]) REFERENCES [Reference].[DataImportDefinition] ([DataImportDefinitionID]),
    CONSTRAINT [FK_DataImportDetail_DataImportLogID] FOREIGN KEY ([DataImportLogID]) REFERENCES [Operations].[DataImportLog] ([DataImportLogID]),
    CONSTRAINT [FK_DataImportDetail_OperationalStatusID] FOREIGN KEY ([OperationalStatusID]) REFERENCES [Reference].[OperationalStatus] ([OperationalStatusID])
);

