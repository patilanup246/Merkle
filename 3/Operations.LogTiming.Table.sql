USE [CEM]
GO
/****** Object:  Table [Operations].[LogTiming]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operations].[LogTiming](
	[LogTimingID] [int] IDENTITY(1,1) NOT NULL,
	[LogSource] [nvarchar](512) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[RecordCount] [int] NULL,
 CONSTRAINT [cndx_PrimaryKey_LogTiming] PRIMARY KEY CLUSTERED 
(
	[LogTimingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
