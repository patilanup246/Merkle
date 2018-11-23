CREATE TABLE [PreProcessing].[TOCPlus_ADRCash] (
    [TOCPlus_ADRCashID]   INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [sTransactionId]      BIGINT         NULL,
    [sTracsTrid]          BIGINT         NULL,
    [iTotalDelayMinutes]  BIGINT         NULL,
    [sADRGroup]           NVARCHAR (10)  NULL,
    [fRefundAmount]       NUMERIC (6, 2) NULL,
    [sDepartureStation]   NVARCHAR (100) NULL,
    [sDestinationStation] NVARCHAR (100) NULL,
    [dtScheduledDepart]   DATETIME       NULL,
    [dtScheduledArrive]   DATETIME       NULL,
    [dtProcessed]         DATETIME       NULL,
    [sVTCaseNumber]       NVARCHAR (20)  NULL,
    [sJourneyReference]   BIGINT         NULL,
    [CreatedDateETL]      DATETIME       NULL,
    [LastModifiedDateETL] DATETIME       NULL,
    [ProcessedInd]        BIT            NULL,
    [DataImportDetailID]  INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPlus_ADRCash] PRIMARY KEY CLUSTERED ([TOCPlus_ADRCashID] ASC)
);
GO

