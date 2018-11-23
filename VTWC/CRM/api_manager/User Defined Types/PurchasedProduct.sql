CREATE TYPE [api_manager].[PurchasedProduct] AS TABLE (
    [SalesTransactionNumber] NVARCHAR (256) NOT NULL,
    [ProductType]            NVARCHAR (256) NULL,
    [ProductCode]            NVARCHAR (256) NULL,
    [IncludesVTECLegInd]     BIT            NULL,
    [NumberOfTravellers]     INT            NULL,
    [ProductCost]            FLOAT (53)     NULL,
    [AddonCost]              FLOAT (53)     NULL,
    [TotalCost]              FLOAT (53)     NOT NULL);

