CREATE TABLE [PreProcessing].[RailTimeTable](
	[RailTimeTable_ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[XMLData] [xml] NULL,
	[CreatedDateETL] [datetime] NULL,
	[LastModifiedDateETL] [datetime] NULL,
	[ProcessedInd] [bit] NULL,
	[DataImportDetailID] [int] NULL,
 CONSTRAINT [cndx_PrimaryKey_RailTimeTable] PRIMARY KEY CLUSTERED 
(
	[RailTimeTable_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
