CREATE TABLE [PreProcessing].[TOCPLUS_NAS_Push_Responses] (
    [TOCPLUS_NAS_Push_ResponsesID] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [JourneyID]                    INT            NOT NULL,
    [EmailAddress]                 NVARCHAR (100) NULL,
    [NASScore]                     INT            NULL,
    [1]                            INT            NULL,
    [2]                            INT            NULL,
    [3]                            INT            NULL,
    [4]                            INT            NULL,
    [5]                            INT            NULL,
    [7]                            INT            NULL,
    [8]                            INT            NULL,
    [9]                            INT            NULL,
    [10]                           INT            NULL,
    [11]                           INT            NULL,
    [12]                           INT            NULL,
    [14]                           INT            NULL,
    [15]                           INT            NULL,
    [16]                           INT            NULL,
    [17]                           INT            NULL,
    [CreatedDateETL]               DATETIME       NULL,
    [LastModifiedDateETL]          DATETIME       NULL,
    [ProcessedInd]                 BIT            NULL,
    [DataImportDetailID]           INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_NAS_Push_Responses] PRIMARY KEY CLUSTERED ([TOCPLUS_NAS_Push_ResponsesID] ASC)
);
GO

