CREATE TABLE [Staging].[STG_JourneyCVI](
	[JourneyId] [int] NOT NULL,
	[CVIQuestionID] [int] NOT NULL,
	[CVIAnswerID] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[JourneyId] ASC,
	[CVIQuestionID] ASC,
	[CVIAnswerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [Staging].[STG_JourneyCVI]  WITH CHECK ADD  CONSTRAINT [FK_STG_JourneyCVI_Journey] FOREIGN KEY([JourneyId])
REFERENCES [Staging].[STG_Journey] ([JourneyID])
GO

ALTER TABLE [Staging].[STG_JourneyCVI] CHECK CONSTRAINT [FK_STG_JourneyCVI_Journey]
GO

ALTER TABLE [Staging].[STG_JourneyCVI]  WITH CHECK ADD  CONSTRAINT [FK_STG_JourneyCVI_Question] FOREIGN KEY([CVIQuestionID])
REFERENCES [Reference].[CVIQuestion] ([CVIQuestionID])
GO

ALTER TABLE [Staging].[STG_JourneyCVI] CHECK CONSTRAINT [FK_STG_JourneyCVI_Question]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Identifier for a Journey' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_JourneyCVI', @level2type=N'COLUMN',@level2name=N'JourneyId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Identifier for a Customer Volunteer Information Question.  ' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_JourneyCVI', @level2type=N'COLUMN',@level2name=N'CVIQuestionID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Identifier for a Customer Volunteer Information Answer.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_JourneyCVI', @level2type=N'COLUMN',@level2name=N'CVIAnswerID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UserID creating this record' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_JourneyCVI', @level2type=N'COLUMN',@level2name=N'CreatedBy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When the row was created' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_JourneyCVI', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UserID performing Update' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_JourneyCVI', @level2type=N'COLUMN',@level2name=N'LastModifiedBy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When the row was updated' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'STG_JourneyCVI', @level2type=N'COLUMN',@level2name=N'LastModifiedDate'
GO


