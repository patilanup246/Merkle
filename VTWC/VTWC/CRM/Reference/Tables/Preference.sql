CREATE TABLE [Reference].[Preference] (
    [PreferenceID]      INT             IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (50)   NULL,
    [Description]       NVARCHAR (4000) NULL,
    [CreatedBy]         INT             NULL,
    [CreatedDate]       DATETIME        NULL,
    [LastModifiedBy]    INT             NULL,
    [LastModififedDate] DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([PreferenceID] ASC)
);

