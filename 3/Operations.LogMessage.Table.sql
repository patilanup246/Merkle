USE [CEM]
GO
/****** Object:  Table [Operations].[LogMessage]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operations].[LogMessage](
	[LogMessageID] [int] IDENTITY(1,1) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[MessageSource] [nvarchar](256) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[MessageLevel] [nvarchar](16) NOT NULL,
	[MessageTypeCd] [nvarchar](16) NULL,
 CONSTRAINT [cndx_PrimaryKey_LogMessage] PRIMARY KEY CLUSTERED 
(
	[LogMessageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
