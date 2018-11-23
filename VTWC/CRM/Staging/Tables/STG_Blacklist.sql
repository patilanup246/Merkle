CREATE TABLE [Staging].[STG_Blacklist] (
    [BlacklistID]         INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                NVARCHAR (256)  NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [Address]             NVARCHAR (256)  NOT NULL,
    [AddressTypeID]       INT             NOT NULL,
    [ParsedAddress]       NVARCHAR (256)  NULL,
    [InformationSourceID] INT             NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_Blacklist] PRIMARY KEY CLUSTERED ([BlacklistID] ASC),
    CONSTRAINT [FK_STG_Blacklist_AddressTypeID] FOREIGN KEY ([AddressTypeID]) REFERENCES [Reference].[AddressType] ([AddressTypeID]),
    CONSTRAINT [FK_STG_Blacklist_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

