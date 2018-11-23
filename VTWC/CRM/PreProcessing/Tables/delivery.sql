CREATE TABLE [PreProcessing].[delivery] (
    [primary_key]                             BIGINT         NULL,
    [category_campaign]                       NVARCHAR (255) NULL,
    [date_only_contact_date]                  DATETIME       NULL,
    [delivered]                               BIGINT         NULL,
    [opt_out]                                 BIGINT         NULL,
    [refused]                                 BIGINT         NULL,
    [sent_success]                            BIGINT         NULL,
    [total_count_of_opens]                    BIGINT         NULL,
    [total_number_of_clicks]                  BIGINT         NULL,
    [unique_clicks_persons_who_have_clicked]  BIGINT         NULL,
    [unique_opens_recipients_who_have_opened] BIGINT         NULL,
    [campaign_name]                           NVARCHAR (255) NULL,
    [CreatedDateETL]                          DATETIME       NULL,
    [LastModifiedDateETL]                     DATETIME       NULL,
    [ProcessedInd]                            BIT            NULL,
    [DataImportDetailID]                      INT            NULL
);
GO

