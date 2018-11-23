CREATE TABLE [SECURITY].[Endpoints] (
    [EndpointID]       INT             NOT NULL,
    [ResourcePath]     NVARCHAR (1024) NOT NULL,
    [HttpMethod]       NVARCHAR (10)   NOT NULL,
    [Description]      NVARCHAR (512)  NULL,
    [CreatedDate]      DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        INT             NOT NULL,
    [LastModifiedDate] DATETIME        DEFAULT (getdate()) NOT NULL,
    [LastModifiedBy]   INT             NOT NULL,
    PRIMARY KEY CLUSTERED ([EndpointID] ASC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [SecurityEndpoints]
    ON [SECURITY].[Endpoints]([ResourcePath] ASC);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Endpoints', @level2type = N'COLUMN', @level2name = N'CreatedBy';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was created', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Endpoints', @level2type = N'COLUMN', @level2name = N'CreatedDate';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Describes what this endpoint does', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Endpoints', @level2type = N'COLUMN', @level2name = N'Description';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for an endpoint', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Endpoints', @level2type = N'COLUMN', @level2name = N'EndpointID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'POST,PUT,GET,DELETE,OPTION Methods', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Endpoints', @level2type = N'COLUMN', @level2name = N'HttpMethod';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has modified this row', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Endpoints', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was updated', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Endpoints', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'API Endpoint Path', @level0type = N'SCHEMA', @level0name = N'SECURITY', @level1type = N'TABLE', @level1name = N'Endpoints', @level2type = N'COLUMN', @level2name = N'ResourcePath';
GO

