CREATE TABLE [SECURITY].[Roles] (
    [RoleID]           INT            NOT NULL,
    [Name]             NVARCHAR (50)  NOT NULL,
    [Description]      NVARCHAR (512) NULL,
    [CreatedDate]      DATETIME       DEFAULT (getdate()) NULL,
    [CreatedBy]        INT            NOT NULL,
    [LastModifiedDate] DATETIME       DEFAULT (getdate()) NULL,
    [LastModifiedBy]   INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([RoleID] ASC)
);
GO

CREATE NONCLUSTERED INDEX [SecurityRolesName]
    ON [SECURITY].[Roles]([Name] ASC);
GO


EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique role identifier',
    @level0type = N'SCHEMA',
    @level0name = N'SECURITY',
    @level1type = N'TABLE',
    @level1name = N'Roles',
    @level2type = N'COLUMN',
    @level2name = N'RoleID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Role name',
    @level0type = N'SCHEMA',
    @level0name = N'SECURITY',
    @level1type = N'TABLE',
    @level1name = N'Roles',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Role long description',
    @level0type = N'SCHEMA',
    @level0name = N'SECURITY',
    @level1type = N'TABLE',
    @level1name = N'Roles',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When this row was created',
    @level0type = N'SCHEMA',
    @level0name = N'SECURITY',
    @level1type = N'TABLE',
    @level1name = N'Roles',
    @level2type = N'COLUMN',
    @level2name = N'CreatedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Who has created this row',
    @level0type = N'SCHEMA',
    @level0name = N'SECURITY',
    @level1type = N'TABLE',
    @level1name = N'Roles',
    @level2type = N'COLUMN',
    @level2name = N'CreatedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When this row was modified',
    @level0type = N'SCHEMA',
    @level0name = N'SECURITY',
    @level1type = N'TABLE',
    @level1name = N'Roles',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Who has modified this row',
    @level0type = N'SCHEMA',
    @level0name = N'SECURITY',
    @level1type = N'TABLE',
    @level1name = N'Roles',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedBy'