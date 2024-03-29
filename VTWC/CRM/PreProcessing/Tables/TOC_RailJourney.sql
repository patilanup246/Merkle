﻿CREATE TABLE [PreProcessing].[TOC_RailJourney] (
    [TOC_JourneyID]          INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustomerId]             INT            NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [DateUpdated]            DATETIME       NOT NULL,
    [ChannelCode]            NVARCHAR (6)   NOT NULL,
    [PurchaseId]             INT            NOT NULL,
    [TransactionId]          INT            NOT NULL,
    [TransactionDate]        DATETIME       NOT NULL,
    [BusinessOrLeisure]      NCHAR (1)      NULL,
    [JourneyId]              INT            NOT NULL,
    [ProCode]                NVARCHAR (10)  NULL,
    [JourneyReference]       NVARCHAR (8)   NOT NULL,
    [FareSettingToc]         NVARCHAR (8)   NULL,
    [OrigStation]            NVARCHAR (50)  NULL,
    [DestStation]            NVARCHAR (50)  NULL,
    [ViaStation]             NVARCHAR (50)  NULL,
    [ViaIndicator]           NCHAR (1)      NULL,
    [OutDateDep]             DATETIME       NULL,
    [OutDateArr]             DATETIME       NULL,
    [RetDateDep]             DATETIME       NULL,
    [RetDateArr]             DATETIME       NULL,
    [JourneyType]            NCHAR (1)      NULL,
    [SmokingPref]            NCHAR (1)      NULL,
    [DisabledInd]            NCHAR (1)      NULL,
    [TravellerName]          NVARCHAR (75)  NULL,
    [NoFullFareAdults]       INT            NULL,
    [NoDiscFareAdults]       INT            NULL,
    [NoFullFareChildren]     INT            NULL,
    [NoDiscFareChildren]     INT            NULL,
    [Railcard1]              NVARCHAR (5)   NULL,
    [NoRailcard1]            INT            NULL,
    [NoOfRailcards]          INT            NULL,
    [TotalAdults]            INT            NULL,
    [TotalChildren]          INT            NULL,
    [TotalReturningAdults]   INT            NULL,
    [TotalReturningChildren] INT            NULL,
    [CostOfTickets]          DECIMAL (8, 2) NULL,
    [TotalCost]              DECIMAL (8, 2) NULL,
    CONSTRAINT [cndx_PrimaryKey_TOC_Journey] PRIMARY KEY CLUSTERED ([TOC_JourneyID] ASC)
);

