CREATE TABLE [PreProcessing].[TOCPLUS_Traveller] (
    [TOCTravellerID]         INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [loyalty_membership_num] NVARCHAR (50) NULL,
    [eff_to_date]            DATETIME      NULL,
    [eff_from_date]          DATETIME      NULL,
    [status]                 NCHAR (1)     NULL,
    [cu_id]                  BIGINT        NULL,
    [CreatedDateETL]         DATETIME      NULL,
    [LastModifiedDateETL]    DATETIME      NULL,
    [ProcessedInd]           BIT           NULL,
    [DataImportDetailID]     INT           NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Traveller] PRIMARY KEY CLUSTERED ([TOCTravellerID] ASC)
);



