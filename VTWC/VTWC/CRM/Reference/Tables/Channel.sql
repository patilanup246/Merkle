CREATE TABLE [Reference].[Channel] (
    [ChannelID]        INT             IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50)   NULL,
    [Description]      NVARCHAR (4000) NULL,
    [CreatedBy]        INT             NULL,
    [CreatedDate]      DATETIME        NULL,
    [LastModifiedBy]   INT             NULL,
    [LastModifiedDate] DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([ChannelID] ASC)
);

