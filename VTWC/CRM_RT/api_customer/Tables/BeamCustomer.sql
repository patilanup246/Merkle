CREATE TABLE api_customer.BeamCustomer(
	BeamCustomerID INT IDENTITY(1,1) NOT NULL,
	FirstName NVARCHAR(255),
	LastName NVARCHAR(255),
	email NVARCHAR(255) NOT NULL ,
	OptIn BIT NOT NULL DEFAULT 0,
	VisitorID NVARCHAR(255),
	CreationDate DATETIME NOT NULL DEFAULT GETDATE()
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UUID Created to allow duplicated registration',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'BeamCustomer',
    @level2type = N'COLUMN',
    @level2name = N'BeamCustomerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Beam Customer First Name',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'BeamCustomer',
    @level2type = N'COLUMN',
    @level2name = N'FirstName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Beam Customer Surname',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'BeamCustomer',
    @level2type = N'COLUMN',
    @level2name = N'LastName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Beam Customer email',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'BeamCustomer',
    @level2type = N'COLUMN',
    @level2name = N'email'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'If customer has opt in then TRUE otherwise FALSE',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'BeamCustomer',
    @level2type = N'COLUMN',
    @level2name = N'OptIn'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cookie ID',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'BeamCustomer',
    @level2type = N'COLUMN',
    @level2name = N'VisitorID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date when this row was created',
    @level0type = N'SCHEMA',
    @level0name = N'api_customer',
    @level1type = N'TABLE',
    @level1name = N'BeamCustomer',
    @level2type = N'COLUMN',
    @level2name = N'CreationDate'