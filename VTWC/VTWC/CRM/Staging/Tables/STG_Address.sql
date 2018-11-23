CREATE TABLE [Staging].[STG_Address] (
    [AddressID]             INT             IDENTITY (1, 1) NOT NULL,
    [Name]                  NVARCHAR (256)  NULL,
    [Description]           NVARCHAR (4000) NULL,
    [CreatedDate]           DATETIME        NOT NULL,
    [CreatedBy]             INT             NOT NULL,
    [LastModifiedDate]      DATETIME        NOT NULL,
    [LastModifiedBy]        INT             NOT NULL,
    [ArchivedInd]           BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID]   INT             NOT NULL,
    [SourceCreatedDate]     DATETIME        NOT NULL,
    [SourceModifiedDate]    DATETIME        NOT NULL,
    [AddressLine1]          NVARCHAR (512)  NULL,
    [AddressLine2]          NVARCHAR (512)  NULL,
    [AddressLine3]          NVARCHAR (512)  NULL,
    [AddressLine4]          NVARCHAR (512)  NULL,
    [AddressLine5]          NVARCHAR (512)  NULL,
    [TownCity]              NVARCHAR (512)  NULL,
    [County]                NVARCHAR (512)  NULL,
    [PostalCode]            NVARCHAR (32)   NULL,
    [CountryID]             INT             CONSTRAINT [DF_STGAddrCountryID] DEFAULT ((-99)) NOT NULL,
    [PrimaryInd]            BIT             DEFAULT ((0)) NOT NULL,
    [AddressTypeID]         INT             NOT NULL,
    [IndividualID]          INT             NULL,
    [CustomerID]            INT             NULL,
    [AddresseeInAddressInd] BIT             DEFAULT ((0)) NOT NULL,
    [IsShortAddressInd]     BIT             DEFAULT ((0)) NOT NULL,
    [CompanyName]           NVARCHAR (100)  NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_Address] PRIMARY KEY CLUSTERED ([AddressID] ASC),
    CONSTRAINT [FK_STG_Address_CountryID] FOREIGN KEY ([CountryID]) REFERENCES [Reference].[Country] ([CountryID]),
    CONSTRAINT [FK_STG_Address_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_Address_IndividualID] FOREIGN KEY ([IndividualID]) REFERENCES [Staging].[STG_Individual] ([IndividualID]),
    CONSTRAINT [FK_STG_Address_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);




GO
CREATE NONCLUSTERED INDEX [ix_STG_Address_PrimaryInd]
    ON [Staging].[STG_Address]([PrimaryInd] ASC)
    INCLUDE([AddressID], [AddressTypeID], [CustomerID]);


GO
CREATE NONCLUSTERED INDEX [idx_STG_Address]
    ON [Staging].[STG_Address]([PrimaryInd] ASC, [CustomerID] ASC)
    INCLUDE([AddressLine1], [AddressLine2], [AddressLine3], [AddressLine4], [AddressLine5], [TownCity], [County], [PostalCode], [CountryID]);


GO
CREATE NONCLUSTERED INDEX [DBA_NCI_AddressTypeID_CustomerID]
    ON [Staging].[STG_Address]([AddressTypeID] ASC, [CustomerID] ASC)
    INCLUDE([AddressID], [SourceCreatedDate], [SourceModifiedDate], [AddressLine1], [AddressLine2], [AddressLine3], [AddressLine4], [AddressLine5], [TownCity], [County], [PostalCode]);

