CREATE TABLE [dbo].[DimAudit] (
    [AuditKey]               INT           IDENTITY (1, 1) NOT NULL,
    [TableProcessKey]        INT           NOT NULL,
    [BranchName]             VARCHAR (50)  NULL,
    [BranchRowCnt]           INT           NULL,
    [InsertRowCnt]           INT           NULL,
    [UpdateRowCnt]           INT           NULL,
    [ErrorRowCnt]            INT           NULL,
    [GoodRowCnt]             INT           NULL,
    [NoChangeCnt]            AS            ((isnull([GoodRowCnt],(0))-isnull([InsertRowCnt],(0)))-isnull([UpdateRowCnt],(0))),
    [ProcessingSummaryGroup] VARCHAR (200) DEFAULT ('Normal') NULL,
    [DateCreated]            DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DimAudit] PRIMARY KEY CLUSTERED ([AuditKey] ASC),
    CONSTRAINT [FK_DimAudit_TableProcessKey] FOREIGN KEY ([TableProcessKey]) REFERENCES [dbo].[AuditTableProcessing] ([TableProcessKey])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was inserted into the database.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The type of processing for this branch. One of ''Normal'', ''Inferred'' or ''Attribute''.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'ProcessingSummaryGroup';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Processing Summary Group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'ProcessingSummaryGroup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Count of rows that were supplied in the feed file, but did not cause an update because the supplied data was identical to that already in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'NoChangeCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'No Change Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'NoChangeCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Good Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'GoodRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Error Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'ErrorRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Count of rows updated in the associated table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'UpdateRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Update Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'UpdateRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Count of rows inserted into the associated table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'InsertRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Insert Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'InsertRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Count of rows added/updated in this package branch', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'BranchRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Branch Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'BranchRowCnt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name supplied by the ETL developer for branch that adds / updates data in the target table.  Typically this is the table name.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'BranchName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Branch Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'BranchName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to AuditTableProcessing', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'TableProcessKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditTableProcessing.TableProcessKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'TableProcessKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Table Process Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'TableProcessKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'AuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'AuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'AuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit', @level2type = N'COLUMN', @level2name = N'AuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Dimension', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit dimension tags each data row with the the process that added or updated it.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'DimAudit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimAudit';

