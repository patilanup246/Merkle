CREATE TABLE [Reference].[CVIStandardAnswer]
(
	[CVIAnswerID] INT NOT NULL PRIMARY KEY, 
    [Value] NVARCHAR(50) NOT NULL, 
    [Description] NVARCHAR(512) NULL, 
    [CreatedBy] INT NOT NULL, 
    [CreatedDate] DATE NOT NULL, 
    [LastModifiedBy] INT NOT NULL, 
    [LastModifiedDate] DATE NOT NULL)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Identifier for a Customer Volunteered Information Answer',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIStandardAnswer',
    @level2type = N'COLUMN',
    @level2name = N'CVIAnswerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Option offered to the Customer for the answer',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIStandardAnswer',
    @level2type = N'COLUMN',
    @level2name = N'Value'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Answer description',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIStandardAnswer',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User who created the record',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIStandardAnswer',
    @level2type = N'COLUMN',
    @level2name = N'CreatedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When the record was created',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIStandardAnswer',
    @level2type = N'COLUMN',
    @level2name = N'CreatedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User who changed the record',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIStandardAnswer',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When the record was changed',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIStandardAnswer',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedDate'