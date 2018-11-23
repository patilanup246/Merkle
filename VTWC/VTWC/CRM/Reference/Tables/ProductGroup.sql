CREATE TABLE [Reference].[ProductGroup] (
    [ProductGroupID]       INT             IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (256)  NOT NULL,
    [Description]          NVARCHAR (4000) NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [CreatedBy]            INT             NOT NULL,
    [LastModifiedDate]     DATETIME        NOT NULL,
    [LastModifiedBy]       INT             NOT NULL,
    [ArchivedInd]          BIT             DEFAULT ((0)) NOT NULL,
    [ProductGroupIDParent] INT             NULL,
    CONSTRAINT [cndx_PrimaryKey_ProductGroup] PRIMARY KEY CLUSTERED ([ProductGroupID] ASC),
    CONSTRAINT [FK_ProductGroup_ProductGroupIDParent] FOREIGN KEY ([ProductGroupIDParent]) REFERENCES [Reference].[ProductGroup] ([ProductGroupID])
);

