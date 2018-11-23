CREATE TABLE [Staging].[STG_LoyaltySeason_Instalments] (
    [LoyaltySeasonInstalmentID] INT      IDENTITY (1, 1) NOT NULL,
    [CreatedDate]               DATETIME NOT NULL,
    [CreatedBy]                 INT      NOT NULL,
    [LastModifiedDate]          DATETIME NOT NULL,
    [LastModifiedBy]            INT      NOT NULL,
    [ArchivedInd]               BIT      NOT NULL,
    [SourceCreatedDate]         DATETIME NOT NULL,
    [SourceModifiedDate]        DATETIME NOT NULL,
    [LoyaltySeasonTicketID]     INT      NOT NULL,
    [CustomerID]                INT      NOT NULL,
    [CBECustomerID]             INT      NOT NULL,
    [InstalmentDate]            DATE     NULL,
    [InstalmentAmount]          INT      NULL,
    [ProcessedInd]              BIT      DEFAULT ((0)) NOT NULL,
    [ProcessedDate]             DATE     NULL,
    [LoyaltyStatusID]           INT      NULL,
    PRIMARY KEY CLUSTERED ([LoyaltySeasonInstalmentID] ASC),
    CONSTRAINT [fk_LoyaltyInstalmentStatusID] FOREIGN KEY ([LoyaltyStatusID]) REFERENCES [Reference].[LoyaltyStatus] ([LoyaltyStatusID]),
    CONSTRAINT [fk_LoyaltySeasonTicketID] FOREIGN KEY ([LoyaltySeasonTicketID]) REFERENCES [Staging].[STG_LoyaltySeason_Summary] ([LoyaltySeasonTicketID])
);

