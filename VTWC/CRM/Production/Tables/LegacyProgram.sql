CREATE TABLE [Production].[LegacyProgram] (
    [LegacyProgramID]  INT             IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (256)  NOT NULL,
    [Description]      NVARCHAR (4000) NULL,
    [CreatedDate]      DATETIME        NOT NULL,
    [LastModifiedDate] DATETIME        NOT NULL,
    [StartDate]        DATETIME        NULL,
    [EndDate]          DATETIME        NULL,
    [ContactCount]     INT             NULL,
    CONSTRAINT [cndx_PrimaryKey_LegacyProgram] PRIMARY KEY CLUSTERED ([LegacyProgramID] ASC)
);

