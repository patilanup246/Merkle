CREATE TABLE [Reference].[MSD_StringMapBase] (
    [ObjectTypeCode] INT              NOT NULL,
    [AttributeName]  NVARCHAR (100)   NOT NULL,
    [AttributeValue] INT              NOT NULL,
    [LangId]         INT              NOT NULL,
    [OrganizationId] UNIQUEIDENTIFIER NOT NULL,
    [Value]          NVARCHAR (4000)  NULL,
    [DisplayOrder]   INT              NULL,
    [VersionNumber]  ROWVERSION       NULL,
    [StringMapId]    UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_StringMap] PRIMARY KEY CLUSTERED ([StringMapId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [UQ_StringMap] UNIQUE NONCLUSTERED ([ObjectTypeCode] ASC, [AttributeName] ASC, [AttributeValue] ASC, [LangId] ASC, [OrganizationId] ASC)
);

