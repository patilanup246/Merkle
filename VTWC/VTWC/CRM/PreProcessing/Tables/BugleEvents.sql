CREATE TABLE [PreProcessing].[BugleEvents] (
    [BugleEventID]          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Start Date]            VARCHAR (512) NULL,
    [Description]           VARCHAR (512) NULL,
    [Train]                 VARCHAR (512) NULL,
    [Start Time]            VARCHAR (512) NULL,
    [Origin]                VARCHAR (512) NULL,
    [Dest]                  VARCHAR (512) NULL,
    [LocationSeq]           VARCHAR (512) NULL,
    [Location]              VARCHAR (512) NULL,
    [PublicTime]            VARCHAR (512) NULL,
    [PlannedActivity]       VARCHAR (512) NULL,
    [ActualTime]            VARCHAR (512) NULL,
    [ActualActivity]        VARCHAR (512) NULL,
    [PublicVar]             VARCHAR (512) NULL,
    [DelayJourneyEventInfo] VARCHAR (512) NULL,
    [LocationID]            INT           NULL,
    [LocationOriginID]      INT           NULL,
    [LocationDestinationID] INT           NULL,
    [CreatedDateETL]        DATETIME      NULL,
    [LastModifiedDateETL]   DATETIME      NULL,
    [ProcessedInd]          BIT           NULL,
    [DataImportDetailID]    INT           NULL
);




GO
CREATE NONCLUSTERED INDEX [ix_BugleEvents_PlannedActivity]
    ON [PreProcessing].[BugleEvents]([Start Date] ASC, [Train] ASC, [PlannedActivity] ASC)
    INCLUDE([Start Time], [Location]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_BugleEvents_Date_Activity]
    ON [PreProcessing].[BugleEvents]([BugleEventID] ASC)
    INCLUDE([Start Date], [Start Time], [PlannedActivity]);

