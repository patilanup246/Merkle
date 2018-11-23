CREATE TABLE [Staging].[STG_Journey] (
    [JourneyID]                 INT             IDENTITY (1, 1) NOT NULL,
    [Name]                      NVARCHAR (256)  NULL,
    [Description]               NVARCHAR (4000) NULL,
    [CreatedDate]               DATETIME        NOT NULL,
    [CreatedBy]                 INT             NOT NULL,
    [LastModifiedDate]          DATETIME        NOT NULL,
    [LastModifiedBy]            INT             NOT NULL,
    [ArchivedInd]               BIT             DEFAULT ((0)) NOT NULL,
    [SalesDetailID]             INT             NOT NULL,
    [LocationIDOrigin]          INT             NULL,
    [LocationIDDestination]     INT             NULL,
    [ECJourneyScore]            INT             DEFAULT ((0)) NULL,
    [OutDepartureDateTime]      DATETIME        NULL,
    [InferredDepartureInd]      INT             DEFAULT ((0)) NULL,
    [OutArrivalDateTime]        DATETIME        NULL,
    [InferredArrivalInd]        INT             DEFAULT ((0)) NULL,
    [RetDepartureDateTime]      DATETIME        NULL,
    [RetArrivalDateTime]        DATETIME        NULL,
    [TOCIDPrimary]              INT             NULL,
    [NumberLegs]                INT             DEFAULT ((0)) NULL,
    [IsOutboundInd]             BIT             DEFAULT ((0)) NULL,
    [IsReturnInd]               BIT             DEFAULT ((0)) NULL,
    [IsReturnInferredInd]       BIT             DEFAULT ((0)) NULL,
    [ExtReference]              BIGINT          NULL,
    [InformationSourceID]       INT             NULL,
    [SourceCreatedDate]         DATETIME        NULL,
    [SourceModifiedDate]        DATETIME        NULL,
    [CustomerID]                INT             NULL,
    [SalesTransactionID]        INT             NULL,
    [TCSBookingID]              INT             NULL,
    [Railcard1]                 NVARCHAR (5)    NULL,
    [NoOfRailCards]             INT             NULL,
    [TotalAdults]               INT             NULL,
    [TotalChildren]             INT             NULL,
    [TotalReturningAdults]      INT             NULL,
    [TotalReturningChildren]    INT             NULL,
    [CostofTickets]             NUMERIC (6, 2)  NULL,
    [TotalCost]                 NUMERIC (6, 2)  NULL,
    [SavingsMade]               NUMERIC (6, 2)  NULL,
    [ProCode]                   NVARCHAR (15)   NULL,
    [JourneyReference]          NVARCHAR (50)   NULL,
    [OutboundMileage]           NUMERIC (6, 2)  NULL,
    [AvailabilityCodeID]        INT             NULL,
    [DisabledInd]               BIT             NULL,
    [NoFullFareAdults]          INT             NULL,
    [NoDiscFareAdults]          INT             NULL,
    [NoFullFareChildren]        INT             NULL,
    [NoDiscFareChildren]        INT             NULL,
    [NoRailcard1]               INT             NULL,
    [DateCreated]               DATETIME        NULL,
    [DateUpdated]               DATETIME        NULL,
    [FareId]                    INT             NULL,
    [PromoCode]                 NVARCHAR (30)   NULL,
    [FullAdultFare]             NUMERIC (6, 2)  NULL,
    [DiscAdultFare1]            NUMERIC (6, 2)  NULL,
    [DiscAdultFare2]            NUMERIC (6, 2)  NULL,
    [DiscAdultFare3]            NUMERIC (6, 2)  NULL,
    [FullChildFare]             NUMERIC (6, 2)  NULL,
    [DiscChildFare1]            NUMERIC (6, 2)  NULL,
    [DiscChildFare2]            NUMERIC (6, 2)  NULL,
    [DiscChildFare3]            NUMERIC (6, 2)  NULL,
    [NoAdultsFullFare]          INT             NULL,
    [NoAdultsDiscFare1]         INT             NULL,
    [NoAdultsDiscFare2]         INT             NULL,
    [NoAdultsDiscFare3]         INT             NULL,
    [NoChildFullFare]           INT             NULL,
    [NoChildDiscFare1]          INT             NULL,
    [NoChildDiscFare2]          INT             NULL,
    [NoChildDiscFare3]          INT             NULL,
    [Railcard2]                 NVARCHAR (5)    NULL,
    [NoRailcard2]               INT             NULL,
    [Railcard3]                 NVARCHAR (5)    NULL,
    [NoRailcard3]               INT             NULL,
    [NoGroupTicketsFullFare]    INT             NULL,
    [NoGroupTicketsDiscFare]    INT             NULL,
    [FullGroupFare]             NUMERIC (6, 2)  NULL,
    [DiscGroupFare]             NUMERIC (6, 2)  NULL,
    [CreatedExtractNumber]      INT             NULL,
    [LastModifiedExtractNumber] INT             NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_Journey] PRIMARY KEY CLUSTERED ([JourneyID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_STG_Journey_AvailabilityCodeID] FOREIGN KEY ([AvailabilityCodeID]) REFERENCES [Reference].[AvailabilityCode] ([AvailabilityCodeID]),
    CONSTRAINT [FK_STG_Journey_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_Journey_FareSettingTOCID] FOREIGN KEY ([TOCIDPrimary]) REFERENCES [Reference].[FareSettingTOC] ([FareSettingTOCID]),
    CONSTRAINT [FK_STG_Journey_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_STG_Journey_LocationIDDestination] FOREIGN KEY ([LocationIDDestination]) REFERENCES [Reference].[Location] ([LocationID]),
    CONSTRAINT [FK_STG_Journey_LocationIDOrigin] FOREIGN KEY ([LocationIDOrigin]) REFERENCES [Reference].[Location] ([LocationID]),
    CONSTRAINT [FK_STG_Journey_SalesDetailID] FOREIGN KEY ([SalesDetailID]) REFERENCES [Staging].[STG_SalesDetail] ([SalesDetailID]),
    CONSTRAINT [FK_STG_Journey_TransactionID] FOREIGN KEY ([SalesTransactionID]) REFERENCES [Staging].[STG_SalesTransaction] ([SalesTransactionID])
);


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO


GO




CREATE NONCLUSTERED INDEX IX_STG_Journey_IsOutboundInd ON [Staging].[STG_Journey] ([IsOutboundInd],[CustomerID])

GO
CREATE NONCLUSTERED INDEX [IDX_STG_Journey_ExtReference]
    ON [Staging].[STG_Journey]([ExtReference] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [dba_nci_RetDepartureDateTime_Includes]
    ON [Staging].[STG_Journey]([RetDepartureDateTime] ASC)
    INCLUDE([CustomerID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [dba_nci_OutDepartureDateTime_Includes]
    ON [Staging].[STG_Journey]([OutDepartureDateTime] ASC)
    INCLUDE([CustomerID], [SalesDetailID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [DBA_NCI_IsOutboundInd_WithInclude]
    ON [Staging].[STG_Journey]([IsOutboundInd] ASC)
    INCLUDE([LocationIDOrigin], [OutDepartureDateTime], [IsReturnInd], [IsReturnInferredInd], [CustomerID], [SalesTransactionID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [dba_fnci_archiveInd_Includes]
    ON [Staging].[STG_Journey]([ArchivedInd] ASC)
    INCLUDE([JourneyID], [SalesDetailID]) WHERE ([ArchivedInd]=(0)) WITH (FILLFACTOR = 80);

