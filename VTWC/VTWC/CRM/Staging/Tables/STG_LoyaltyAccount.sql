CREATE TABLE [Staging].[STG_LoyaltyAccount] (
    [LoyaltyAccountID]       INT             IDENTITY (1, 1) NOT NULL,
    [Name]                   NVARCHAR (256)  NULL,
    [Description]            NVARCHAR (4000) NULL,
    [CreatedDate]            DATETIME        NOT NULL,
    [CreatedBy]              INT             NOT NULL,
    [LastModifiedDate]       DATETIME        NOT NULL,
    [LastModifiedBy]         INT             NOT NULL,
    [ArchivedInd]            BIT             DEFAULT ((0)) NOT NULL,
    [LoyaltyProgrammeTypeID] INT             NOT NULL,
    [LoyaltyReference]       NVARCHAR (32)   NOT NULL,
    [InformationSourceID]    INT             NOT NULL,
    [SourceCreatedDate]      DATETIME        NOT NULL,
    [SourceModifiedDate]     DATETIME        NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_LoyaltyAccount] PRIMARY KEY CLUSTERED ([LoyaltyAccountID] ASC),
    CONSTRAINT [FK_STG_LoyaltyAccount_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_STG_LoyaltyAccount_LoyaltyProgrammeTypeID] FOREIGN KEY ([LoyaltyProgrammeTypeID]) REFERENCES [Reference].[LoyaltyProgrammeType] ([LoyaltyProgrammeTypeID])
);

