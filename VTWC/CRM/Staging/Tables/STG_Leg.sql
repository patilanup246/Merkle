CREATE TABLE [Staging].[STG_Leg] (
    [ID]                        INT            IDENTITY (1, 1) NOT NULL,
    [JourneyLegID]              INT            NOT NULL,
    [LegID]                     BIGINT         NOT NULL,
    [CreatedDate]               DATETIME       NOT NULL,
    [CreatedBy]                 INT            NOT NULL,
    [LastModifiedDate]          DATETIME       NOT NULL,
    [LastModifiedBy]            INT            NOT NULL,
    [ArchivedInd]               BIT            DEFAULT ((0)) NOT NULL,
    [SeatReservation]           NVARCHAR (256) NULL,
    [QuietZone]                 NCHAR (1)      NULL,
    [InformationSourceID]       INT            NULL,
    [SourceCreatedDate]         DATETIME       NULL,
    [SourceModifiedDate]        DATETIME       NULL,
    [CreatedExtractNumber]      INT            NULL,
    [LastModifiedExtractNumber] INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_Leg] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_STG_Leg_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_STG_Leg_JourneyLegID] FOREIGN KEY ([JourneyLegID]) REFERENCES [Staging].[STG_JourneyLeg] ([JourneyLegID])
);
GO

CREATE NONCLUSTERED INDEX idx_STG_Leg_JourneyLegID_LegID
ON [Staging].[STG_Leg] ([JourneyLegID],[LegID])

GO

CREATE NONCLUSTERED INDEX idx2_STG_Leg_LegID
ON [Staging].[STG_Leg] ([LegID])

GO