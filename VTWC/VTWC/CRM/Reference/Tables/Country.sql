CREATE TABLE [Reference].[Country] (
    [CountryID]           INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [Code]                NVARCHAR (2)    NULL,
    [ValidityStartDate]   DATETIME        NOT NULL,
    [ValidityEndDate]     DATETIME        NOT NULL,
    [SourceCreatedDate]   DATETIME        NOT NULL,
    [SourceModifiedDate]  DATETIME        NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_Country] PRIMARY KEY CLUSTERED ([CountryID] ASC),
    CONSTRAINT [FK_Country_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

