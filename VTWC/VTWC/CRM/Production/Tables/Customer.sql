CREATE TABLE [Production].[Customer] (
    [CustomerID]               INT             NOT NULL,
    [Description]              NVARCHAR (4000) NULL,
    [CreatedDate]              DATETIME        NOT NULL,
    [CreatedBy]                INT             NOT NULL,
    [LastModifiedDate]         DATETIME        NOT NULL,
    [LastModifiedBy]           INT             NOT NULL,
    [ArchivedInd]              BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID]      INT             NOT NULL,
    [IndividualID]             INT             NULL,
    [CustomerTypeID]           INT             NULL,
    [SegmentTierID]            INT             NULL,
    [LocationIDHomeActual]     INT             NULL,
    [LocationIDHomeInferred]   INT             NULL,
    [ValidEmailInd]            BIT             DEFAULT ((0)) NOT NULL,
    [ValidMobileInd]           BIT             DEFAULT ((0)) NOT NULL,
    [OptInLeisureInd]          BIT             DEFAULT ((0)) NOT NULL,
    [OptInCorporateInd]        BIT             DEFAULT ((0)) NOT NULL,
    [IsFallowCellInd]          BIT             DEFAULT ((0)) NOT NULL,
    [CountryID]                INT             CONSTRAINT [DF_ProdCustCountryID] DEFAULT ((-99)) NOT NULL,
    [IsOrganisationInd]        BIT             DEFAULT ((0)) NOT NULL,
    [IsStaffInd]               BIT             DEFAULT ((0)) NOT NULL,
    [IsBlackListInd]           BIT             DEFAULT ((0)) NOT NULL,
    [IsCorporateInd]           BIT             DEFAULT ((0)) NOT NULL,
    [IsTMCInd]                 BIT             DEFAULT ((0)) NOT NULL,
    [RailCardUserInd]          BIT             DEFAULT ((0)) NOT NULL,
    [eVoucherUserInd]          BIT             DEFAULT ((0)) NOT NULL,
    [Salutation]               NVARCHAR (64)   NULL,
    [FirstName]                NVARCHAR (64)   NULL,
    [MiddleName]               NVARCHAR (64)   NULL,
    [LastName]                 NVARCHAR (64)   NULL,
    [EmailAddress]             NVARCHAR (256)  NULL,
    [MobileNumber]             NVARCHAR (512)  NULL,
    [PostalArea]               NVARCHAR (32)   NULL,
    [PostalDistrict]           NVARCHAR (32)   NULL,
    [DateRegistered]           DATETIME        NULL,
    [DateFirstPurchaseAny]     DATETIME        NULL,
    [DateLastPurchaseAny]      DATETIME        NULL,
    [DateFirstPurchaseFirst]   DATETIME        NULL,
    [DateLastPurchaseFirst]    DATETIME        NULL,
    [DateFirstTravelAny]       DATETIME        NULL,
    [DateLastTravelAny]        DATETIME        NULL,
    [DateNextTravelAny]        DATETIME        NULL,
    [DateFirstTravelFirst]     DATETIME        NULL,
    [DateLastTravelFirst]      DATETIME        NULL,
    [DateNextTravelFirst]      DATETIME        NULL,
    [SalesAmountTotal]         DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmount3Mnth]         DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmount6Mnth]         DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmount12Mnth]        DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmountRailTotal]     DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmountRail3Mnth]     DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmountRail6Mnth]     DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmountRail12Mnth]    DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmountNotRailTotal]  DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmountNotRail3Mnth]  DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmountNotRail6Mnth]  DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesAmountNotRail12Mnth] DECIMAL (14, 2) DEFAULT ((0)) NOT NULL,
    [SalesTransactionTotal]    INT             DEFAULT ((0)) NOT NULL,
    [SalesTransaction1Mnth]    INT             DEFAULT ((0)) NOT NULL,
    [SalesTransaction3Mnth]    INT             DEFAULT ((0)) NOT NULL,
    [SalesTransaction6Mnth]    INT             DEFAULT ((0)) NOT NULL,
    [SalesTransaction12Mnth]   INT             DEFAULT ((0)) NOT NULL,
    [SalesTransaction24Mnth]   INT             DEFAULT ((0)) NOT NULL,
    [SalesTransaction36Mnth]   INT             DEFAULT ((0)) NOT NULL,
    [MigratedInd]              BIT             CONSTRAINT [MigratedIndDefault] DEFAULT ((0)) NULL,
    [RFVsegmentRecency]        CHAR (1)        NULL,
    [RFVsegmentValue]          CHAR (1)        NULL,
    [RFVsegmentFrequency]      CHAR (1)        NULL,
    [RFV]                      VARCHAR(8)      NULL,
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
	CONSTRAINT [cndx_PrimaryKey_Customer] PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [FK_Customer_CountryID] FOREIGN KEY ([CountryID]) REFERENCES [Reference].[Country] ([CountryID]),
    CONSTRAINT [FK_Customer_CustomerTypeID] FOREIGN KEY ([CustomerTypeID]) REFERENCES [Reference].[CustomerType] ([CustomerTypeID]),
    CONSTRAINT [FK_Customer_IndividualID] FOREIGN KEY ([IndividualID]) REFERENCES [Staging].[STG_Individual] ([IndividualID]),
    CONSTRAINT [FK_Customer_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_Customer_LocationIDActual] FOREIGN KEY ([LocationIDHomeActual]) REFERENCES [Reference].[Location] ([LocationID]),
    CONSTRAINT [FK_Customer_LocationIDInferred] FOREIGN KEY ([LocationIDHomeInferred]) REFERENCES [Reference].[Location] ([LocationID]),
    CONSTRAINT [FK_Customer_SegmentTierID] FOREIGN KEY ([SegmentTierID]) REFERENCES [Reference].[SegmentTier] ([SegmentTierID])
);


GO
CREATE NONCLUSTERED INDEX [Missing_IXNC_Customer_ArchivedInd_EmailAddress]
    ON [Production].[Customer]([ArchivedInd] ASC, [EmailAddress] ASC)
    INCLUDE([CustomerID]);


GO
CREATE NONCLUSTERED INDEX [Missing_IXNC_Customer_ArchivedInd]
    ON [Production].[Customer]([ArchivedInd] ASC)
    INCLUDE([CustomerID], [ValidEmailInd], [OptInLeisureInd], [DateRegistered]);


GO
CREATE NONCLUSTERED INDEX [ix_Customer_Registered_Optin]
    ON [Production].[Customer]([DateRegistered] ASC)
    INCLUDE([OptInLeisureInd]);


GO
CREATE NONCLUSTERED INDEX [ix_Customer_DateLastTravel]
    ON [Production].[Customer]([DateLastTravelAny] ASC, [DateNextTravelAny] ASC)
    INCLUDE([CustomerID]);


GO
CREATE NONCLUSTERED INDEX [DBA_NCI_ValidEmailInd_OptInLeisureInd]
    ON [Production].[Customer]([ValidEmailInd] ASC, [OptInLeisureInd] ASC)
    INCLUDE([CustomerID], [CreatedDate], [FirstName], [LastName], [EmailAddress]);


GO
CREATE NONCLUSTERED INDEX [DBA_NCI_ArchiveInd_SegmentTierID_InformationSourceID]
    ON [Production].[Customer]([ArchivedInd] ASC, [SegmentTierID] ASC, [InformationSourceID] ASC)
    INCLUDE([CustomerID], [DateRegistered], [SalesTransaction12Mnth], [LocationIDHomeInferred]);


GO
CREATE NONCLUSTERED INDEX [Customer_ArchivedInd]
    ON [Production].[Customer]([ArchivedInd] ASC)
    INCLUDE([CustomerID]);

GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RFV Segmentation',
    @level0type = N'SCHEMA',
    @level0name = N'Production',
    @level1type = N'TABLE',
    @level1name = N'Customer',
    @level2type = N'COLUMN',
    @level2name = N'RFV'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recency Score for RFV',
    @level0type = N'SCHEMA',
    @level0name = N'Production',
    @level1type = N'TABLE',
    @level1name = N'Customer',
    @level2type = N'COLUMN',
    @level2name = N'RFVsegmentRecency'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Value Score for RFV',
    @level0type = N'SCHEMA',
    @level0name = N'Production',
    @level1type = N'TABLE',
    @level1name = N'Customer',
    @level2type = N'COLUMN',
    @level2name = N'RFVsegmentValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Frequency Score for RFV',
    @level0type = N'SCHEMA',
    @level0name = N'Production',
    @level1type = N'TABLE',
    @level1name = N'Customer',
    @level2type = N'COLUMN',
    @level2name = N'RFVsegmentFrequency'
