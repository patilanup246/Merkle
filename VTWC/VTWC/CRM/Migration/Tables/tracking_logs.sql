CREATE TABLE [Migration].[Tracking_Logs] (
    [log_id]                  BIGINT          NOT NULL,
    [tcs_customer_id]         BIGINT          NOT NULL,
    [delivery_id]             BIGINT          NOT NULL,
    [campaign_id]             BIGINT          NOT NULL,
    [log_date]                DATETIME        NULL,
    [category_url]            NVARCHAR (50)   NULL,
    [label_url]               NVARCHAR (1000) NULL,
    [url]                     NVARCHAR (1000) NULL,
    [response_type]           NVARCHAR (25)   NULL,
    [operating_system_icon]   NVARCHAR (25)   NULL,
    [operating_system_family] NVARCHAR (25)   NULL,
    [device_browser]          NVARCHAR (25)   NULL,
    [delivery_label]          NVARCHAR (200)  NULL,
    [campaign_label]          NVARCHAR (200)  NULL,
    [sent_date]               DATETIME        NULL,
    [date_loaded]             DATETIME        NULL,
    [last_modified]           DATETIME        NULL,
    [created_extract_number]  INT             NULL,
    [modified_extract_number] INT             NULL,
    PRIMARY KEY CLUSTERED ([log_id] ASC, [tcs_customer_id] ASC, [delivery_id] ASC, [campaign_id] ASC)
);
GO

