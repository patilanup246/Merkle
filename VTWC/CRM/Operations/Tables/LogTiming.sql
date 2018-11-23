CREATE TABLE [Operations].[LogTiming] (
    [LogTimingID]      INT            IDENTITY (1, 1) NOT NULL,
    [LogSource]        NVARCHAR (512) NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [CreatedBy]        INT            NOT NULL,
    [LastModifiedDate] DATETIME       NOT NULL,
    [LastModifiedBy]   INT            NOT NULL,
    [StartDate]        DATETIME       NOT NULL,
    [EndDate]          DATETIME       NULL,
    [RecordCount]      INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_LogTiming] PRIMARY KEY CLUSTERED ([LogTimingID] ASC)
);

