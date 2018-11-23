CREATE TABLE [PreProcessing].[TOCPLUS_MobileTickets] (
    [TOC_MobileTicketsID] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TCSBookingID]        BIGINT        NULL,
    [AVFTicketID]         NVARCHAR (20) NULL,
    [AVFBookingID]        BIGINT        NULL,
    [Direction]           NCHAR (1)     NULL,
    [NrsCode]             NVARCHAR (20) NULL,
    [BookedAt]            DATETIME      NULL,
    [Price]               INT           NULL,
    [PassengerType]       NVARCHAR (20) NULL,
    [TravelClass]         NVARCHAR (20) NULL,
    [ValidFrom]           DATETIME      NULL,
    [ValidUntil]          DATETIME      NULL,
    [IdTypeCode]          NVARCHAR (20) NULL,
    [Islead]              NCHAR (1)     NULL,
    [PassengerIndex]      INT           NULL,
    [PairId]              NVARCHAR (20) NULL,
    [DirectionOfPair]     NCHAR (1)     NULL,
    [AvfDateCreated]      DATETIME      NULL,
    [CreatedDateETL]      DATETIME      NULL,
    [LastModifiedDateETL] DATETIME      NULL,
    [ProcessedInd]        BIT           NULL,
    [DataImportDetailID]  INT           NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_MobileTickets] PRIMARY KEY CLUSTERED ([TOC_MobileTicketsID] ASC)
);



