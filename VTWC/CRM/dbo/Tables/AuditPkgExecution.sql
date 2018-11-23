CREATE TABLE [dbo].[AuditPkgExecution] (
    [PkgExecKey]       INT              IDENTITY (1, 1) NOT NULL,
    [PkgName]          VARCHAR (50)     NULL,
    [PkgGUID]          UNIQUEIDENTIFIER NULL,
    [PkgVersionGUID]   UNIQUEIDENTIFIER NULL,
    [PkgVersionMajor]  SMALLINT         NULL,
    [PkgVersionMinor]  SMALLINT         NULL,
    [PkgVersionBuild]  SMALLINT         NULL,
    [ExecStartDT]      DATETIME         NULL,
    [ExecStopDT]       DATETIME         NULL,
    [SuccessFlag]      CHAR (1)         NULL,
    [ParentPkgExecKey] INT              DEFAULT ((-1)) NOT NULL,
    [PathFolder]       VARCHAR (255)    NULL,
    [InternalEmailTo]  VARCHAR (8000)   NULL,
    [ExternalEmailTo]  VARCHAR (8000)   NULL,
    [DateCreated]      DATETIME         DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_AuditPkgExecution] PRIMARY KEY CLUSTERED ([PkgExecKey] ASC),
    CONSTRAINT [FK_AuditPkgExecution_ParentPkgExecKey] FOREIGN KEY ([ParentPkgExecKey]) REFERENCES [dbo].[AuditPkgExecution] ([PkgExecKey])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was inserted into the database.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The email address(es) of the external recipients. Passed from SSIS execution', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ExternalEmailTo';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'External Email To', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ExternalEmailTo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The email address(es) of the internal recipients. Passed from SSIS execution', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'InternalEmailTo';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Internal Email To', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'InternalEmailTo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The root folder path that the for this package execution. Passed from SSIS execution', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PathFolder';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Path Folder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PathFolder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Link to the row for the master package execution that called this package', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ParentPkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditPkgExecution.PkgExecKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ParentPkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ParentPkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Parent Package Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ParentPkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Did package execution complete without error?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Y, N', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Sucess Flag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datetime package execution ended', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ExecStopDT';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Execution Finish Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ExecStopDT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datetime package execution began', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ExecStartDT';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Execution Start Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'ExecStartDT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Package build version', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionBuild';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionBuild';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Package Version Build', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionBuild';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Package minor version', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionMinor';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionMinor';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Package Version Minor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionMinor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Package major version', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionMajor';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionMajor';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Package Version Major', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionMajor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Package version GUID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionGUID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Package Version GUID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgVersionGUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GUID for the package', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgGUID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Package GUID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgGUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the package', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgName';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Dim_Product_ETL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Package Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgName';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Pkg Exec Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Audit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Receives a row each time an Integration Services package is executed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AuditPkgExecution', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditPkgExecution';

