CREATE TABLE [PreProcessing].[TOCPLUS_NAS_Questions] (
    [TOCPLUS_NAS_QuestionID] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [QuestionId]             INT            NULL,
    [QuestionText]           NVARCHAR (MAX) NULL,
    [CreatedDateETL]         DATETIME       NULL,
    [LastModifiedDateETL]    DATETIME       NULL,
    [ProcessedInd]           BIT            NULL,
    [DataImportDetailID]     INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_NAS_Question] PRIMARY KEY CLUSTERED ([TOCPLUS_NAS_QuestionID] ASC)
);
GO

