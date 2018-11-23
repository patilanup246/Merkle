CREATE TABLE [Reference].[RetailChannel] (
    [RetailChannelID]     INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [ValidityStartDate]   DATETIME        NOT NULL,
    [ValidityEndDate]     DATETIME        NOT NULL,
    [SourceCreatedDate]   DATETIME        NOT NULL,
    [SourceModifiedDate]  DATETIME        NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    [Code]                NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_RetailChannel] PRIMARY KEY CLUSTERED ([RetailChannelID] ASC),
    CONSTRAINT [FK_RetailChannel_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

