CREATE TABLE [Migration].[Delivery] (
    [primary_key]                             BIGINT         NOT NULL,
    [category_campaign]                       NVARCHAR (25)  NULL,
    [date_only_contact_date]                  DATETIME       NULL,
    [delivered]                               BIGINT         NULL,
    [opt_out]                                 BIGINT         NULL,
    [refused]                                 BIGINT         NULL,
    [sent_success]                            BIGINT         NULL,
    [total_count_of_opens]                    BIGINT         NULL,
    [total_number_of_clicks]                  BIGINT         NULL,
    [unique_clicks_persons_who_have_clicked]  BIGINT         NULL,
    [unique_opens_recipients_who_have_opened] BIGINT         NULL,
    [campaign_name]                           NVARCHAR (100) NULL,
    [date_loaded]                             DATETIME       NULL,
    [last_modified]                           DATETIME       NULL,
    [created_extract_number]                  INT            NULL,
    [modified_extract_number]                 INT            NULL,
    PRIMARY KEY CLUSTERED ([primary_key] ASC)
);
GO

