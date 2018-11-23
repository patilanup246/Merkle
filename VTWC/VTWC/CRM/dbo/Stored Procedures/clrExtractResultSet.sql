CREATE PROCEDURE [dbo].[clrExtractResultSet]
@sqlSource NVARCHAR (4000) NULL, @sqlTargetFolder NVARCHAR (4000) NULL, @sqlTargetFile NVARCHAR (4000) NULL, @sqlDelimiter NVARCHAR (4000) NULL, @sqlRightAlignColumnList NVARCHAR (4000) NULL, @sqlOptions NVARCHAR (4000) NULL, @sqlDebug BIT NULL
AS EXTERNAL NAME [assemblyCLRUtilities].[CLRUtilities.StoredProcedures].[clrExtractResultSet]

