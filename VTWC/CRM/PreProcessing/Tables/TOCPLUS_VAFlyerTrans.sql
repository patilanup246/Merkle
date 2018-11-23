CREATE TABLE [PreProcessing].[TOCPLUS_VAFlyerTrans] (
    [TOCVAFlyerTransID]       INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [tr_id]                   BIGINT         NULL,
    [mem_number]              BIGINT         NULL,
    [ticket_class]            NVARCHAR (5)   NULL,
    [total_cost_rail_revenue] NUMERIC (6, 2) NULL,
    [amount_points]           BIGINT         NULL,
    [out_date]                DATETIME       NULL,
    [CreatedDateETL]          DATETIME       NULL,
    [LastModifiedDateETL]     DATETIME       NULL,
    [ProcessedInd]            BIT            NULL,
    [DataImportDetailID]      INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_VAFlyerTrans] PRIMARY KEY CLUSTERED ([TOCVAFlyerTransID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [idx_TOCPLUS_VAFlyerTrans_DataImportDetailID]
    ON [PreProcessing].[TOCPLUS_VAFlyerTrans]([DataImportDetailID] ASC) INCLUDE ([CreatedDateETL],[ProcessedInd]) WITH (FILLFACTOR = 80);

