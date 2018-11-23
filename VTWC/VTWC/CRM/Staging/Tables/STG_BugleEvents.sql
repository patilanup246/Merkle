CREATE TABLE [Staging].[STG_BugleEvents] (
    [BugleEventID]          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CreatedDate]           DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]             INT           DEFAULT ((0)) NOT NULL,
    [LastModifiedDate]      DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastModifiedBy]        INT           DEFAULT ((0)) NOT NULL,
    [ArchivedInd]           BIT           DEFAULT ((0)) NOT NULL,
    [StartDate]             DATE          NOT NULL,
    [StartTime]             TIME (7)      NOT NULL,
    [TrainID]               VARCHAR (4)   NULL,
    [Description]           VARCHAR (512) NULL,
    [LocationOriginID]      INT           NULL,
    [LocationDestinationID] INT           NULL,
    [LocationID]            INT           NULL,
    [LocationSeq]           INT           NULL,
    [PlannedActivity]       VARCHAR (1)   NOT NULL,
    [PublicTime]            TIME (7)      NULL,
    [ActualTime]            TIME (7)      NULL,
    [ActualActivity]        VARCHAR (512) NULL,
    [PublicVar]             INT           NOT NULL,
    [DelayJourneyEventInfo] VARCHAR (512) NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_STG_BugleEvents_StartDate_TrainID]
    ON [Staging].[STG_BugleEvents]([StartDate] ASC, [TrainID] ASC, [PlannedActivity] ASC)
    INCLUDE([BugleEventID], [StartTime], [Description], [LocationOriginID], [LocationDestinationID], [LocationID], [LocationSeq], [PublicTime], [ActualTime], [ActualActivity], [PublicVar], [DelayJourneyEventInfo]);


GO
CREATE NONCLUSTERED INDEX [ix_STG_BugleEvents_Activity_PublicVar]
    ON [Staging].[STG_BugleEvents]([PlannedActivity] ASC, [PublicVar] ASC)
    INCLUDE([StartDate], [TrainID], [LocationID]);

