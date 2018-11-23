CREATE TABLE [dbo].[AuditLog] (
    [AuditLogID]      INT           IDENTITY (1, 1) NOT NULL,
    [AuditTypeCode]   VARCHAR (2)   NOT NULL,
    [Server]          VARCHAR (128) NULL,
    [DatabaseName]    VARCHAR (128) NULL,
    [Process]         VARCHAR (128) NULL,
    [Step]            VARCHAR (128) NULL,
    [FileName]        VARCHAR (128) NULL,
    [Message]         VARCHAR (512) NULL,
    [CodeExecuted]    VARCHAR (MAX) NULL,
    [Rows]            INT           NULL,
    [AuditStartTime]  DATETIME      DEFAULT (getdate()) NOT NULL,
    [AuditEndTime]    DATETIME      NULL,
    [DurationSeconds] AS            (datediff(second,[AuditStartTime],[AuditEndTime])),
    [DurationTime]    AS            (case when [AuditTypeCode]='T' OR [AuditTypeCode]='TE' OR [AuditTypeCode]='PE' then '' when datediff(second,[AuditStartTime],[AuditEndTime]) IS NULL then ((((CONVERT([varchar](6),datediff(second,[AuditStartTime],getdate())/(3600))+':')+right('0'+CONVERT([varchar](2),(datediff(second,[AuditStartTime],getdate())%(3600))/(60)),(2)))+':')+right('0'+CONVERT([varchar](2),datediff(second,[AuditStartTime],getdate())%(60)),(2)))+'E' else (((CONVERT([varchar](6),datediff(second,[AuditStartTime],[AuditEndTime])/(3600))+':')+right('0'+CONVERT([varchar](2),(datediff(second,[AuditStartTime],[AuditEndTime])%(3600))/(60)),(2)))+':')+right('0'+CONVERT([varchar](2),datediff(second,[AuditStartTime],[AuditEndTime])%(60)),(2)) end),
    [ParentLogID]     INT           NULL,
    [SPID]            INT           DEFAULT (@@spid) NULL,
    [UserLogin]       [sysname]     DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED ([AuditLogID] ASC),
    CONSTRAINT [FK_AuditLog_AuditTypeCode] FOREIGN KEY ([AuditTypeCode]) REFERENCES [dbo].[LkupAuditType] ([AuditTypeCode])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The login or username or the process making the call.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'UserLogin';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'User Login', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'UserLogin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The SPID of the process making the call', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'SPID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SPID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'SPID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Parent Log ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'ParentLogID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A calculated time in HH:MM format. This is suffixed with E when step has not finished.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'DurationTime';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Duration Time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'DurationTime';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Duration Seconds', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'DurationSeconds';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit End Time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditEndTime';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit Start Time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditStartTime';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Rows', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Rows';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Code Executed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'CodeExecuted';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Message', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Message';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the file, if the event relates to an action being performed on a file.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'For large or complex processes Step can be used to identify a particular action within a process.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Step', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the process that raised the event.  E.g. the stored procedure name.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Process';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Process', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Process';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the database that raised the event.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'DatabaseName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Database Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'DatabaseName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the server or system that raised the event.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Server';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Server', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'Server';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code representing the audit type. FK to LkupAuditType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditTypeCode';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'LkupAuditType.AuditTypeCode', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditTypeCode';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit Type Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditTypeCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identity column and parent key for sub-processes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditLogID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Audit Log ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog', @level2type = N'COLUMN', @level2name = N'AuditLogID';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Audit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table stores one row for each start, trace or end event and is used for logging SQL activity.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AuditLog', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditLog';

