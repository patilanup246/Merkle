CREATE TABLE [PreProcessing].[TOCPLUS_JourneyLegs] (
    [TOC_JourneyLegsID]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [legid]               BIGINT        NULL,
    [journeyid]           BIGINT        NULL,
    [tcscustomerid]       BIGINT        NULL,
    [transactiondate]     DATETIME      NULL,
    [legno]               INT           NULL,
    [legorigstation]      NVARCHAR (50) NULL,
    [legdeststation]      NVARCHAR (50) NULL,
    [depdatetime]         DATETIME      NULL,
    [arrdatetime]         DATETIME      NULL,
    [modeoftransport]     NVARCHAR (3)  NULL,
    [seatreserved]        NCHAR (1)     NULL,
    [seatingclass]        NCHAR (1)     NULL,
    [reservationrequired] NVARCHAR (3)  NULL,
    [operatorcode]        NVARCHAR (3)  NULL,
    [operatortype]        NVARCHAR (10) NULL,
    [operatordescription] NVARCHAR (75) NULL,
    [retailtrainid]       NVARCHAR (10) NULL,
    [tcstransactionid]    BIGINT        NULL,
    [cmddateupdated]      DATETIME      NULL,
    [legorigstationcode]  NVARCHAR (50) NULL,
    [legdeststationcode]  NVARCHAR (50) NULL,
    [coach]               NCHAR (1)     NULL,
    [seat]                NVARCHAR (20) NULL,
    [quietzoneyn]         NCHAR (1)     NULL,
    [trainuid]            NVARCHAR (20) NULL,
    [jltype]              NCHAR (1)     NULL,
    [CMDDateCreated]      DATETIME      NULL,
    [FareSettingTOCDesc]  NVARCHAR (50) NULL,
    [ModeOfTransportDesc] NVARCHAR (50) NULL,
    [SeatingClassDesc]    NVARCHAR (50) NULL,
    [SeatReservedDesc]    NVARCHAR (50) NULL,
    [OperatorCodeDesc]    NVARCHAR (50) NULL,
    [CreatedDateETL]      DATETIME      NULL,
    [LastModifiedDateETL] DATETIME      NULL,
    [ProcessedInd]        BIT           NULL,
    [DataImportDetailID]  INT           NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_JourneyLegs] PRIMARY KEY CLUSTERED ([TOC_JourneyLegsID] ASC)
);
GO

CREATE NONCLUSTERED INDEX [idx_TOCPLUS_JourneyLegs_DataImportDetailID] ON [PreProcessing].[TOCPLUS_JourneyLegs]
(
	[DataImportDetailID] ASC
)
INCLUDE ( 	[TOC_JourneyLegsID],
	[legid],
	[modeoftransport],
	[ModeOfTransportDesc],
	[seatingclass],
	[SeatingClassDesc],
	[operatorcode],
	[OperatorCodeDesc]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [idx2_TOCPLUS_JourneyLegs_ProcessedInd_DataImportDetailID] ON [PreProcessing].[TOCPLUS_JourneyLegs]
(
	[ProcessedInd] ASC,
	[DataImportDetailID] ASC
)
INCLUDE ( 	[TOC_JourneyLegsID],
	[legid],
	[journeyid],
	[legno],
	[depdatetime],
	[arrdatetime],
	[modeoftransport],
	[seatingclass],
	[operatorcode],
	[retailtrainid],
	[cmddateupdated],
	[legorigstationcode],
	[legdeststationcode],
	[coach],
	[seat],
	[quietzoneyn],
	[trainuid],
	[jltype],
	[CMDDateCreated]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [idx3_TOCPLUS_JourneyLegs]
ON [PreProcessing].[TOCPLUS_JourneyLegs] ([DataImportDetailID])
INCLUDE ([CreatedDateETL],[ProcessedInd])
GO