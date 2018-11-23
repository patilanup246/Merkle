
GO
CREATE TABLE Security.RolesEndpoints
( RoleID INT NOT NULL,
  EndpointID INT NOT NULL,
  CreatedDate DATETIME DEFAULT GETDATE() NOT NULL,
  CreatedBy INT NOT NULL,
  LastModifiedDate DATETIME DEFAULT GETDATE() NOT NULL,
  LastModifiedBy INT NOT NULL,
  CONSTRAINT PK_RolesEndpoints PRIMARY KEY (RoleID, EndpointID),
  CONSTRAINT FK_RolesEndpoints_Roles FOREIGN KEY (RoleID)     
    REFERENCES [Security].Roles (RoleID)     
    ON DELETE CASCADE    
    ON UPDATE NO ACTION,
  CONSTRAINT FK_RolesEndpoints_Endpoints FOREIGN KEY (EndpointID)     
    REFERENCES [Security].[Endpoints] (EndpointID)     
    ON DELETE CASCADE    
    ON UPDATE NO ACTION)  
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Foreign key to Security.Roles',
    @level0type = N'SCHEMA',
    @level0name = N'Security',
    @level1type = N'TABLE',
    @level1name = N'RolesEndpoints',
    @level2type = N'COLUMN',
    @level2name = N'RoleID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Foreign key to Security.Endpoints',
    @level0type = N'SCHEMA',
    @level0name = N'Security',
    @level1type = N'TABLE',
    @level1name = N'RolesEndpoints',
    @level2type = N'COLUMN',
    @level2name = N'EndpointID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When this row was created.',
    @level0type = N'SCHEMA',
    @level0name = N'Security',
    @level1type = N'TABLE',
    @level1name = N'RolesEndpoints',
    @level2type = N'COLUMN',
    @level2name = N'CreatedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Who has created this row',
    @level0type = N'SCHEMA',
    @level0name = N'Security',
    @level1type = N'TABLE',
    @level1name = N'RolesEndpoints',
    @level2type = N'COLUMN',
    @level2name = N'CreatedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When this row was updated',
    @level0type = N'SCHEMA',
    @level0name = N'Security',
    @level1type = N'TABLE',
    @level1name = N'RolesEndpoints',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Who has updated this row',
    @level0type = N'SCHEMA',
    @level0name = N'Security',
    @level1type = N'TABLE',
    @level1name = N'RolesEndpoints',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedBy'