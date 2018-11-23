CREATE TABLE [Migration].[Broad_Log] (
    [delivery_log_id]         BIGINT         NOT NULL,
    [tcs_customer_id]         BIGINT         NULL,
    [delivery_id]             BIGINT         NULL,
    [campaign_id]             BIGINT         NULL,
    [ttl_segment]             NVARCHAR (100) NULL,
    [cell_code]               NVARCHAR (50)  NULL,
    [vt_segment_code]         NVARCHAR (25)  NULL,
    [control_population]      INT            NULL,
    [seed]                    INT            NULL,
    [delivery_label]          NVARCHAR (100) NULL,
    [status]                  NVARCHAR (50)  NULL,
    [reason]                  NVARCHAR (50)  NULL,
    [error_discription]       NVARCHAR (100) NULL,
    [campaign_label]          NVARCHAR (100) NULL,
    [category]                NVARCHAR (50)  NULL,
    [sent_date]               DATETIME       NULL,
    [program]                 NVARCHAR (50)  NULL,
    [folder]                  NVARCHAR (50)  NULL,
    [last_modified]           DATETIME       NULL,
    [date_loaded]             DATETIME       NULL,
    [created_extract_number]  INT            NULL,
    [modified_extract_number] INT            NULL,
    PRIMARY KEY CLUSTERED ([delivery_log_id] ASC)
);
GO

