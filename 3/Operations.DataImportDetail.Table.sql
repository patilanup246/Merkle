USE [CEM]
GO
/****** Object:  Table [Operations].[DataImportDetail]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operations].[DataImportDetail](
	[DataImportDetailID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[ArchivedInd] [bit] NOT NULL,
	[DataImportLogID] [int] NOT NULL,
	[DataImportDefinitionID] [int] NOT NULL,
	[OperationalStatusID] [int] NOT NULL,
	[ImportFileName] [nvarchar](256) NOT NULL,
	[ProcessingOrder] [int] NOT NULL,
	[DestinationTable] [nvarchar](256) NOT NULL,
	[QueryFileName] [nvarchar](256) NULL,
	[QueryDefinition] [nvarchar](max) NULL,
	[StartTimeExtract] [datetime] NULL,
	[EndTimeExtract] [datetime] NULL,
	[StartTimeImport] [datetime] NULL,
	[EndTimeImport] [datetime] NULL,
	[TotalCountImport] [int] NULL,
	[SuccessCountImport] [int] NULL,
	[ErrorCountImport] [int] NULL,
 CONSTRAINT [cndx_PrimaryKey_DataImportDetail] PRIMARY KEY CLUSTERED 
(
	[DataImportDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Index [ix_DataImportDetail_DataImportDetailID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_DataImportDetail_DataImportDetailID] ON [Operations].[DataImportDetail]
(
	[DataImportLogID] ASC
)
INCLUDE ( 	[DataImportDetailID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Operations].[DataImportDetail] ADD  DEFAULT ((0)) FOR [ArchivedInd]
GO
ALTER TABLE [Operations].[DataImportDetail]  WITH CHECK ADD  CONSTRAINT [FK_DataImportDetail_DataImportDefinitionID] FOREIGN KEY([DataImportDefinitionID])
REFERENCES [Reference].[DataImportDefinition] ([DataImportDefinitionID])
GO
ALTER TABLE [Operations].[DataImportDetail] CHECK CONSTRAINT [FK_DataImportDetail_DataImportDefinitionID]
GO
ALTER TABLE [Operations].[DataImportDetail]  WITH CHECK ADD  CONSTRAINT [FK_DataImportDetail_DataImportLogID] FOREIGN KEY([DataImportLogID])
REFERENCES [Operations].[DataImportLog] ([DataImportLogID])
GO
ALTER TABLE [Operations].[DataImportDetail] CHECK CONSTRAINT [FK_DataImportDetail_DataImportLogID]
GO
ALTER TABLE [Operations].[DataImportDetail]  WITH CHECK ADD  CONSTRAINT [FK_DataImportDetail_OperationalStatusID] FOREIGN KEY([OperationalStatusID])
REFERENCES [Reference].[OperationalStatus] ([OperationalStatusID])
GO
ALTER TABLE [Operations].[DataImportDetail] CHECK CONSTRAINT [FK_DataImportDetail_OperationalStatusID]
GO
