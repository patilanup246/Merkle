CREATE TABLE [dbo].[DimTime] (
    [TimeKey]           SMALLINT     NOT NULL,
    [TheTime]           AS           (CONVERT([time],[TimeString24])),
    [TimeString24]      CHAR (5)     NULL,
    [TimeString12]      CHAR (5)     NULL,
    [HourOfDay24]       TINYINT      NULL,
    [HourOfDay12]       TINYINT      NULL,
    [AmPm]              CHAR (2)     NULL,
    [MinuteOfHour]      TINYINT      NULL,
    [HalfOfHour]        TINYINT      NULL,
    [HalfHourOfDay]     TINYINT      NULL,
    [QuarterOfHour]     TINYINT      NULL,
    [QuarterHourOfDay]  TINYINT      NULL,
    [PeriodOfDay]       VARCHAR (10) NULL,
    [DateCreated]       DATETIME     DEFAULT (getdate()) NULL,
    [DateUpdated]       DATETIME     DEFAULT (getdate()) NULL,
    [RowIsCurrent]      CHAR (1)     DEFAULT ('Y') NULL,
    [RowStartDate]      DATETIME     DEFAULT (getdate()) NULL,
    [RowEndDate]        DATETIME     DEFAULT ('99991231') NULL,
    [RowChangeReason]   CHAR (1)     DEFAULT ('E') NULL,
    [RowChangeOperator] VARCHAR (20) NULL,
    [InsertAuditKey]    INT          NOT NULL,
    [UpdateAuditKey]    INT          NOT NULL,
    CONSTRAINT [PK_DimTime] PRIMARY KEY CLUSTERED ([TimeKey] ASC),
    CONSTRAINT [FK_DimTime_InsertAuditKey] FOREIGN KEY ([InsertAuditKey]) REFERENCES [dbo].[DimAudit] ([AuditKey]),
    CONSTRAINT [FK_DimTime_UpdateAuditKey] FOREIGN KEY ([UpdateAuditKey]) REFERENCES [dbo].[DimAudit] ([AuditKey])
);


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'ETL Process', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'UpdateAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Key to Audit dimension for row update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'UpdateAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'DimAudit.AuditKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'UpdateAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'UpdateAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Update Audit Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'UpdateAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'ETL Process', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'InsertAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Key to Audit dimension for row insertion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'InsertAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'DimAudit.AuditKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'InsertAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'InsertAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Insert Audit Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'InsertAuditKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the operator that last changed the row.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowChangeOperator';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Row Change Operator', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowChangeOperator';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived in ETL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowChangeReason';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Was this row last changed by the ''E''TL process or ''T''ouchpoint?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowChangeReason';


GO
EXECUTE sp_addextendedproperty @name = N'ETL Rules', @value = N'Standard SCD-2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowChangeReason';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Row Change Reason', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowChangeReason';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived in ETL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowEndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When did this row become invalid? (12/31/9999 if current row)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowEndDate';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'99991231', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowEndDate';


GO
EXECUTE sp_addextendedproperty @name = N'ETL Rules', @value = N'Standard SCD-2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowEndDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Row End Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowEndDate';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived in ETL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When did this row become valid for this member?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'39742', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'ETL Rules', @value = N'Standard SCD-2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Row Start Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived in ETL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowIsCurrent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is this the current row for this member (Y/N)?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowIsCurrent';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Y, N', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowIsCurrent';


GO
EXECUTE sp_addextendedproperty @name = N'ETL Rules', @value = N'Standard SCD-2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowIsCurrent';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Row Is Current', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'RowIsCurrent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was last updated.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Updated', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was inserted into the database.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Period of the day (Morning, Afternoon, Evening, Night)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'PeriodOfDay';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'PeriodOfDay', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'PeriodOfDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Quater hour for the entire day (1-96)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'QuarterHourOfDay';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'QuarterHourOfDay', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'QuarterHourOfDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'First, second, third, fourth quater of the hour (1-4)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'QuarterOfHour';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'QuarterOfHour', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'QuarterOfHour';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Half hour for the entire day (1-48)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'HalfHourOfDay';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'HalfHourOfDay', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'HalfHourOfDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'First or second half of the hour (1-2)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'HalfOfHour';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'HalfOfHour', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'HalfOfHour';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Minute of the hour (0-59)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'MinuteOfHour';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'MinuteOfHour', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'MinuteOfHour';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'AM/PM ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'AmPm';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AmPm ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'AmPm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hour of the day 12 hour clock (1-12)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'HourOfDay12';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'HourOfDay12', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'HourOfDay12';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hour of the day 24 hour clock (0-23)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'HourOfDay24';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'HourOfDay24', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'HourOfDay24';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'12 hour clock representation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TimeString12';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'TimeString12', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TimeString12';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'24 hour clock textual representation ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TimeString24';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'TimeString24', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TimeString24';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The actual Time ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TheTime';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'TheTime', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TheTime';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TimeKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TimeKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TimeKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'TimeKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime', @level2type = N'COLUMN', @level2name = N'TimeKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Dimension', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table holds one row for minute of a single day', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'DimTime', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimTime';

