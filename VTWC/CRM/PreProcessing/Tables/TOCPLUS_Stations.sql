CREATE TABLE [PreProcessing].[TOCPLUS_Stations] (
    [TOCStationsID]         INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [code]                  NVARCHAR (5)  NULL,
    [name]                  NVARCHAR (50) NULL,
    [eff_from_date]         DATETIME      NULL,
    [eff_to_date]           DATETIME      NULL,
    [last_update_date_time] DATETIME      NULL,
    [county]                NVARCHAR (50) NULL,
    [postcode]              NVARCHAR (15) NULL,
    [group_station]         NVARCHAR (10) NULL,
    [CreatedDateETL]        DATETIME      NULL,
    [LastModifiedDateETL]   DATETIME      NULL,
    [ProcessedInd]          BIT           NULL,
    [DataImportDetailID]    INT           NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Stations] PRIMARY KEY CLUSTERED ([TOCStationsID] ASC)
);



