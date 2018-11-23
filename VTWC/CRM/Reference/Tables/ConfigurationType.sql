CREATE TABLE [Reference].[ConfigurationType] (
    [ConfigurationTypeID] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256) NOT NULL,
    [Description]         NVARCHAR (MAX) NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [CreatedBy]           INT            NOT NULL,
    [LastModifiedDate]    DATETIME       NOT NULL,
    [LastModifiedBy]      INT            NOT NULL,
    [ArchivedInd]         BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_ConfigurationType] PRIMARY KEY CLUSTERED ([ConfigurationTypeID] ASC)
);

