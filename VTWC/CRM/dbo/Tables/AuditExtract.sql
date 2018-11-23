CREATE TABLE [dbo].[AuditExtract] (
    [ExtractKey]      INT           IDENTITY (1, 1) NOT NULL,
    [PkgExecKey]      INT           NOT NULL,
    [ExtractName]     VARCHAR (50)  NULL,
    [DestinationPath] VARCHAR (255) NULL,
    [FileName]        VARCHAR (50)  NULL,
    [LineCount]       INT           NULL,
    [FileSize]        BIGINT        NULL,
    [LowestKey]       INT           NULL,
    [HighestKey]      INT           NULL,
    [StartDate]       DATETIME      DEFAULT (getdate()) NULL,
    [StopDate]        DATETIME      NULL,
    CONSTRAINT [PK_AuditExtract] PRIMARY KEY CLUSTERED ([ExtractKey] ASC),
    CONSTRAINT [FK_AuditExtract_PkgExecKey] FOREIGN KEY ([PkgExecKey]) REFERENCES [dbo].[AuditPkgExecution] ([PkgExecKey])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the extract finished.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'StopDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Stop Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'StopDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the extract started.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'StartDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Start Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'StartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The highest value of the master surrogate key that has been extracted so far.  This is used with the ExtractName to establish where the next extract should start.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'HighestKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Highest Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'HighestKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The lowest value of the master key that was extracted in the process logged by this row.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'LowestKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Lowest Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'LowestKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The size of the file in bytes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'FileSize';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'FileSize';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of lines contained in the extract file.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'LineCount';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Line Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'LineCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the extract file.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'DestinationPath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The path (without file name) where the extracted file was saved.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'DestinationPath';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Destination Path', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'DestinationPath';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'ExtractName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the extract process.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'ExtractName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Extract Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'ExtractName';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to AuditPkgExecution', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditPkgExecution.PkgExecKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Pkg Exec Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'ExtractKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'ExtractKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'ExtractKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Extract Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract', @level2type = N'COLUMN', @level2name = N'ExtractKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Audit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Receives one row for each extract file created.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AuditExtract', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditExtract';

