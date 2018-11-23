CREATE TABLE [dbo].[AuditTableProcessing] (
    [TableProcessKey]    INT          IDENTITY (1, 1) NOT NULL,
    [PkgExecKey]         INT          NOT NULL,
    [FeedFileKey]        INT          NOT NULL,
    [TableName]          VARCHAR (50) NULL,
    [InsertStdRowCnt]    INT          NULL,
    [UpdateRowCnt]       INT          NULL,
    [ErrorRowCnt]        INT          NULL,
    [NoChangeCnt]        INT          NULL,
    [DuplicateBKCnt]     INT          NULL,
    [TableInitialRowCnt] INT          NULL,
    [TableFinalRowCnt]   INT          NULL,
    [SuccessFlag]        CHAR (1)     NULL,
    [ShowInLoadReport]   CHAR (1)     DEFAULT ('N') NULL,
    [DateCreated]        DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_AuditTableProcessing] PRIMARY KEY CLUSTERED ([TableProcessKey] ASC),
    CONSTRAINT [FK_AuditTableProcessing_FeedFileKey] FOREIGN KEY ([FeedFileKey]) REFERENCES [dbo].[AuditFeedFile] ([FeedFileKey]),
    CONSTRAINT [FK_AuditTableProcessing_PkgExecKey] FOREIGN KEY ([PkgExecKey]) REFERENCES [dbo].[AuditPkgExecution] ([PkgExecKey])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was inserted into the database.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'ShowInLoadReport';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Should this audit row be shown in the standard Data Load Summary report?  One of ''Y''=Yes or ''N''=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'ShowInLoadReport';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Y, N', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'ShowInLoadReport';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Show In Load Report', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'ShowInLoadReport';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Did this table finish processing successfully?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Y, N', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'ETL Rules', @value = N'Standard SCD-2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Success Flag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableFinalRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Final row count of target table, post processing', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableFinalRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Table Final Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableFinalRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableInitialRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Initial row count of target table, pre-processing', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableInitialRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Table Initial Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableInitialRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A count of the number of rows in the data flow where there are duplicate Business Keys.  The total number of rows inserted into the table will be reduced by this count.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'DuplicateBKCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Duplicate BK Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'DuplicateBKCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A count of the number of rows in the data flow that resulted in no changes being applied to the data warehouse table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'NoChangeCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'No Change Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'NoChangeCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'ErrorRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Count of error rows not inserted into table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'ErrorRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Error Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'ErrorRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'UpdateRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Count of rows updated in target table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'UpdateRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Update Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'UpdateRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'InsertStdRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Count of rows inserted into target using standard processing', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'InsertStdRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Insert Std Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'InsertStdRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Table Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Table Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to AuditFeedFile', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditFeedFile.FeedFileKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Feed File Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to AuditPkgExecution', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditPkgExecution.PkgExecKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Pkg Exec Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableProcessKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableProcessKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableProcessKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Table Processing Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing', @level2type = N'COLUMN', @level2name = N'TableProcessKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Audit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Receives a row each time a table is processed in a package', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AuditTableProcessing', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTableProcessing';

