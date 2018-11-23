CREATE TABLE [Reference].[PaymentMethod] (
    [PaymentMethodID]     INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                NVARCHAR (256)  NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [SourceCreatedDate]   DATETIME        NOT NULL,
    [SourceModifiedDate]  DATETIME        NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [Code]                NVARCHAR (4)    NULL,
    [ValidityStartDate]   DATETIME        NOT NULL,
    [ValidityEndDate]     DATETIME        NOT NULL,
    [SDCIRecordType]      NVARCHAR (2)    NULL,
    [PriorityMaskValue]   INT             NULL,
    [MOP]                 NVARCHAR (16)   NULL,
    [MaxPaymentsCount]    INT             NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_PaymentMethod] PRIMARY KEY CLUSTERED ([PaymentMethodID] ASC),
    CONSTRAINT [FK_PaymentMethod_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

