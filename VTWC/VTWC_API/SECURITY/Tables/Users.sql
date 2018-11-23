CREATE TABLE [SECURITY].[Users] (
    [UserIdentity]     NVARCHAR (50)  NOT NULL,
    [Password]         NVARCHAR (512) NOT NULL,
    [RoleID]           INT            NULL,
    [CreatedDate]      DATETIME       DEFAULT (getdate()) NULL,
    [CreatedBy]        INT            NOT NULL,
    [LastModifiedDate] DATETIME       DEFAULT (getdate()) NULL,
    [LastModifiedBy]   INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([UserIdentity] ASC),
    CONSTRAINT [FK_UsersRoles] FOREIGN KEY ([RoleID]) REFERENCES [SECURITY].[Roles] ([RoleID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'API user name used to get a token', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'UserIdentity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Encrypted password', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'Password';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date when this row was created', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date when this row was updated', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has updated this row', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';

