CREATE TABLE [PreProcessing].[TOCPLUS_Bookings] (
    [TOCBookingsID]       INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [purchaseid]          BIGINT         NULL,
    [tcstransactionid]    BIGINT         NULL,
    [tcscustomerid]       BIGINT         NULL,
    [purchasecode]        NVARCHAR (10)  NULL,
    [transactiondate]     DATETIME       NULL,
    [purchasevalue]       NUMERIC (6, 2) NULL,
    [noofitems]           INT            NULL,
    [purchasedate]        DATETIME       NULL,
    [businessorleisure]   NCHAR (1)      NULL,
    [refundind]           NCHAR (1)      NULL,
    [amendedind]          NCHAR (1)      NULL,
    [refunddate]          DATETIME       NULL,
    [amendeddate]         DATETIME       NULL,
    [cmddateupdated]      DATETIME       NULL,
    [CreatedDateETL]      DATETIME       NULL,
    [LastModifiedDateETL] DATETIME       NULL,
    [ProcessedInd]        BIT            NULL,
    [DataImportDetailID]  INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Bookings] PRIMARY KEY CLUSTERED ([TOCBookingsID] ASC)
);
GO
CREATE NONCLUSTERED INDEX [idx_TOCPLUS_Bookings_ProcessedInd_DataImportDetailID] ON [PreProcessing].[TOCPLUS_Bookings]
(
	[ProcessedInd] ASC,
	[DataImportDetailID] ASC
)
INCLUDE ( 	[TOCBookingsID],
	[purchaseid],
	[tcstransactionid],
	[tcscustomerid],
	[purchasecode],
	[transactiondate],
	[purchasevalue],
	[noofitems],
	[businessorleisure],
	[refundind],
	[amendedind],
	[refunddate],
	[cmddateupdated]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

GO
CREATE NONCLUSTERED INDEX [idx2_TOCPLUS_Bookings_DataImportDetailID] ON [PreProcessing].[TOCPLUS_Bookings]
(
	[DataImportDetailID] ASC
)
INCLUDE ( 	[TOCBookingsID],
	[purchaseid],
	[ProcessedInd],
	[CreatedDateETL]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


