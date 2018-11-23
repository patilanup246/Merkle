CREATE TABLE [Reference].[CVIQuestion](
	[CVIQuestionID] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](512) NULL,
	[Type] [varchar](10) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CVIQuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique  Identifier for a Customer Volunteered Information Question' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIQuestion', @level2type=N'COLUMN',@level2name=N'CVIQuestionID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Short description for a CVI Question' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIQuestion', @level2type=N'COLUMN',@level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of the Question. May be used to store the question presented to the Customer if available' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIQuestion', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value to define which type of answers are associated with the question. [Standard|Open|Date|Numeric]' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIQuestion', @level2type=N'COLUMN',@level2name=N'Type'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UserID creating this record' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIQuestion', @level2type=N'COLUMN',@level2name=N'CreatedBy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When the row was created' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIQuestion', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UserID performing Update' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIQuestion', @level2type=N'COLUMN',@level2name=N'LastModifiedBy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When the row was updated' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIQuestion', @level2type=N'COLUMN',@level2name=N'LastModifiedDate'
GO


