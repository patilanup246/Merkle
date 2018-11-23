CREATE TABLE [Staging].[STG_FIRST_CLASS_UPGRADES] (
    [DEP_DATE]      VARCHAR (10) NOT NULL,
    [RSID]          VARCHAR (6)  NOT NULL,
    [Price]         INT          NULL,
    [Seats to Book] INT          NULL,
    [LoadDate]      DATE         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([DEP_DATE] ASC, [RSID] ASC)
);

