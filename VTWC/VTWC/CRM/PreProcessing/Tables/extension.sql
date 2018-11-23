﻿CREATE TABLE [PreProcessing].[extension] (
    [tcs_customer_id]                                        BIGINT         NULL,
    [current_segment_vt_customer_extension]                  NVARCHAR (255) NULL,
    [customer_form_frequency_vt_customer_extension]          NVARCHAR (255) NULL,
    [customer_form_preferred_station_vt_customer_extension]  NVARCHAR (255) NULL,
    [customer_form_purchasing_tickets_vt_customer_extension] NVARCHAR (255) NULL,
    [customer_form_railcard_vt_customer_extension]           NVARCHAR (255) NULL,
    [nursery_added_date_vt_customer_extension]               NVARCHAR (255) NULL,
    [nursery_control_vt_customer_extension]                  NVARCHAR (255) NULL,
    [nursery_dropout_date_vt_customer_extension]             NVARCHAR (255) NULL,
    [nursery_status_vt_customer_extension]                   NVARCHAR (255) NULL,
    [nursery_stream_vt_customer_extension]                   NVARCHAR (255) NULL,
    [nursery_travel_date_vt_customer_extension]              NVARCHAR (255) NULL,
    [pin_code_vt_customer_extension]                         NVARCHAR (255) NULL,
    [pin_expiry_vt_customer_extension]                       NVARCHAR (255) NULL,
    [propensity_to_buy_vt_customer_extension]                NVARCHAR (255) NULL,
    [reengagement_flag_vt_customer_extension]                NVARCHAR (255) NULL,
    [salutation_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m1_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m2_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m3_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m4_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m5_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m6_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m7_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m8_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m9_vt_customer_extension]                       NVARCHAR (255) NULL,
    [segment_m10_vt_customer_extension]                      NVARCHAR (255) NULL,
    [segment_m11_vt_customer_extension]                      NVARCHAR (255) NULL,
    [segment_m12_vt_customer_extension]                      NVARCHAR (255) NULL,
    [softoptinrof_vt_customer_extension]                     NVARCHAR (255) NULL,
    [traveller_expiry_vt_customer_extension]                 NVARCHAR (255) NULL,
    [traveller_from_vt_customer_extension]                   NVARCHAR (255) NULL,
    [traveller_no_vt_customer_extension]                     BIGINT         NULL,
    [traveller_salutation_vt_customer_extension]             NVARCHAR (255) NULL,
    [traveller_status_vt_customer_extension]                 NVARCHAR (255) NULL,
    [virghin_insight_segment_vt_customer_extension]          BIGINT         NULL,
    [vt_perm_control_vt_customer_extension]                  NVARCHAR (255) NULL,
    [vt_red_matched_date_vt_customer_extension]              NVARCHAR (255) NULL,
    [vt_red_segment_vt_customer_extension]                   BIGINT         NULL,
    [CreatedDateETL]                                         DATETIME       NULL,
    [LastModifiedDateETL]                                    DATETIME       NULL,
    [ProcessedInd]                                           BIT            NULL,
    [DataImportDetailID]                                     INT            NULL
);
GO

