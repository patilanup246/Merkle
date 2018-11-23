CREATE TABLE [PreProcessing].[broad_log] (
    [delivery_log_id]     BIGINT         NULL,
    [tcs_customer_id]     BIGINT         NULL,
    [delivery_id]         BIGINT         NULL,
    [campaign_id]         BIGINT         NULL,
    [ttl_segment]         NVARCHAR (255) NULL,
    [cell_code]           NVARCHAR (255) NULL,
    [vt_segment_code]     NVARCHAR (255) NULL,
    [control_population]  INT            NULL,
    [seed]                INT            NULL,
    [delivery_label]      NVARCHAR (255) NULL,
    [status]              NVARCHAR (255) NULL,
    [reason]              NVARCHAR (255) NULL,
    [error_discription]   NVARCHAR (255) NULL,
    [campaign_label]      NVARCHAR (255) NULL,
    [category]            NVARCHAR (255) NULL,
    [sent_date]           DATETIME       NULL,
    [program]             NVARCHAR (255) NULL,
    [folder]              NVARCHAR (255) NULL,
    [last_modified]       DATETIME       NULL,
    [CreatedDateETL]      DATETIME       NULL,
    [LastModifiedDateETL] DATETIME       NULL,
    [ProcessedInd]        BIT            NULL,
    [DataImportDetailID]  INT            NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_ProcessedInd_DataImportDetailID]
    ON [PreProcessing].[broad_log]([ProcessedInd] ASC, [DataImportDetailID] ASC)
    INCLUDE([delivery_log_id], [tcs_customer_id], [delivery_id], [campaign_id], [ttl_segment], [cell_code], [vt_segment_code], [control_population], [seed], [delivery_label], [status], [reason], [error_discription], [campaign_label], [category], [sent_date], [program], [folder], [last_modified], [CreatedDateETL]) WITH (FILLFACTOR = 80);

