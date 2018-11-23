CREATE TABLE [Reference].[DataType] (
    [DataTypeID]       INT            IDENTITY (1, 1) NOT NULL,
    [Name]             VARCHAR (256)  NOT NULL,
    [Description]      VARCHAR (4000) NULL,
    [SimpleType]       VARCHAR (50)   NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [CreatedBy]        INT            NOT NULL,
    [LastModifiedDate] DATETIME       NOT NULL,
    [LastModifiedBy]   INT            NOT NULL,
    CONSTRAINT [PK_Reference.DataType] PRIMARY KEY CLUSTERED ([DataTypeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who was the last one to modify this row', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'DataType', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latest date for this row', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'DataType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'DataType', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was created', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'DataType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Simple type of the data type (Boolean,Text,Date,Lookup)', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'DataType', @level2type = N'COLUMN', @level2name = N'SimpleType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for a Data Type', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'DataType', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Short name for a Data Type', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'DataType', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for a data type', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'DataType', @level2type = N'COLUMN', @level2name = N'DataTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Stores all possible data types.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'DataType';

