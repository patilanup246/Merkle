CREATE TABLE [api_customer].[ServiceMessage](
	[MobileNumber] [nvarchar](25) NOT NULL,
	[OptOutDate] [datetime] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL
) 
GO
CREATE NONCLUSTERED INDEX [idx_api_ServiceMessage]
    ON [api_customer].[ServiceMessage]([OptOutDate] ASC);
	
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Mobile phone number',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'ServiceMessage',
    @level2type = N'COLUMN',
    @level2name = N'MobileNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date when the customer opted out from SMS',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'ServiceMessage',
    @level2type = N'COLUMN',
    @level2name = N'OptOutDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When this row was created',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'ServiceMessage',
    @level2type = N'COLUMN',
    @level2name = N'CreatedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Who created this row',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'ServiceMessage',
    @level2type = N'COLUMN',
    @level2name = N'CreatedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When this row was last modified',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'ServiceMessage',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Who modified this row',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'ServiceMessage',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedBy'