CREATE TABLE [api_customer].[API_ElectronicAddress] (
    [CustomerID]    INT            NOT NULL,
    [AddressType]   NVARCHAR (256) NOT NULL,
    [ParsedAddress] NVARCHAR (256) COLLATE Latin1_General_CS_AS NOT NULL,
    PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Encrypted Electronic Address.', @level0type = N'SCHEMA', @level0name = N'api_customer', @level1type = N'TABLE', @level1name = N'API_ElectronicAddress', @level2type = N'COLUMN', @level2name = N'ParsedAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Address Type Name. Typically EMAIL.', @level0type = N'SCHEMA', @level0name = N'api_customer', @level1type = N'TABLE', @level1name = N'API_ElectronicAddress', @level2type = N'COLUMN', @level2name = N'AddressType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'VT Customer ID. FK to CRM.STG_Customer.', @level0type = N'SCHEMA', @level0name = N'api_customer', @level1type = N'TABLE', @level1name = N'API_ElectronicAddress', @level2type = N'COLUMN', @level2name = N'CustomerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contains Emails of users who as done a transaction during the last 18 months.', @level0type = N'SCHEMA', @level0name = N'api_customer', @level1type = N'TABLE', @level1name = N'API_ElectronicAddress';

