CREATE TABLE [Staging].[STG_RailblazersData] (
    [Title]             VARCHAR (50)   NULL,
    [FirstName]         VARCHAR (50)   NULL,
    [Surname]           VARCHAR (50)   NULL,
    [Company]           VARCHAR (50)   NULL,
    [AddressLine1]      VARCHAR (50)   NULL,
    [AddressLine2]      VARCHAR (50)   NULL,
    [TownCity]          VARCHAR (50)   NULL,
    [Postcode]          VARCHAR (50)   NULL,
    [ContactNumber]     VARCHAR (50)   NULL,
    [BusinessSector]    VARCHAR (50)   NULL,
    [BusinessStructure] VARCHAR (50)   NULL,
    [NumberOfEmployees] VARCHAR (8000) NULL,
    [Email]             VARCHAR (50)   NULL,
    [PromoCode]         VARCHAR (50)   NULL,
    [Coast]             VARCHAR (50)   NULL,
    [DateReceived]      DATETIME       NULL,
    [MarketingOptIn]    BIT            NULL,
    [CreditOptIn]       BIT            NULL,
    [DFTOptIn]          BIT            NULL
);

