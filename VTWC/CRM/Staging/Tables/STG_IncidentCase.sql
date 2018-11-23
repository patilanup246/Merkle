CREATE TABLE [Staging].[STG_IncidentCase] (
    [IncidentCaseID]             INT             IDENTITY (1, 1) NOT NULL,
    [Name]                       NVARCHAR (256)  NULL,
    [Description]                NVARCHAR (4000) NULL,
    [CreatedDate]                DATETIME        NOT NULL,
    [CreatedBy]                  INT             NOT NULL,
    [LastModifiedDate]           DATETIME        NOT NULL,
    [LastModifiedBy]             INT             NOT NULL,
    [ArchivedInd]                BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID]        INT             NOT NULL,
    [SourceCreatedDate]          DATETIME        NOT NULL,
    [SourceModifiedDate]         DATETIME        NOT NULL,
    [CustomerID]                 INT             NOT NULL,
    [IncidentCaseTypeID]         INT             NOT NULL,
    [IncidentCaseStatusID]       INT             NOT NULL,
    [IncidentCaseReasonID]       INT             NULL,
    [SalesTransactionIDOriginal] INT             NULL,
    [SalesTransactionIDNew]      INT             NULL,
    [IncidentCaseRefundTypeID]   INT             NULL,
    [CaseNumber]                 NVARCHAR (256)  NULL,
    [ExtReference]               NVARCHAR (256)  NULL,
    [ComplaintInd]               BIT             DEFAULT ((0)) NOT NULL,
    [RefundAmount]               DECIMAL (14, 2) NULL,
    [DateRefunded]               DATETIME        NULL,
    CONSTRAINT [cndx_PrimaryKey_IncidentCase] PRIMARY KEY CLUSTERED ([IncidentCaseID] ASC),
    CONSTRAINT [FK_STG_IncidentCase_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_IncidentCase_IncidentCaseReasonID] FOREIGN KEY ([IncidentCaseReasonID]) REFERENCES [Reference].[IncidentCaseReason] ([IncidentCaseReasonID]),
    CONSTRAINT [FK_STG_IncidentCase_IncidentCaseRefundTypeID] FOREIGN KEY ([IncidentCaseRefundTypeID]) REFERENCES [Reference].[IncidentCaseRefundType] ([IncidentCaseRefundTypeID]),
    CONSTRAINT [FK_STG_IncidentCase_IncidentCaseTypeID] FOREIGN KEY ([IncidentCaseTypeID]) REFERENCES [Reference].[IncidentCaseType] ([IncidentCaseTypeID]),
    CONSTRAINT [FK_STG_IncidentCase_SalesTransactionIDNew] FOREIGN KEY ([SalesTransactionIDNew]) REFERENCES [Staging].[STG_SalesTransaction] ([SalesTransactionID]),
    CONSTRAINT [FK_STG_IncidentCase_SalesTransactionIDOriginal] FOREIGN KEY ([SalesTransactionIDOriginal]) REFERENCES [Staging].[STG_SalesTransaction] ([SalesTransactionID])
);


GO
CREATE NONCLUSTERED INDEX [ix_STG_IncidentCase_SalesTransactionIDOriginal]
    ON [Staging].[STG_IncidentCase]([ArchivedInd] ASC, [SalesTransactionIDOriginal] ASC)
    INCLUDE([IncidentCaseID], [Name], [Description], [CreatedDate], [CreatedBy], [LastModifiedDate], [LastModifiedBy], [InformationSourceID], [SourceCreatedDate], [SourceModifiedDate], [CustomerID], [IncidentCaseTypeID], [IncidentCaseStatusID], [IncidentCaseReasonID], [SalesTransactionIDNew], [IncidentCaseRefundTypeID], [CaseNumber], [ExtReference], [ComplaintInd], [RefundAmount]);


GO
CREATE NONCLUSTERED INDEX [DBA_NCI_ExtReference]
    ON [Staging].[STG_IncidentCase]([ExtReference] ASC)
    INCLUDE([IncidentCaseID], [Name], [Description], [LastModifiedDate], [LastModifiedBy], [InformationSourceID], [SourceCreatedDate], [SourceModifiedDate], [CustomerID], [IncidentCaseTypeID], [IncidentCaseStatusID], [IncidentCaseReasonID], [SalesTransactionIDOriginal], [SalesTransactionIDNew], [IncidentCaseRefundTypeID], [CaseNumber], [ComplaintInd], [RefundAmount]);

