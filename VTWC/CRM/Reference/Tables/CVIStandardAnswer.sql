CREATE TABLE [Reference].[CVIStandardAnswer](
	[CVIAnswerID] [int] NOT NULL,
	[Value] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](512) NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CVIAnswerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Identifier for a Customer Volunteered Information Answer' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIStandardAnswer', @level2type=N'COLUMN',@level2name=N'CVIAnswerID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Option offered to the Customer for the answer' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIStandardAnswer', @level2type=N'COLUMN',@level2name=N'Value'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Answer description' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIStandardAnswer', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created the record' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIStandardAnswer', @level2type=N'COLUMN',@level2name=N'CreatedBy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When the record was created' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIStandardAnswer', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who changed the record' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIStandardAnswer', @level2type=N'COLUMN',@level2name=N'LastModifiedBy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When the record was changed' , @level0type=N'SCHEMA',@level0name=N'Reference', @level1type=N'TABLE',@level1name=N'CVIStandardAnswer', @level2type=N'COLUMN',@level2name=N'LastModifiedDate'
GO
