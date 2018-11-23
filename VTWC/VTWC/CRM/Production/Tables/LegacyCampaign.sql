CREATE TABLE [Production].[LegacyCampaign] (
    [LegacyCampaignID] INT             IDENTITY (1, 1) NOT NULL,
    [LegacyProgramID]  INT             NULL,
    [Name]             NVARCHAR (256)  NOT NULL,
    [Description]      NVARCHAR (4000) NULL,
    [CreatedDate]      DATETIME        NOT NULL,
    [LastModifiedDate] DATETIME        NOT NULL,
    [StartDate]        DATETIME        NULL,
    [EndDate]          DATETIME        NULL,
    [ContactCount]     INT             NULL,
    CONSTRAINT [cndx_PrimaryKey_LegacyCampaign] PRIMARY KEY CLUSTERED ([LegacyCampaignID] ASC),
    CONSTRAINT [FK_LegacyCampaign_LegacyProgramID] FOREIGN KEY ([LegacyProgramID]) REFERENCES [Production].[LegacyProgram] ([LegacyProgramID])
);

