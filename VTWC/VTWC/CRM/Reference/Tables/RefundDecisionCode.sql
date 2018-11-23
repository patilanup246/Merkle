CREATE TABLE [Reference].[RefundDecisionCode] (
    [RefundDecisionCodeID] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                 NVARCHAR (256)  NULL,
    [Description]          NVARCHAR (4000) NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [CreatedBy]            INT             NOT NULL,
    [LastModifiedDate]     DATETIME        NOT NULL,
    [LastModifiedBy]       INT             NOT NULL,
    [ArchivedInd]          BIT             DEFAULT ((0)) NOT NULL,
    [SourceCreatedDate]    DATETIME        NOT NULL,
    [SourceModifiedDate]   DATETIME        NOT NULL,
    [InformationSourceID]  INT             NOT NULL,
    [Code]                 NVARCHAR (4)    NULL,
    [IsRejectionInd]       BIT             DEFAULT ((0)) NULL,
    [ExtReference]         NVARCHAR (256)  NULL,
    [ValidityStartDate]    DATETIME        NOT NULL,
    [ValidityEndDate]      DATETIME        NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_RefundDecisionCode] PRIMARY KEY CLUSTERED ([RefundDecisionCodeID] ASC),
    CONSTRAINT [FK_RefundDecisionCode_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

