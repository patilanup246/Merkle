CREATE TABLE [Staging].[STG_TacticalProgrammeLoadErrors] (
    [Status]             VARCHAR (512) NULL,
    [Status.Code]        VARCHAR (512) NULL,
    [Status.Description] VARCHAR (512) NULL,
    [CBECustomerID]      INT           NULL,
    [HasLoyaltyCardType] BIT           NULL,
    [CustomerVariable2]  BIT           NULL,
    [CustomerVariable3]  BIT           NULL,
    [CustomerVariable4]  BIT           NULL,
    [CustomerVariable5]  BIT           NULL,
    [CustomerVariable6]  BIT           NULL,
    [CustomerVariable7]  BIT           NULL,
    [CustomerVariable8]  BIT           NULL,
    [CustomerVariable9]  BIT           NULL,
    [CustomerVariable10] BIT           NULL,
    [Error.Message]      VARCHAR (512) NULL,
    [Error.Code]         INT           NULL,
    [Error.SQLState]     VARCHAR (512) NULL,
    [Timestamp]          VARCHAR (512) NULL,
    [Username]           VARCHAR (512) NULL,
    [VisitorID]          VARCHAR (512) NULL,
    [EmailAddress]       VARCHAR (512) NULL
);

