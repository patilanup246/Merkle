CREATE TABLE [Staging].[STG_Customer] (
    [CustomerID]               INT              IDENTITY (1, 1) NOT NULL,
    [Description]              NVARCHAR (4000)  NULL,
    [CreatedDate]              DATETIME         NOT NULL,
    [CreatedBy]                INT              NOT NULL,
    [LastModifiedDate]         DATETIME         NOT NULL,
    [LastModifiedBy]           INT              NOT NULL,
    [ArchivedInd]              BIT              DEFAULT ((0)) NOT NULL,
    [MSDID]                    UNIQUEIDENTIFIER NULL,
    [SourceCreatedDate]        DATETIME         NOT NULL,
    [SourceModifiedDate]       DATETIME         NOT NULL,
    [IsStaffInd]               BIT              DEFAULT ((0)) NOT NULL,
    [IsBlackListInd]           BIT              DEFAULT ((0)) NOT NULL,
    [IsTMCInd]                 BIT              DEFAULT ((0)) NOT NULL,
    [IsCorporateInd]           BIT              DEFAULT ((0)) NOT NULL,
    [Salutation]               NVARCHAR (64)    NULL,
    [FirstName]                NVARCHAR (64)    NULL,
    [MiddleName]               NVARCHAR (64)    NULL,
    [LastName]                 NVARCHAR (64)    NULL,
    [IndividualID]             INT              NULL,
    [InformationSourceID]      INT              NOT NULL,
    [DateFirstPurchase]        DATETIME         NULL,
    [DateLastPurchase]         DATETIME         NULL,
    [IsPersonInd]              BIT              CONSTRAINT [DF_IsPersonInd] DEFAULT ((1)) NOT NULL,
    [HasSetPrefInd]            BIT              CONSTRAINT [DF_STG_Customer_HasSetPrefInd] DEFAULT ((0)) NULL,
    [DateOfBirth]              DATETIME         NULL,
    [NearestStation]           NVARCHAR (5)     NULL,
    [VTSegment]                INT              NULL,
    [AccountStatus]            NVARCHAR (25)    NULL,
    [RegChannel]               NVARCHAR (20)    NULL,
    [RegOriginatingSystemType] NVARCHAR (20)    NULL,
    [FirstCallTranDate]        DATETIME         NULL,
    [FirstIntTranDate]         DATETIME         NULL,
    [FirstMobAppTranDate]      DATETIME         NULL,
    [FirstMobWebTranDate]      DATETIME         NULL,
    [ExperianHouseholdIncome]  NVARCHAR (20)    NULL,
    [ExperianAgeBand]          NVARCHAR (10)    NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_Customer] PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [FK_STG_Customer_IndividualID] FOREIGN KEY ([IndividualID]) REFERENCES [Staging].[STG_Individual] ([IndividualID]),
    CONSTRAINT [FK_STG_Customer_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);




GO
CREATE NONCLUSTERED INDEX [ix_STG_Customer_MSDID]
    ON [Staging].[STG_Customer]([MSDID] ASC);

