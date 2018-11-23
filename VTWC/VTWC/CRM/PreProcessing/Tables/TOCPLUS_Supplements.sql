CREATE TABLE [PreProcessing].[TOCPLUS_Supplements] (
    [TOCSupplementsID]    INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SupplementID]        BIGINT         NULL,
    [TCSBookingID]        BIGINT         NULL,
    [TCSTransactionId]    BIGINT         NULL,
    [SupplementTypeCode]  NVARCHAR (5)   NULL,
    [SupplementTypeDesc]  NVARCHAR (50)  NULL,
    [AppliesTo]           NVARCHAR (5)   NULL,
    [Cost]                NUMERIC (6, 2) NULL,
    [Quantity]            INT            NULL,
    [TotalCost]           NUMERIC (6, 2) NULL,
    [Zone]                NVARCHAR (50)  NULL,
    [DateUpdated]         DATETIME       NULL,
    [DateCreated]         DATETIME       NULL,
    [CreatedDateETL]      DATETIME       NULL,
    [LastModifiedDateETL] DATETIME       NULL,
    [ProcessedInd]        BIT            NULL,
    [DataImportDetailID]  INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Supplements] PRIMARY KEY CLUSTERED ([TOCSupplementsID] ASC)
);



