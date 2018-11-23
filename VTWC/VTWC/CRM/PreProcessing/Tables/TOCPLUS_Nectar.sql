CREATE TABLE [PreProcessing].[TOCPLUS_Nectar] (
    [TOC_NectarID]        INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [nectarcardnumber]    NVARCHAR (50)  NULL,
    [trid]                BIGINT         NULL,
    [locationid]          NVARCHAR (15)  NULL,
    [trandatetime]        DATETIME       NULL,
    [tranamount]          NUMERIC (6, 2) NULL,
    [transtype]           NVARCHAR (5)   NULL,
    [CreatedDateETL]      DATETIME       NULL,
    [LastModifiedDateETL] DATETIME       NULL,
    [ProcessedInd]        BIT            NULL,
    [DataImportDetailID]  INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Nectar] PRIMARY KEY CLUSTERED ([TOC_NectarID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [idx_TOCPLUS_Nectar_DataImportDetailID]
    ON [PreProcessing].[TOCPLUS_Nectar]([DataImportDetailID] ASC) WITH (FILLFACTOR = 80);

