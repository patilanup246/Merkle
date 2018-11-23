CREATE TABLE [Staging].[STG_DistressedInventory] (
    [Date]          DATE          NULL,
    [RSID]          VARCHAR (512) NULL,
    [Time]          VARCHAR (512) NULL,
    [Orig]          VARCHAR (512) NULL,
    [Dest]          VARCHAR (512) NULL,
    [Class]         VARCHAR (512) NULL,
    [Seats_to_book] INT           NULL,
    [Price]         MONEY         NULL,
    [CreatedDate]   DATETIME      DEFAULT (getdate()) NULL
);

