CREATE TABLE [dat_dtv].[AuditExtractFeedFile] (
    [FeedFileKey]       INT           IDENTITY (1, 1) NOT NULL,
    [PkgExecKey]        VARCHAR (50)  NOT NULL,
    [ExtractFolder]     VARCHAR (255) NOT NULL,
    [DestinationFolder] VARCHAR (255) NOT NULL,
    [FileName]          VARCHAR (100) NOT NULL,
    [FileStatus]        VARCHAR (50)  NOT NULL,
    [LastUpdateDate]    DATETIME      DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_AuditExtractFeedFile] PRIMARY KEY CLUSTERED ([FeedFileKey] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the feed file that was received.  This file name may be changed by the receipt process if a file with the same name has already been archived.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Original File Name', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to AuditPkgExecution.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditPkgExecution.PkgExecKey', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Pkg Exec Key', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Feed File Key', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Audit', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Receives a row for each Feed file processed.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AuditExtractFeedFile', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditExtractFeedFile';

