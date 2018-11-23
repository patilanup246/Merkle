CREATE TABLE [PreProcessing].[TOCPLUS_FallowGroups] (
    [TOC_FallowGroupsID]       INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [cu_id]                    BIGINT        NULL,
    [control_flag]             NVARCHAR (50) NULL,
    [registered_retailer_code] NVARCHAR (5)  NULL,
    [control_date]             DATETIME      NULL,
    [expired_date]             DATETIME      NULL,
    [CreatedDateETL]           DATETIME      NULL,
    [LastModifiedDateETL]      DATETIME      NULL,
    [ProcessedInd]             BIT           NULL,
    [DataImportDetailID]       INT           NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_FallowGroups] PRIMARY KEY CLUSTERED ([TOC_FallowGroupsID] ASC)
);



