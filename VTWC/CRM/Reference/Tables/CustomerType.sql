CREATE TABLE [Reference].[CustomerType] (
    [CustomerTypeID]       INT             IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (256)  NOT NULL,
    [Description]          NVARCHAR (4000) NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [CreatedBy]            INT             NOT NULL,
    [LastModifiedDate]     DATETIME        NOT NULL,
    [LastModifiedBy]       INT             NOT NULL,
    [ArchivedInd]          BIT             DEFAULT ((0)) NOT NULL,
    [CustomerTypeIDParent] INT             NULL,
    [TypeOrder]            INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_CustomerType] PRIMARY KEY CLUSTERED ([CustomerTypeID] ASC),
    CONSTRAINT [FK_Customer_CustomerTypeIDParent] FOREIGN KEY ([CustomerTypeIDParent]) REFERENCES [Reference].[CustomerType] ([CustomerTypeID])
);

