CREATE TABLE [Migration].[broad_log] (
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
    [error_description]       NVARCHAR (100) NULL,
    [campaign_label]          NVARCHAR (100) NULL,
    [category]                NVARCHAR (50)  NULL,
    [sent_date]               DATETIME       NULL,
    [program]                 NVARCHAR (50)  NULL,
    [folder]                  NVARCHAR (50)  NULL,
    [last_modified]           DATETIME       NULL,
    [date_loaded]             DATETIME       DEFAULT (getdate()) NULL,
    [FeedFileKey]             INT            NULL,
    [created_extract_number]  INT            NULL,
    [modified_extract_number] INT            NULL,
    PRIMARY KEY CLUSTERED ([delivery_log_id] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [nci_dba_satus_reason_tcscustomerid_INCLUDES_controlpopulation]
    ON [Migration].[broad_log]([status] ASC, [reason] ASC, [tcs_customer_id] ASC)
    INCLUDE([control_population]) WITH (FILLFACTOR = 80);

