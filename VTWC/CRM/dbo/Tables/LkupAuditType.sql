CREATE TABLE [dbo].[LkupAuditType] (
    [AuditTypeCode]          VARCHAR (2)    NOT NULL,
    [AuditType]              VARCHAR (32)   NOT NULL,
    [AuditTypeDescription]   VARCHAR (1023) NULL,
    [ShowInExceptionsReport] CHAR (1)       DEFAULT ('N') NOT NULL,
    [EventType]              CHAR (1)       DEFAULT ('E') NOT NULL,
    [DateCreated]            DATETIME       DEFAULT (getdate()) NULL,
    [DateUpdated]            DATETIME       DEFAULT (getdate()) NULL,
    [RowChangeOperator]      VARCHAR (20)   NULL,
    CONSTRAINT [PK_LkupAuditType] PRIMARY KEY CLUSTERED ([AuditTypeCode] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the operator that last changed the row.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'RowChangeOperator';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Row Change Operator', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'RowChangeOperator';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was last updated.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Updated', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was inserted into the database.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The type of audit event this is - whether the [s]tart of a process,  [e]nd of a process,  single [e]vent or [c]ompleted process.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'EventType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Event Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'EventType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Whether this Audit Type is showin in the error report.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'ShowInExceptionsReport';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Show In Exceptions Report', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'ShowInExceptionsReport';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Full description of the audit type and what action should be taken.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'AuditTypeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit Type Description', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'AuditTypeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Long name describing the audit type.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'AuditType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'AuditType';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'AuditTypeCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Short code defining the audit type. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'AuditTypeCode';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'E,I,W,P,C', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'AuditTypeCode';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit Type Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType', @level2type = N'COLUMN', @level2name = N'AuditTypeCode';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Lookup', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table stores one row for each audit type.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'LkupAuditType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkupAuditType';

