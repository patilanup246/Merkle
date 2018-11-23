CREATE TABLE [dbo].[MetadataFileSpecification] (
    [FileSpecificationKey]        INT            IDENTITY (1, 1) NOT NULL,
    [FileSpecificationName]       VARCHAR (500)  NULL,
    [FileDescription]             VARCHAR (8000) NULL,
    [ClientCode]                  CHAR (3)       NULL,
    [SupplierCode]                CHAR (3)       NULL,
    [FileType]                    CHAR (3)       NULL,
    [FilenameElement4]            CHAR (3)       NULL,
    [FilenameElement5]            CHAR (3)       NULL,
    [EncodingType]                CHAR (1)       NULL,
    [FileNameWildCard]            VARCHAR (100)  NULL,
    [SampleFileName]              VARCHAR (100)  NULL,
    [FileFormat]                  VARCHAR (50)   NULL,
    [FieldSeperator]              VARCHAR (5)    NULL,
    [TextQualifier]               VARCHAR (5)    NULL,
    [RowDelimiter]                VARCHAR (10)   NULL,
    [CodePage]                    VARCHAR (100)  NULL,
    [EscapeCharacter]             VARCHAR (10)   NULL,
    [CommentCharacter]            VARCHAR (10)   NULL,
    [FileHeaders]                 VARCHAR (1)    NULL,
    [TransferMethod]              VARCHAR (500)  NULL,
    [TransferFrequency]           VARCHAR (500)  NULL,
    [FullOrIncremental]           VARCHAR (500)  NULL,
    [FilterCriteria]              VARCHAR (500)  NULL,
    [DeletedRecords]              VARCHAR (500)  NULL,
    [RejectedRows]                VARCHAR (500)  NULL,
    [ColumnMetadataLocked]        CHAR (1)       NULL,
    [AdditionalColumnDestination] VARCHAR (50)   NULL,
    [FileSpecificationOptions]    VARCHAR (4000) NULL,
    [ModifiedDate]                DATE           DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_MetadataFileSpecification] PRIMARY KEY CLUSTERED ([FileSpecificationKey] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Highlights row changes for the EDP system to pick up the latest data', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'ModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Modified Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'ModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rules for any file options', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileSpecificationOptions';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Specification Options', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileSpecificationOptions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Destination of any additional columns supplied in the file.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'AdditionalColumnDestination';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Additional Column Destination', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'AdditionalColumnDestination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is the file row locked for editing. This would 
stop updating the column specification for the file as well.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'ColumnMetadataLocked';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Column Metadata Locked', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'ColumnMetadataLocked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Notes to describe what happens to rejected rows. This is only used for reference.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'RejectedRows';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Rejected Rows', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'RejectedRows';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Notes to describe what happens if and when records are deleted from source. This is only used for reference.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'DeletedRecords';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Deleted Records', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'DeletedRecords';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Notes to describe if only selected records sent from source system. This is only used for reference.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FilterCriteria';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Filter Criteria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FilterCriteria';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Notes to describe if all records are supplied each time, or only recently added/amended records.  Specify date period if applicable.  This is only used for reference.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FullOrIncremental';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Full Or Incremental', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FullOrIncremental';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'How often the file will get delivered', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'TransferFrequency';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Transfer Frequency', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'TransferFrequency';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'How the file will get delivered to dbg', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'TransferMethod';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Transfer Method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'TransferMethod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'For Fixed Width files this flag specifies that headers are included', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileHeaders';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Headers', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileHeaders';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Used to include comments within data (anything after this character is ignored)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'CommentCharacter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Comment Character', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'CommentCharacter';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Used to embed special characters', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'EscapeCharacter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Escape Character', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'EscapeCharacter';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code page of file data', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'CodePage';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1252', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'CodePage';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Code Page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'CodePage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Delimiter used to identify next row', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'RowDelimiter';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'{CR}{LF}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'RowDelimiter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Row Delimiter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'RowDelimiter';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Text qualifier used in the file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'TextQualifier';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'""', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'TextQualifier';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Text Qualifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'TextQualifier';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Field seperator used in the file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FieldSeperator';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'| ,', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FieldSeperator';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Field Seperator', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FieldSeperator';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The format of the file (used by EDP)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileFormat';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Format', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileFormat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A sample of the file name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'SampleFileName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Sample File Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'SampleFileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The wildcard used to identify this file specification', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileNameWildCard';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'FileName Wild Card', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileNameWildCard';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'V=Standard, U=Unicode, T=Test', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'EncodingType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Encoding Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'EncodingType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Specifies the type of data contained in the feed. The usage depends on the client.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FilenameElement5';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Filename Element 5', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FilenameElement5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Specifies the type of data contained in the feed. The usage depends on the client.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FilenameElement4';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Filename Element 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FilenameElement4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Specifies the feed that this data relates to', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Specifies the supplier (source within the client''s organisation or third party supplier)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'SupplierCode';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Supplier Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'SupplierCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The client code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'ClientCode';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Client Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'ClientCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A description of the feed specification', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileDescription';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Description', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the file specification. This should include the company name and be unique', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileSpecificationName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Specification Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileSpecificationName';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileSpecificationKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileSpecificationKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileSpecificationKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Specification Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification', @level2type = N'COLUMN', @level2name = N'FileSpecificationKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'List of schemas using this table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Lookup', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table has one row for each file specification. It is updated from the Feed File Specification spreadsheet.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'MetadataFileSpecification', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MetadataFileSpecification';

