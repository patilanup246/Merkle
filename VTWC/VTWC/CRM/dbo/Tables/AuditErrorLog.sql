CREATE TABLE [dbo].[AuditErrorLog] (
    [ErrorLogKey]          INT             IDENTITY (1, 1) NOT NULL,
    [PkgExecKey]           INT             NOT NULL,
    [FeedFileKey]          INT             NOT NULL,
    [LineNumber]           BIGINT          NULL,
    [ErrorCode]            INT             NULL,
    [ValidationAction]     CHAR (1)        NULL,
    [SourceColumnName]     VARCHAR (255)   NULL,
    [TargetTable]          VARCHAR (150)   NULL,
    [TargetColumnDataType] VARCHAR (20)    NULL,
    [TargetColumnLength]   INT             NULL,
    [Occurred]             DATETIME        NULL,
    [Description]          VARCHAR (255)   NULL,
    [SourceColumnData]     NVARCHAR (4000) NULL,
    [DateCreated]          DATETIME        DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_AuditErrorLog] PRIMARY KEY CLUSTERED ([ErrorLogKey] ASC),
    CONSTRAINT [FK_AuditErrorLog_FeedFileKey] FOREIGN KEY ([FeedFileKey]) REFERENCES [dbo].[AuditFeedFile] ([FeedFileKey]),
    CONSTRAINT [FK_AuditErrorLog_PkgExecKey] FOREIGN KEY ([PkgExecKey]) REFERENCES [dbo].[AuditPkgExecution] ([PkgExecKey])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was inserted into the database.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'SourceColumnData';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The data that caused the error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'SourceColumnData';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Source Column Data', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'SourceColumnData';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The description of the error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Description', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'Occurred';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time when this error occurred', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'Occurred';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Occurred', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'Occurred';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'TargetColumnLength';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The length of the column where the data was supposed to go', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'TargetColumnLength';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Target Column Length', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'TargetColumnLength';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'TargetColumnDataType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The data type of the column where the data was supposed to go', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'TargetColumnDataType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Target Column Data Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'TargetColumnDataType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Destination table or the entity insert table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'TargetTable';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Target Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'TargetTable';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'SourceColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Name of the column where the error occurred.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'SourceColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Source Column Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'SourceColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Validation Action applied to the record. Only the top level of the action hierarchy will be recorded here. F=File rejected; R=Record rejected;E=Entity (customer) rejected;U=Update action performed;B=Blanking action performed;W=Warning raised. Records with actions F,R & E will not be loaded.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'ValidationAction';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Validation Action', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'ValidationAction';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Error Code that occurred at the line', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorCode';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Error Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorCode';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'LineNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Line of which the error occurred', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'LineNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Line Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'LineNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to AuditFeedFile', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditFeedFile.FeedFileKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Feed File Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to AuditPkgExecution', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditPkgExecution.PkgExecKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Pkg Exec Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorLogKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorLogKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorLogKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Error Log Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorLogKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Audit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Receives one or more rows each time a row errors in a package', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AuditErrorLog', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditErrorLog';

