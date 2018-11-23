CREATE TABLE [dat_dtv].[AuditLog] (
    [AuditLogID]     INT           IDENTITY (1, 1) NOT NULL,
    [Process]        VARCHAR (128) NULL,
    [Step]           VARCHAR (128) NULL,
    [FileName]       VARCHAR (128) NULL,
    [AuditStartTime] DATETIME      DEFAULT (getdate()) NOT NULL,
    [AuditEndTime]   DATETIME      NULL,
    [UserLogin]      [sysname]     DEFAULT (suser_sname()) NULL,
    [PkgExecKey]     VARCHAR (50)  NULL,
    CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED ([AuditLogID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The login or username or the process making the call.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'UserLogin';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'User Login', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'UserLogin';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit End Time', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditEndTime';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit Start Time', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditStartTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the file, if the event relates to an action being performed on a file.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Name', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'For large or complex processes Step can be used to identify a particular action within a process.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Step', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the process that raised the event.  E.g. the stored procedure name.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Process';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Process', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Process';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identity column and parent key for sub-processes.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditLogID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1,2,3', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditLogID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit Log ID', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditLogID';


GO
EXECUTE sp_addextendedproperty @name = N'View Name', @value = N'vwAuditLog', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Audit', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table stores one row for each start, trace or end event and is used for logging SQL activity.', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AuditLog', @level0type = N'SCHEMA', @level0name = N'dat_dtv', @level1type = N'TABLE', @level1name = N'AuditLog';

