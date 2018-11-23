USE [CRM]
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'LastModifiedBy'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'LastModifiedDate'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'CreatedBy'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'PreferenceValue'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'OptionID'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'CustomerID'
GO

ALTER TABLE [Staging].[STG_CustomerPreference] DROP CONSTRAINT [FK_CustomerPreference_STG_PreferenceOptions]
GO

ALTER TABLE [Staging].[STG_CustomerPreference] DROP CONSTRAINT [FK_CustomerPreference_STG_Customer]
GO

ALTER TABLE [Staging].[STG_CustomerPreference] DROP CONSTRAINT [DF__STG_Custo__Archi__284DF453]
GO

/****** Object:  Table [Staging].[STG_CustomerPreference]    Script Date: 31/07/2018 09:31:48 ******/
DROP TABLE [Staging].[STG_CustomerPreference]
GO

/****** Object:  Table [Staging].[STG_CustomerPreference]    Script Date: 31/07/2018 09:31:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Staging].[STG_CustomerPreference](
	[CustomerID] [int] NOT NULL,
	[OptionID] [int] NOT NULL,
	[PreferenceValue] [bit] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[ArchivedInd] [bit] NOT NULL,
 CONSTRAINT [PK_CustomerPreference] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC,
	[OptionID] ASC,
	[CreatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [Staging].[STG_CustomerPreference] ADD  DEFAULT ((0)) FOR [ArchivedInd]
GO

ALTER TABLE [Staging].[STG_CustomerPreference]  WITH CHECK ADD  CONSTRAINT [FK_CustomerPreference_STG_Customer] FOREIGN KEY([CustomerID])
REFERENCES [Staging].[STG_Customer] ([CustomerID])
GO

ALTER TABLE [Staging].[STG_CustomerPreference] CHECK CONSTRAINT [FK_CustomerPreference_STG_Customer]
GO

ALTER TABLE [Staging].[STG_CustomerPreference]  WITH CHECK ADD  CONSTRAINT [FK_CustomerPreference_STG_PreferenceOptions] FOREIGN KEY([OptionID])
REFERENCES [Staging].[STG_PreferenceOptions] ([OptionID])
GO

ALTER TABLE [Staging].[STG_CustomerPreference] CHECK CONSTRAINT [FK_CustomerPreference_STG_PreferenceOptions]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer unique identifier and foreign key to Staging.STG_Customer table.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'CustomerID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Preference option unique identifier and foreign key to Staging.STG_PreferenceOptions.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'OptionID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The value of the preference for a given customer' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'PreferenceValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When this row was created' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Who has created this row' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'CreatedBy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Latest date for this row' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'LastModifiedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Who was the last one to modify this row' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference', @level2type=N'COLUMN',@level2name=N'LastModifiedBy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Preferences assigned to a Customer' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_CustomerPreference'
GO

