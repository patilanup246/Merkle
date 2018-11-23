CREATE TABLE [Staging].[STG_IndividualCustomerAudit] (
    [IndividualCustomerAuditID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]                      NVARCHAR (256)  NULL,
    [Description]               NVARCHAR (4000) NULL,
    [CreatedDate]               DATETIME        NULL,
    [CreatedBy]                 NVARCHAR (256)  NULL,
    [LastModifiedDate]          DATETIME        NULL,
    [LastModifiedBy]            INT             NULL,
    [ArchivedInd]               BIT             DEFAULT ((0)) NULL,
    [CustomerID]                INT             NULL,
    [IndividualID]              INT             NULL,
    [AddressUniqueID]           INT             NULL,
    [CollectionNumber]          INT             NULL,
    [MatchScore]                NVARCHAR (512)  NULL,
    [MatchRecordType]           NVARCHAR (512)  NULL,
    [FirstNameParsed]           NVARCHAR (64)   NULL,
    [LastNameParsed]            NVARCHAR (64)   NULL,
    [FirstNameCustomer]         NVARCHAR (64)   NULL,
    [LastNameCustomer]          NVARCHAR (64)   NULL,
    [MatchingTypeID]            INT             NULL,
    [OperationalStatusID]       INT             NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_IndividualCustomerAudit] PRIMARY KEY CLUSTERED ([IndividualCustomerAuditID] ASC),
    CONSTRAINT [FK_STG_IndividualCustomerAudit_AddressUniqueID] FOREIGN KEY ([AddressUniqueID]) REFERENCES [Staging].[STG_AddressUnique] ([AddressUniqueID]),
    CONSTRAINT [FK_STG_IndividualCustomerAudit_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_IndividualCustomerAudit_IndividualID] FOREIGN KEY ([IndividualID]) REFERENCES [Staging].[STG_Individual] ([IndividualID])
);


GO
CREATE NONCLUSTERED INDEX [ix_STG_IndividualCustomerAudit_CustomerID]
    ON [Staging].[STG_IndividualCustomerAudit]([CustomerID] ASC)
    INCLUDE([CollectionNumber]);

