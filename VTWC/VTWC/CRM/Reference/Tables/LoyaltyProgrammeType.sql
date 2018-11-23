CREATE TABLE [Reference].[LoyaltyProgrammeType] (
    [LoyaltyProgrammeTypeID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]                   NVARCHAR (256)  NOT NULL,
    [Description]            NVARCHAR (4000) NULL,
    [CreatedDate]            DATETIME        NOT NULL,
    [CreatedBy]              INT             NOT NULL,
    [LastModifiedDate]       DATETIME        NOT NULL,
    [LastModifiedBy]         INT             NOT NULL,
    [ArchivedInd]            BIT             DEFAULT ((0)) NOT NULL,
    [DisplayName]            NVARCHAR (256)  NOT NULL,
    [ExtReference]           NVARCHAR (256)  NULL,
    [ProgrammeName]          NVARCHAR (256)  NULL,
    [ValidityStartDate]      DATETIME        NOT NULL,
    [ValidityEndDate]        DATETIME        NOT NULL,
    [SourceCreatedDate]      DATETIME        NULL,
    [SourceModifiedDate]     DATETIME        NULL,
    CONSTRAINT [cndx_PrimaryKey_LoyaltyProgrammeType] PRIMARY KEY CLUSTERED ([LoyaltyProgrammeTypeID] ASC)
);

