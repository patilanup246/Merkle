CREATE TYPE [api_manager].[AddOn] AS TABLE (
    [ProductType]          VARCHAR (256)  NULL,
    [ProductCode]          VARCHAR (256)  NULL,
    [NumberOfTravellers]   INT            NULL,
    [Cost]                 FLOAT (53)     NULL,
    [PurchasedProductCode] NVARCHAR (256) NULL);

