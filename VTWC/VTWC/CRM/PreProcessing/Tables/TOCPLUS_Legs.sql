CREATE TABLE [PreProcessing].[TOCPLUS_Legs] (
    [TOC_LegsID]          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [operator]            NVARCHAR (3)  NULL,
    [jl_id]               BIGINT        NULL,
    [coach]               NCHAR (1)     NULL,
    [seat_number]         NVARCHAR (10) NULL,
    [quiet_coach]         NCHAR (1)     NULL,
    [DateCreated]         DATETIME      NULL,
    [DateUpdated]         DATETIME      NULL,
    [CreatedDateETL]      DATETIME      NULL,
    [LastModifiedDateETL] DATETIME      NULL,
    [ProcessedInd]        BIT           NULL,
    [DataImportDetailID]  INT           NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Legs] PRIMARY KEY CLUSTERED ([TOC_LegsID] ASC)
);
GO

