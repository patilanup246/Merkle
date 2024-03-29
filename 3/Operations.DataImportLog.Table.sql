USE [CEM]
GO
/****** Object:  Table [Operations].[DataImportLog]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operations].[DataImportLog](
	[DataImportLogID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[ArchivedInd] [bit] NOT NULL,
	[DataImportTypeID] [int] NOT NULL,
	[OperationalStatusID] [int] NOT NULL,
	[ImportStartTime] [datetime] NULL,
	[ImportEndTime] [datetime] NULL,
	[DateQueryStart] [datetime] NULL,
	[DateQueryEnd] [datetime] NULL,
 CONSTRAINT [cndx_PrimaryKey_DataImportDefinition] PRIMARY KEY CLUSTERED 
(
	[DataImportLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Index [ix_DataImportLog_DataImportTypeID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_DataImportLog_DataImportTypeID] ON [Operations].[DataImportLog]
(
	[DataImportTypeID] ASC
)
INCLUDE ( 	[DateQueryEnd]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_DataImportLog_QueryStart]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_DataImportLog_QueryStart] ON [Operations].[DataImportLog]
(
	[DataImportTypeID] ASC,
	[DateQueryStart] ASC
)
INCLUDE ( 	[DataImportLogID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Operations].[DataImportLog] ADD  DEFAULT ((0)) FOR [ArchivedInd]
GO
ALTER TABLE [Operations].[DataImportLog]  WITH CHECK ADD  CONSTRAINT [FK_DataImportLog_DataImportTypeID] FOREIGN KEY([DataImportTypeID])
REFERENCES [Reference].[DataImportType] ([DataImportTypeID])
GO
ALTER TABLE [Operations].[DataImportLog] CHECK CONSTRAINT [FK_DataImportLog_DataImportTypeID]
GO
ALTER TABLE [Operations].[DataImportLog]  WITH CHECK ADD  CONSTRAINT [FK_DataImportLog_OperationalStatusID] FOREIGN KEY([OperationalStatusID])
REFERENCES [Reference].[OperationalStatus] ([OperationalStatusID])
GO
ALTER TABLE [Operations].[DataImportLog] CHECK CONSTRAINT [FK_DataImportLog_OperationalStatusID]
GO
