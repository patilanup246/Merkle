USE [CEM]
GO
/****** Object:  Table [PreProcessing].[API_CustomerRegistration]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PreProcessing].[API_CustomerRegistration](
	[CBECustomerID] [int] NOT NULL,
	[VisitorID] [uniqueidentifier] NULL,
	[Email] [nvarchar](256) NOT NULL,
	[EncryptedEmail] [nvarchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[ProcessedInd] [bit] NULL,
	[LastModifiedBy] [int] NULL,
	[LastModifiedDate] [datetime] NULL,
	[DataImportDetailID] [int] NULL,
 CONSTRAINT [PK_API_CustomerRegistration] PRIMARY KEY CLUSTERED 
(
	[CBECustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [PreProcessing].[API_CustomerRegistration] ADD  CONSTRAINT [DF_API_CustomerRegistration_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [PreProcessing].[API_CustomerRegistration] ADD  CONSTRAINT [DF_API_CustomerRegistration_ProcessedInd]  DEFAULT ((0)) FOR [ProcessedInd]
GO
ALTER TABLE [PreProcessing].[API_CustomerRegistration] ADD  CONSTRAINT [DF_API_API_CustomerRegistrationDefaultLastModifiedBy]  DEFAULT ((0)) FOR [LastModifiedBy]
GO
ALTER TABLE [PreProcessing].[API_CustomerRegistration] ADD  CONSTRAINT [DF_API_API_CustomerRegistrationDefaultLastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CBE Customer Identifier.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CustomerRegistration', @level2type=N'COLUMN',@level2name=N'CBECustomerID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID based on the cookie Identifier.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CustomerRegistration', @level2type=N'COLUMN',@level2name=N'VisitorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Email address of the customer.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CustomerRegistration', @level2type=N'COLUMN',@level2name=N'Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Encrypted Registered Customer Email.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CustomerRegistration', @level2type=N'COLUMN',@level2name=N'EncryptedEmail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When this row was created' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CustomerRegistration', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Who has created this row' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CustomerRegistration', @level2type=N'COLUMN',@level2name=N'CreatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicator to show whether record has been processed as part of the CEM Refresh. Default value is 0.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CustomerRegistration', @level2type=N'COLUMN',@level2name=N'ProcessedInd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer registration data.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CustomerRegistration'
GO
