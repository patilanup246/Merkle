CREATE TABLE [PreProcessing].[tracking_logs] (
    [log_id]                  BIGINT          NULL,
    [tcs_customer_id]         BIGINT          NULL,
    [delivery_id]             BIGINT          NULL,
    [campaign_id]             BIGINT          NULL,
    [log_date]                DATETIME        NULL,
    [category_url]            NVARCHAR (255)  NULL,
    [label_url]               NVARCHAR (4000) NULL,
    [url]                     NVARCHAR (4000) NULL,
    [response_type]           NVARCHAR (255)  NULL,
    [operating_system_icon]   NVARCHAR (255)  NULL,
    [operating_system_family] NVARCHAR (255)  NULL,
    [device_browser]          NVARCHAR (255)  NULL,
    [delivery_label]          NVARCHAR (255)  NULL,
    [campaign_label]          NVARCHAR (255)  NULL,
    [sent_date]               DATETIME        NULL,
    [CreatedDateETL]          DATETIME        NULL,
    [LastModifiedDateETL]     DATETIME        NULL,
    [ProcessedInd]            BIT             NULL,
    [DataImportDetailID]      INT             NULL
);
GO

