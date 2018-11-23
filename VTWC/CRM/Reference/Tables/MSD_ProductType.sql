CREATE TABLE [Reference].[MSD_ProductType] (
    [MSDProductTypeId] INT            NOT NULL,
    [Name]             NVARCHAR (256) NOT NULL,
    [Description]      NVARCHAR (MAX) NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [CreatedBy]        INT            NOT NULL,
    [LastModifiedDate] DATETIME       NOT NULL,
    [LastModifiedBy]   INT            NOT NULL,
    [ArchivedInd]      BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_ProductType] PRIMARY KEY CLUSTERED ([MSDProductTypeId] ASC)
);

