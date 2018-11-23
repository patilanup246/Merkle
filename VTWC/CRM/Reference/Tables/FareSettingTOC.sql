CREATE TABLE [Reference].[FareSettingTOC](
	[FareSettingTOCID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](4000) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[ArchivedInd] [bit] NOT NULL,
	[InformationSourceID] [int] NULL,
	[ExtReference] [nvarchar](256) NULL,
	[ShortCode] [nvarchar](16) NOT NULL,
	[URLInformation] [nvarchar](512) NULL,
 CONSTRAINT [cndx_PrimaryKey_FareSettingTOC] PRIMARY KEY CLUSTERED 
(
	[FareSettingTOCID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [Reference].[FareSettingTOC] ADD  DEFAULT ((0)) FOR [ArchivedInd]
GO

ALTER TABLE [Reference].[FareSettingTOC]  WITH CHECK ADD  CONSTRAINT [FK_FareSettingTOC_InformationSourceID] FOREIGN KEY([InformationSourceID])
REFERENCES [Reference].[InformationSource] ([InformationSourceID])
GO

ALTER TABLE [Reference].[FareSettingTOC] CHECK CONSTRAINT [FK_FareSettingTOC_InformationSourceID]
GO


