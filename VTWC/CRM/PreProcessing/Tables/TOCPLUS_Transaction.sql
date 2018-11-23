﻿CREATE TABLE [PreProcessing].[TOCPLUS_Transaction] (
    [TOCTransactionID]        INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [cmdtransactionid]        BIGINT         NULL,
    [tcstransactionid]        BIGINT         NULL,
    [tcscustomerid]           BIGINT         NULL,
    [businessorleisure]       NCHAR (1)      NULL,
    [retailercode]            NVARCHAR (25)  NULL,
    [transactiondate]         DATETIME       NULL,
    [totalnoofallpurchases]   INT            NULL,
    [totalcostofallpurchases] NUMERIC (6, 2) NULL,
    [internationalflag]       NCHAR (1)      NULL,
    [hotelbookingcost]        NUMERIC (6, 2) NULL,
    [originatingsystem]       NVARCHAR (15)  NULL,
    [originatingsystemtype]   NVARCHAR (20)  NULL,
    [cmddateupdated]          DATETIME       NULL,
    [paymenttype]             NVARCHAR (5)   NULL,
    [cardtype]                NVARCHAR (15)  NULL,
    [voucherused]             NVARCHAR (3)   NULL,
    [affiliatecode]           NVARCHAR (10)  NULL,
    [corporateorleisure]      NVARCHAR (20)  NULL,
    [operatingsystem]         NVARCHAR (20)  NULL,
    [mobiledevice]            NVARCHAR (255)  NULL,
    [channelcode]             NVARCHAR (25)  NULL,
    [DateCreated]             DATETIME       NULL,
    [DateUpdated]             DATETIME       NULL,
    [PaymentTypeDesc]         NVARCHAR (50)  NULL,
    [CreatedDateETL]          DATETIME       NULL,
    [LastModifiedDateETL]     DATETIME       NULL,
    [ProcessedInd]            BIT            NULL,
    [DataImportDetailID]      INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Transaction] PRIMARY KEY CLUSTERED ([TOCTransactionID] ASC)
);




GO
CREATE NONCLUSTERED INDEX idx_TOCPLUS_Transaction_DataImportDetailID
ON [PreProcessing].[TOCPLUS_Transaction] ([DataImportDetailID])
INCLUDE ([originatingsystem],[originatingsystemtype],[CreatedDateETL],[ProcessedInd])
GO

CREATE NONCLUSTERED INDEX idx2_TOCPLUS_Transaction
ON [PreProcessing].[TOCPLUS_Transaction] ([ProcessedInd],[DataImportDetailID],[tcscustomerid])
INCLUDE ([TOCTransactionID],[tcstransactionid],[transactiondate],[totalcostofallpurchases],[originatingsystemtype],[paymenttype],[cardtype],[voucherused],[channelcode],[DateCreated],[DateUpdated])
GO
CREATE NONCLUSTERED INDEX idx3_TOCPLUS_Transaction
ON [PreProcessing].[TOCPLUS_Transaction] ([ProcessedInd],[DataImportDetailID],[tcstransactionid],[tcscustomerid])
INCLUDE ([TOCTransactionID],[transactiondate],[totalcostofallpurchases],[originatingsystemtype],[paymenttype],[cardtype],[voucherused],[channelcode],[DateCreated],[DateUpdated])

GO