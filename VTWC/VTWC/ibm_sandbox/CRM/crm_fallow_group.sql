CREATE TABLE [CRM].[CRMFallowGroup]
(
	[Customer_ID] INT NULL,
    [IndividualID] INT NULL,
    [date_added] DATETIME NULL,
    [marketing_status_when_selected] BIT NULL,
    [date_removed] DATETIME NULL,
    [fallow_type] VARCHAR(10) NULL
)

GO

CREATE INDEX [IX_CRM_FallowGroup_CustomerID_Dates] ON [CRM].[CRMFallowGroup] (Customer_ID, date_added, date_removed)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer ID',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CRMFallowGroup',
    @level2type = N'COLUMN',
    @level2name = N'Customer_ID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Individual ID',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CRMFallowGroup',
    @level2type = N'COLUMN',
    @level2name = N'IndividualID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date added to Fallow',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CRMFallowGroup',
    @level2type = N'COLUMN',
    @level2name = N'date_added'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Were they Marketable when added',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CRMFallowGroup',
    @level2type = N'COLUMN',
    @level2name = N'marketing_status_when_selected'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date removed from Fallow',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CRMFallowGroup',
    @level2type = N'COLUMN',
    @level2name = N'date_removed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fallow Type',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CRMFallowGroup',
    @level2type = N'COLUMN',
    @level2name = N'fallow_type'