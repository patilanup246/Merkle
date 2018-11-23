CREATE TABLE [Operations].[DataImportLog] (
    [DataImportLogID]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256) NOT NULL,
    [Description]         NVARCHAR (MAX) NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [CreatedBy]           INT            NOT NULL,
    [LastModifiedDate]    DATETIME       NOT NULL,
    [LastModifiedBy]      INT            NOT NULL,
    [ArchivedInd]         BIT            DEFAULT ((0)) NOT NULL,
    [DataImportTypeID]    INT            NOT NULL,
    [OperationalStatusID] INT            NOT NULL,
    [ImportStartTime]     DATETIME       NULL,
    [ImportEndTime]       DATETIME       NULL,
    [DateQueryStart]      DATETIME       NULL,
    [DateQueryEnd]        DATETIME       NULL,
    CONSTRAINT [cndx_PrimaryKey_DataImportDefinition] PRIMARY KEY CLUSTERED ([DataImportLogID] ASC),
    CONSTRAINT [FK_DataImportLog_DataImportTypeID] FOREIGN KEY ([DataImportTypeID]) REFERENCES [Reference].[DataImportType] ([DataImportTypeID]),
    CONSTRAINT [FK_DataImportLog_OperationalStatusID] FOREIGN KEY ([OperationalStatusID]) REFERENCES [Reference].[OperationalStatus] ([OperationalStatusID])
);


GO
CREATE NONCLUSTERED INDEX [ix_DataImportLog_QueryStart]
    ON [Operations].[DataImportLog]([DataImportTypeID] ASC, [DateQueryStart] ASC)
    INCLUDE([DataImportLogID]);


GO
CREATE NONCLUSTERED INDEX [ix_DataImportLog_DataImportTypeID]
    ON [Operations].[DataImportLog]([DataImportTypeID] ASC)
    INCLUDE([DateQueryEnd]);

