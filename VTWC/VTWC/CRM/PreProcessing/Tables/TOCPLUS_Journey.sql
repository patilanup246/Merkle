﻿CREATE TABLE [PreProcessing].[TOCPLUS_Journey] (
    [TOC_JourneyID]             INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [journeyid]                 BIGINT         NULL,
    [purchaseid]                BIGINT         NULL,
    [tcscustomerid]             BIGINT         NULL,
    [tcstransactionid]          BIGINT         NULL,
    [tcsbookingid]              BIGINT         NULL,
    [transactiondate]           DATETIME       NULL,
    [channelcode]               NVARCHAR (15)  NULL,
    [businessorleisure]         NCHAR (1)      NULL,
    [faresettingtoc]            NVARCHAR (3)   NULL,
    [origstation]               NVARCHAR (50)  NULL,
    [deststation]               NVARCHAR (50)  NULL,
    [reasonfortravel]           NVARCHAR (50)  NULL,
    [outdatedep]                DATETIME       NULL,
    [outdatearr]                DATETIME       NULL,
    [retdatedep]                DATETIME       NULL,
    [retdatearr]                DATETIME       NULL,
    [journeytype]               NCHAR (1)      NULL,
    [travellername]             NVARCHAR (100) NULL,
    [railcarddesc]              NVARCHAR (50)  NULL,
    [railcard1]                 NVARCHAR (5)   NULL,
    [noofrailcards]             INT            NULL,
    [totaladults]               INT            NULL,
    [totalchildren]             INT            NULL,
    [totalreturningadults]      INT            NULL,
    [totalreturningchildren]    INT            NULL,
    [costoftickets]             NUMERIC (6, 2) NULL,
    [totalcost]                 NUMERIC (6, 2) NULL,
    [savingsmade]               NUMERIC (6, 2) NULL,
    [procode]                   NVARCHAR (15)  NULL,
    [tickettypecode]            NVARCHAR (5)   NULL,
    [tickettypedesc]            NVARCHAR (50)  NULL,
    [deliverymethodcode]        NVARCHAR (20)  NULL,
    [deliverymethoddescription] NVARCHAR (50)  NULL,
    [journeydirection]          NVARCHAR (5)   NULL,
    [journeyreference]          NVARCHAR (20)  NULL,
    [cmddateupdated]            DATETIME       NULL,
    [class]                     NCHAR (1)      NULL,
    [origstationcode]           NVARCHAR (5)   NULL,
    [deststationcode]           NVARCHAR (5)   NULL,
    [outboundmileage]           NUMERIC (6, 2) NULL,
    [availabilitycode]          NVARCHAR (5)   NULL,
    [DisabledInd]               NCHAR (1)      NULL,
    [NoFullFareAdults]          INT            NULL,
    [NoDiscFareAdults]          INT            NULL,
    [NoFullFareChildren]        INT            NULL,
    [NoDiscFareChildren]        INT            NULL,
    [DateCreated]               DATETIME       NULL,
    [DateUpdated]               DATETIME       NULL,
    [FareId]                    INT            NULL,
    [PromoCode]                 NVARCHAR (30)  NULL,
    [FullAdultFare]             NUMERIC (6, 2) NULL,
    [DiscAdultFare1]            NUMERIC (6, 2) NULL,
    [DiscAdultFare2]            NUMERIC (6, 2) NULL,
    [DiscAdultFare3]            NUMERIC (6, 2) NULL,
    [FullChildFare]             NUMERIC (6, 2) NULL,
    [DiscChildFare1]            NUMERIC (6, 2) NULL,
    [DiscChildFare2]            NUMERIC (6, 2) NULL,
    [DiscChildFare3]            NUMERIC (6, 2) NULL,
    [NoAdultsFullFare]          INT            NULL,
    [NoAdultsDiscFare1]         INT            NULL,
    [NoAdultsDiscFare2]         INT            NULL,
    [NoAdultsDiscFare3]         INT            NULL,
    [NoChildFullFare]           INT            NULL,
    [NoChildDiscFare1]          INT            NULL,
    [NoChildDiscFare2]          INT            NULL,
    [NoChildDiscFare3]          INT            NULL,
    [NoRailcard1]               INT            NULL,
    [Railcard2]                 NVARCHAR (5)   NULL,
    [NoRailcard2]               INT            NULL,
    [Railcard3]                 NVARCHAR (5)   NULL,
    [NoRailcard3]               INT            NULL,
    [NoGroupTicketsFullFare]    INT            NULL,
    [NoGroupTicketsDiscFare]    INT            NULL,
    [FullGroupFare]             NUMERIC (6, 2) NULL,
    [DiscGroupFare]             NUMERIC (6, 2) NULL,
    [Railcard2Desc]             NVARCHAR (50)  NULL,
    [Railcard3Desc]             NVARCHAR (50)  NULL,
    [FareSettingTOCDesc]        NVARCHAR (50)  NULL,
    [AvailabilityCodeDesc]      NVARCHAR (50)  NULL,
    [CreatedDateETL]            DATETIME       NULL,
    [LastModifiedDateETL]       DATETIME       NULL,
    [ProcessedInd]              BIT            NULL,
    [DataImportDetailID]        INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Journey] PRIMARY KEY CLUSTERED ([TOC_JourneyID] ASC)
);


