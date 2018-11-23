CREATE TABLE [Reference].[MSD_Product] (
    [MSDProductID]     INT              IDENTITY (1, 1) NOT NULL,
    [ProductIdMSD]     UNIQUEIDENTIFIER NOT NULL,
    [Name]             NVARCHAR (100)   NULL,
    [Description]      NVARCHAR (MAX)   NULL,
    [ProductTypeCode]  INT              NULL,
    [ProductNumber]    NVARCHAR (100)   NOT NULL,
    [CreatedOn]        DATETIME         NULL,
    [ModifiedOn]       DATETIME         NULL,
    [StateCode]        INT              NOT NULL,
    [StatusCode]       INT              NULL,
    [MSDProductTypeId] INT              NOT NULL,
    [ProductID]        INT              NULL,
    [CreatedDate]      DATETIME         NULL,
    [CreatedBy]        INT              NULL,
    [LastModifiedDate] DATETIME         NULL,
    [LastModifiedBy]   INT              NULL,
    [ArchivedInd]      BIT              NULL,
    CONSTRAINT [cndx_PrimaryKey_MSD_Product] PRIMARY KEY CLUSTERED ([MSDProductID] ASC),
    CONSTRAINT [FK_MSD_Product_MSDProductTypeID] FOREIGN KEY ([MSDProductTypeId]) REFERENCES [Reference].[MSD_ProductType] ([MSDProductTypeId]),
    CONSTRAINT [FK_MSD_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Reference].[Product] ([ProductID])
);

