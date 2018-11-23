CREATE TABLE [CRM].[CorporatesTMC_Flag](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[EmailAddress] [varchar](255) NULL,
	[EmailDomain] [varchar](255) NULL,
	[CustType] [varchar](32) NULL,
	[DateAdded] [datetime] NULL,
	[ArchivedInd] [bit] NULL DEFAULT 0,
PRIMARY KEY CLUSTERED 
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Record identifier',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CorporatesTMC_Flag',
    @level2type = N'COLUMN',
    @level2name = N'RecordID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email Address of TMC',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CorporatesTMC_Flag',
    @level2type = N'COLUMN',
    @level2name = N'EmailAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email Domain of the TMC',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CorporatesTMC_Flag',
    @level2type = N'COLUMN',
    @level2name = N'EmailDomain'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Type',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CorporatesTMC_Flag',
    @level2type = N'COLUMN',
    @level2name = N'CustType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Added',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CorporatesTMC_Flag',
    @level2type = N'COLUMN',
    @level2name = N'DateAdded'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Archived Flag',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'CorporatesTMC_Flag',
    @level2type = N'COLUMN',
    @level2name = N'ArchivedInd'