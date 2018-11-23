CREATE TABLE [Reference].[Profanity] (
    [ProfanityID] INT            IDENTITY (1, 1) NOT NULL,
    [Profanity]   NVARCHAR (256) NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_Profanity] PRIMARY KEY CLUSTERED ([Profanity] ASC)
);

