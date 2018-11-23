CREATE TABLE [dat_dtv].[AuditFeedFile] (
    [FeedFileKey]   INT           IDENTITY (1, 1) NOT NULL,
    [PkgExecKey]    VARCHAR (50)  NOT NULL,
    [SourceFolder]  VARCHAR (255) NOT NULL,
    [ProcessFolder] VARCHAR (255) NOT NULL,
    [RowData]       VARCHAR (100) NOT NULL,
    [ProcessedDate] DATETIME      CONSTRAINT [DF__AuditFeed__Proce__37A5467C] DEFAULT (getdate()) NOT NULL,
    [FileName]      VARCHAR (50)  NOT NULL,
    [FileSizeBytes] BIGINT        NOT NULL,
    [CreateDate]    DATETIME      NOT NULL,
    [FileStatus]    VARCHAR (15)  DEFAULT ('Unknown') NOT NULL,
    [Archived]      BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AuditFeedFile] PRIMARY KEY CLUSTERED ([FeedFileKey] ASC) WITH (FILLFACTOR = 80)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the file was moved to the Process folder by Production.  This is the date/time production processing finished.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Processed Date', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the feed file that was received.  This file name may be changed by the receipt process if a file with the same name has already been archived.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'RowData';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Original File Name', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'RowData';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The folder where the file was delivered to by the Production process.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessFolder';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Process Folder', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessFolder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The folder where the file was picked up from by the Production process.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'SourceFolder';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Source Folder', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'SourceFolder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to AuditPkgExecution.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditPkgExecution.PkgExecKey', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Pkg Exec Key', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Feed File Key', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Audit', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Receives a row for each Feed file processed.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AuditFeedFile', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditFeedFile';

