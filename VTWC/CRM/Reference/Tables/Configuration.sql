CREATE TABLE [Reference].[Configuration] (
    [ConfigurationID]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256) NOT NULL,
    [Description]         NVARCHAR (MAX) NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [CreatedBy]           INT            NOT NULL,
    [LastModifiedDate]    DATETIME       NOT NULL,
    [LastModifiedBy]      INT            NOT NULL,
    [ArchivedInd]         BIT            DEFAULT ((0)) NOT NULL,
    [ConfigurationTypeID] INT            NOT NULL,
    [Setting]             NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_Configuration] PRIMARY KEY CLUSTERED ([ConfigurationID] ASC),
    CONSTRAINT [FK_Configuration_ConfigurationTypeId] FOREIGN KEY ([ConfigurationTypeID]) REFERENCES [Reference].[ConfigurationType] ([ConfigurationTypeID])
);

