CREATE TABLE [Reference].[CVIQuestion]
(
	[CVIQuestionID] INT NOT NULL PRIMARY KEY, 
    [Name] NVARCHAR(20) NOT NULL, 
    [Description] NVARCHAR(512) NULL, 
    [Type] VARCHAR(10) NOT NULL,
    [CreatedBy] INT NOT NULL, 
    [CreatedDate] DATE NOT NULL, 
    [LastModifiedBy] INT NOT NULL, 
    [LastModifiedDate] DATE NOT NULL
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique  Identifier for a Customer Volunteered Information Question',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIQuestion',
    @level2type = N'COLUMN',
    @level2name = 'CVIQuestionID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Short description for a CVI Question',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIQuestion',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description of the Question. May be used to store the question presented to the Customer if available',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIQuestion',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Value to define which type of answers are associated with the question. [Standard|Open|Date|Numeric]',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIQuestion',
    @level2type = N'COLUMN',
    @level2name = N'Type'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UserID creating this record',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIQuestion',
    @level2type = N'COLUMN',
    @level2name = N'CreatedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When the row was created',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIQuestion',
    @level2type = N'COLUMN',
    @level2name = N'CreatedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UserID performing Update',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIQuestion',
    @level2type = N'COLUMN',
    @level2name = 'LastModifiedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When the row was updated',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'CVIQuestion',
    @level2type = N'COLUMN',
    @level2name = 'LastModifiedDate'