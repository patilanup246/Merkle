USE [CEM]
GO
/****** Object:  Table [PreProcessing].[API_CVIResponseCustomer]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PreProcessing].[API_CVIResponseCustomer](
	[CVIResponseCustomerID] [int] IDENTITY(1,1) NOT NULL,
	[InformationSourceID] [int] NOT NULL,
	[CBECustomerID] [int] NOT NULL,
	[CVIQuestionID] [int] NOT NULL,
	[CVIQuestionGroupID] [int] NULL,
	[CVIQuestionAnswerID] [int] NOT NULL,
	[Response] [varchar](4000) NULL,
	[VisitorID] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[ProcessedInd] [bit] NULL,
	[LastModifiedBy] [int] NULL,
	[LastModifiedDate] [datetime] NULL,
	[DataImportDetailID] [int] NULL,
 CONSTRAINT [PK_API_CVIResponseCustomer] PRIMARY KEY CLUSTERED 
(
	[CVIResponseCustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [DBA_NCI_CBECustomerID_CVIQuestionAnswerID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [DBA_NCI_CBECustomerID_CVIQuestionAnswerID] ON [PreProcessing].[API_CVIResponseCustomer]
(
	[CBECustomerID] ASC,
	[CVIQuestionAnswerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Index]
GO
ALTER TABLE [PreProcessing].[API_CVIResponseCustomer] ADD  CONSTRAINT [DF_API_CVIResponseCustomerDefaultLastModifiedBy]  DEFAULT ((0)) FOR [LastModifiedBy]
GO
ALTER TABLE [PreProcessing].[API_CVIResponseCustomer] ADD  CONSTRAINT [DF_API_CVIResponseCustomerDefaultLastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [PreProcessing].[API_CVIResponseCustomer]  WITH CHECK ADD  CONSTRAINT [FK_API_CVIResponseCustomer_CVIQuestion] FOREIGN KEY([CVIQuestionID])
REFERENCES [Reference].[CVIQuestion] ([CVIQuestionID])
GO
ALTER TABLE [PreProcessing].[API_CVIResponseCustomer] CHECK CONSTRAINT [FK_API_CVIResponseCustomer_CVIQuestion]
GO
ALTER TABLE [PreProcessing].[API_CVIResponseCustomer]  WITH CHECK ADD  CONSTRAINT [FK_API_CVIResponseCustomer_InformationSource] FOREIGN KEY([InformationSourceID])
REFERENCES [Reference].[InformationSource] ([InformationSourceID])
GO
ALTER TABLE [PreProcessing].[API_CVIResponseCustomer] CHECK CONSTRAINT [FK_API_CVIResponseCustomer_InformationSource]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CEM Unique identifier.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'CVIResponseCustomerID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID used in table Reference.InformationSource. Indicates the Source system for the information.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'InformationSourceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CBE Customer Identifier.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'CBECustomerID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key to Reference.CVIQuestion related to the customer response.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'CVIQuestionID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key to Reference.CVIQuestionGroup related to the customer response.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'CVIQuestionGroupID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key to Reference.CVIQuestionAnswer related to the customer response.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'CVIQuestionAnswerID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Used to record responses to non-predefined answers. Type of answer will be depend on the question’s response type code.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'Response'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID based on the cookie Identifier.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'VisitorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When this row was created' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Who has created this row' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'CreatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicator to show whether record has been processed as part of the CEM Refresh. Default value is 0.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer', @level2type=N'COLUMN',@level2name=N'ProcessedInd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CVI Responses registration when CBE Customer is unknown in CEM.' , @level0type=N'SCHEMA',@level0name=N'PreProcessing', @level1type=N'TABLE',@level1name=N'API_CVIResponseCustomer'
GO
