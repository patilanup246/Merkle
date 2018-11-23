CREATE TABLE [Reference].[Emaildomain] (
    [emaildomainID] INT            IDENTITY (1, 1) NOT NULL,
    [emaildomain]   NVARCHAR (256) NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_Emaildomain] PRIMARY KEY CLUSTERED ([emaildomain] ASC)
);

