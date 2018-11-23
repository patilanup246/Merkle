CREATE TABLE [CRM].[crm_fallow_group](
	[Customer_ID] [int] NULL,
	[IndividualID] [int] NULL,
	[date_added] [datetime] NULL,
	[marketing_status_when_selected] [bit] NULL,
	[date_removed] [datetime] NULL,
	[fallow_type] [varchar](10) NULL,
	[fallow_source] [varchar](10) NULL
)
GO

CREATE INDEX [IX_CRM_FallowGroup_CustomerID_Dates] ON [CRM].CRM_Fallow_Group (Customer_ID, date_added, date_removed)

