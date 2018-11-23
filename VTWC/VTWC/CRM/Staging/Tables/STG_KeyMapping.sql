CREATE TABLE [Staging].[STG_KeyMapping] (
    [KeyMappingID]                INT             IDENTITY (1, 1) NOT NULL,
    [Description]                 NVARCHAR (4000) NULL,
    [CreatedDate]                 DATETIME        NOT NULL,
    [CreatedBy]                   INT             NOT NULL,
    [LastModifiedDate]            DATETIME        NOT NULL,
    [LastModifiedBy]              INT             NOT NULL,
    [CustomerID]                  INT             NULL,
    [IndividualID]                INT             NULL,
    [InformationSourceID]         INT             NOT NULL,
    [TCSCustomerID]               INT             NULL,
    [MigratedDate]                DATETIME        NULL,
    [IsVerifiedInd]               BIT             CONSTRAINT [IsVerifiedDefault] DEFAULT ((0)) NOT NULL,
    [VerifiedDate]                DATETIME        NULL,
    [InformationSourceIDVerified] INT             NULL,
    [IsParentInd]                 BIT             NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_KeyMapping] PRIMARY KEY CLUSTERED ([KeyMappingID] ASC),
    CONSTRAINT [FK_STG_KeyMapping_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_KeyMapping_IndividualID] FOREIGN KEY ([IndividualID]) REFERENCES [Staging].[STG_Individual] ([IndividualID]),
    CONSTRAINT [FK_STG_KeyMapping_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);
GO

CREATE NONCLUSTERED INDEX [DBA_NCI_TCSCustomerID]
    ON [Staging].[STG_KeyMapping]([TCSCustomerID] ASC)
    INCLUDE([KeyMappingID], [CustomerID]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_KeyMapping_CustomerID_IndividualID]
    ON [Staging].[STG_KeyMapping]([CustomerID] ASC)
    INCLUDE([IndividualID]);
GO

CREATE NONCLUSTERED INDEX [ix_STG_KeyMapping_IndividualID]
    ON [Staging].[STG_KeyMapping]([IndividualID] ASC);
GO

