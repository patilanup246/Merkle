CREATE TABLE [PreProcessing].[CustomerPIIResponse] (
    [TMPcustomerid]         INT            NOT NULL,
    [TMPprofanityind]       NCHAR (1)      NULL,
    [TMPParsedEmailInd]     BIT            NULL,
    [TMPParsedAddressEmail] NVARCHAR (100) NULL,
    [TMPParsedEmailScore]   INT            NULL,
    [TMPParsedind]          BIT            NULL,
    [TMPCleanmobile]        NVARCHAR (25)  NULL,
    [TMPMobilescore]        INT            NULL,
    [TMPParsedind1]         BIT            NULL,
    [TMPCleanmobile1]       NVARCHAR (25)  NULL,
    [TMPMobilescore1]       INT            NULL,
    [TMPParsedind2]         BIT            NULL,
    [TMPCleanmobile2]       NVARCHAR (25)  NULL,
    [TMPMobilescore2]       INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TMPcustomerid] PRIMARY KEY CLUSTERED ([TMPcustomerid] ASC)
);

