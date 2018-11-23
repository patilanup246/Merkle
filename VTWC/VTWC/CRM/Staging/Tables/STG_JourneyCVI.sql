CREATE TABLE [Staging].[STG_JourneyCVI]
(
	[JourneyId] BIGINT NOT NULL , 
    [CVIQuestionID] INT NOT NULL, 
    [CVIAnswerID] NCHAR(10) NOT NULL, 
    [CreatedBy] INT NOT NULL, 
    [CreatedDate] DATE NOT NULL, 
    [LastModifiedBy] INT NOT NULL, 
    [LastModifiedDate] DATE NOT NULL, 
    PRIMARY KEY ([JourneyId], [CVIQuestionID], [CVIAnswerID]), 
    CONSTRAINT [FK_STG_JourneyCVI_Question] FOREIGN KEY ([CVIQuestionID]) REFERENCES [Reference].[CVIQuestion]([CVIQuestionID])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Identifier for a Journey',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_JourneyCVI',
    @level2type = N'COLUMN',
    @level2name = N'JourneyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Identifier for a Customer Volunteer Information Question.  ',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_JourneyCVI',
    @level2type = N'COLUMN',
    @level2name = N'CVIQuestionID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Identifier for a Customer Volunteer Information Answer.',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_JourneyCVI',
    @level2type = N'COLUMN',
    @level2name = N'CVIAnswerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UserID creating this record',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_JourneyCVI',
    @level2type = N'COLUMN',
    @level2name = N'CreatedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When the row was created',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_JourneyCVI',
    @level2type = N'COLUMN',
    @level2name = N'CreatedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UserID performing Update',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_JourneyCVI',
    @level2type = N'COLUMN',
    @level2name = 'LastModifiedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When the row was updated',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_JourneyCVI',
    @level2type = N'COLUMN',
    @level2name = 'LastModifiedDate'