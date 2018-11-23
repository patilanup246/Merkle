CREATE TABLE [Operations].[LogMessage] (
    [LogMessageID]     INT            IDENTITY (1, 1) NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [CreatedBy]        INT            NOT NULL,
    [LastModifiedDate] DATETIME       NOT NULL,
    [LastModifiedBy]   INT            NOT NULL,
    [MessageSource]    NVARCHAR (256) NOT NULL,
    [Message]          NVARCHAR (MAX) NOT NULL,
    [MessageLevel]     NVARCHAR (16)  NOT NULL,
    [MessageTypeCd]    NVARCHAR (16)  NULL,
    CONSTRAINT [cndx_PrimaryKey_LogMessage] PRIMARY KEY CLUSTERED ([LogMessageID] ASC)
);

