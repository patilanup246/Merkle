USE [CEM]
GO
/****** Object:  Table [PreProcessing].[API_CustomerPreference]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PreProcessing].[API_CustomerPreference](
	[CustomerPreferenceID] [int] IDENTITY(1,1) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[ArchivedInd] [bit] NOT NULL,
	[CBECustomerID] [int] NOT NULL,
	[OptionID] [int] NOT NULL,
	[PreferenceValue] [bit] NOT NULL,
	[InformationSourceID] [int] NOT NULL,
	[ProcessedInd] [bit] NOT NULL,
	[DataImportDetailID] [int] NULL,
 CONSTRAINT [cndx_PrimaryKey_API_CustomerPreference] PRIMARY KEY CLUSTERED 
(
	[CustomerPreferenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [PreProcessing].[API_CustomerPreference] ADD  DEFAULT ((0)) FOR [ArchivedInd]
GO
