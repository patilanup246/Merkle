CREATE TABLE [CRM].[Blacklist]
(
	[CustomerID] [bigint] NULL,
	[EmailAddress] [nvarchar](256) NULL,
	[Forename] [nvarchar](64) NULL,
	[Surname] [nvarchar](64) NULL,
	[MobileTelephoneNo] [nvarchar](256) NULL,
	[FirstRegDate] [datetime] NULL,
	[DateInserted] [datetime] NULL default getdate()
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Identifier in CRM',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Blacklist',
    @level2type = N'COLUMN',
    @level2name = N'CustomerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email Address',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Blacklist',
    @level2type = N'COLUMN',
    @level2name = N'EmailAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'First Name',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Blacklist',
    @level2type = N'COLUMN',
    @level2name = N'Forename'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Name',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Blacklist',
    @level2type = N'COLUMN',
    @level2name = N'Surname'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mobile Telephone Number',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Blacklist',
    @level2type = N'COLUMN',
    @level2name = N'MobileTelephoneNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date registered',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Blacklist',
    @level2type = N'COLUMN',
    @level2name = N'FirstRegDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date added to blacklist',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Blacklist',
    @level2type = N'COLUMN',
    @level2name = N'DateInserted'
GO

CREATE INDEX [IX_Blacklist_CustomerEmail]  ON [CRM].[Blacklist] (CustomerID, EmailAddress)
GO

CREATE INDEX [IX_Blacklist_CustomerMobile] ON [CRM].[Blacklist] (CustomerID, MobileTelephoneNo)
GO