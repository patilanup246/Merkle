CREATE TABLE [dbo].[dbgConfigurationParameters] (
    [ConfigurationParameterID] INT           IDENTITY (1, 1) NOT NULL,
    [Parameter]                VARCHAR (50)  NOT NULL,
    [Description]              VARCHAR (500) NULL,
    [Value]                    VARCHAR (500) NULL,
    [DataType]                 VARCHAR (20)  NULL,
    [ActiveFrom]               SMALLDATETIME NULL,
    [ActiveTo]                 SMALLDATETIME NULL,
    [IsActive]                 AS            (case when getdate()>=[ActiveFrom] AND getdate()<=[ActiveTo] then (1) else (0) end),
    [DateCreated]              DATETIME      DEFAULT (getdate()) NULL,
    [DateUpdated]              DATETIME      DEFAULT (getdate()) NULL,
    [RowChangeReason]          CHAR (1)      NULL,
    [RowChangeOperator]        VARCHAR (20)  NULL,
    CONSTRAINT [PK_dbgConfigurationParameters] PRIMARY KEY CLUSTERED ([ConfigurationParameterID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the operator that last changed the row.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'RowChangeOperator';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Row Change Operator', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'RowChangeOperator';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Was this row last changed by the [E]TL process [T]ouchpoint, [M] Manual', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'RowChangeReason';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Row Change Reason', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'RowChangeReason';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was last updated.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Updated', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was inserted into the database.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Computed column indicating whether the configuration is currently active.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'IsActive';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Is Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'IsActive';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date the configuration ceases to be active.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'ActiveTo';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Active To', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'ActiveTo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date the configuration becomes active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'ActiveFrom';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Active From', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'ActiveFrom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Used to validate the value is of a particular datatype. Date (YYYYMMDD), Datetime (YYYYMMDD HH:MM), Int, Numeric, Text', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'DataType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Data Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'DataType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Holds the parameter value. Sometimes this will be cleared during data processing', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'Value';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'Value';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Describes the parameter and its use', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Description', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The parameter name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'Parameter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Parameter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'Parameter';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'ConfigurationParameterID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Configuration Parameter ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters', @level2type = N'COLUMN', @level2name = N'ConfigurationParameterID';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'List of schemas using this table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Work', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Holds configuration options', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'dbgConfigurationParameters', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'dbgConfigurationParameters';

