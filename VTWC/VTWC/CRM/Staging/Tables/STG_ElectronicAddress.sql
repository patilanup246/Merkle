CREATE TABLE [Staging].[STG_ElectronicAddress] (
    [ElectronicAddressID]    INT             IDENTITY (1, 1) NOT NULL,
    [Name]                   NVARCHAR (256)  NULL,
    [Description]            NVARCHAR (4000) NULL,
    [CreatedDate]            DATETIME        NOT NULL,
    [CreatedBy]              INT             NOT NULL,
    [LastModifiedDate]       DATETIME        NOT NULL,
    [LastModifiedBy]         INT             NOT NULL,
    [ArchivedInd]            BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID]    INT             NOT NULL,
    [SourceChangeDate]       DATETIME        NOT NULL,
    [Address]                NVARCHAR (256)  NOT NULL,
    [PrimaryInd]             BIT             DEFAULT ((0)) NOT NULL,
    [UsedInCommunicationInd] BIT             DEFAULT ((0)) NOT NULL,
    [ParsedInd]              BIT             DEFAULT ((0)) NOT NULL,
    [ParsedScore]            INT             DEFAULT ((0)) NOT NULL,
    [IndividualID]           INT             NULL,
    [CustomerID]             INT             NULL,
    [AddressTypeID]          INT             NOT NULL,
    [ParsedAddress]          NVARCHAR (256)  NULL,
    [HashedAddress]			 NVARCHAR (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [EncryptedAddress]       NVARCHAR(36)	COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL DEFAULT convert(nvarchar(36), newid()), 
    CONSTRAINT [cndx_PrimaryKey_ElectronicAddress] PRIMARY KEY CLUSTERED ([ElectronicAddressID] ASC),
    CONSTRAINT [FK_STG_ElectronicAddress_AddressTypeID] FOREIGN KEY ([AddressTypeID]) REFERENCES [Reference].[AddressType] ([AddressTypeID]),
    CONSTRAINT [FK_STG_ElectronicAddress_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_ElectronicAddress_IndividualID] FOREIGN KEY ([IndividualID]) REFERENCES [Staging].[STG_Individual] ([IndividualID]),
    CONSTRAINT [FK_STG_ElectronicAddress_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);


GO
CREATE NONCLUSTERED INDEX [STG_ElectronicAddress_Primary_ParsedAddress]
    ON [Staging].[STG_ElectronicAddress]([PrimaryInd] ASC, [ParsedAddress] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_STG_ElectronicAddress_ParsedScore]
    ON [Staging].[STG_ElectronicAddress]([PrimaryInd] ASC, [AddressTypeID] ASC)
    INCLUDE([ParsedScore], [CustomerID]);


GO
CREATE NONCLUSTERED INDEX [ix_STG_ElectronicAddress_IndividualID]
    ON [Staging].[STG_ElectronicAddress]([IndividualID] ASC)
    INCLUDE([AddressTypeID]);


GO
CREATE NONCLUSTERED INDEX [ix_STG_ElectronicAddress_HashedAddress_CustomerID]
    ON [Staging].[STG_ElectronicAddress]([HashedAddress] ASC)
    INCLUDE([CustomerID]);


GO
CREATE NONCLUSTERED INDEX [ix_STG_ElectronicAddress_EncrytpedAddress_CustomerID]
    ON [Staging].[STG_ElectronicAddress]([EncryptedAddress] ASC)
    INCLUDE([CustomerID]);
	
GO
CREATE NONCLUSTERED INDEX [ix_STG_ElectronicAddress_AddressTypeIDParsedAddress]
    ON [Staging].[STG_ElectronicAddress]([AddressTypeID] ASC, [ParsedAddress] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_STG_ElectronicAddress_AddressTypeIDAddress]
    ON [Staging].[STG_ElectronicAddress]([AddressTypeID] ASC, [Address] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_stg_electronicaddress_hashedaddress]
    ON [Staging].[STG_ElectronicAddress]([PrimaryInd] ASC, [HashedAddress] ASC)
    INCLUDE([IndividualID], [AddressTypeID]);

GO
CREATE NONCLUSTERED INDEX [idx_stg_electronicaddress_encrytpedaddress]
    ON [Staging].[STG_ElectronicAddress]([PrimaryInd] ASC, [EncryptedAddress] ASC)
    INCLUDE([IndividualID], [AddressTypeID]);

GO
CREATE NONCLUSTERED INDEX [DBA_NCI_PrimaryInd_CustomerID_AddressTypeID]
    ON [Staging].[STG_ElectronicAddress]([PrimaryInd] ASC, [CustomerID] ASC, [AddressTypeID] ASC)
    INCLUDE([ArchivedInd], [ParsedAddress]);


GO
CREATE NONCLUSTERED INDEX [DBA_NCI_CustomerID]
    ON [Staging].[STG_ElectronicAddress]([CustomerID] ASC)
    INCLUDE([AddressTypeID], [HashedAddress]);

