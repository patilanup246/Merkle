CREATE TABLE [Reference].[LocationAlias] (
    [LocationAliasID]     INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [LocationID]          INT             NULL,
    CONSTRAINT [cndx_PrimaryKey_LocationAlias] PRIMARY KEY CLUSTERED ([LocationAliasID] ASC),
    CONSTRAINT [FK_LocationAlias_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_LocationAlias_LocationID] FOREIGN KEY ([LocationID]) REFERENCES [Reference].[Location] ([LocationID])
);

