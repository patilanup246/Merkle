CREATE PROCEDURE [dbo].[clrGetFileInfo]
@sqlSourceFolder NVARCHAR (4000) NULL, @sqlSourceFile NVARCHAR (4000) NULL, @sqlOptions NVARCHAR (4000) NULL, @RowCountOutput INT NULL OUTPUT, @FileSizeBytesOutput BIGINT NULL OUTPUT, @sqlDebug BIT NULL
AS EXTERNAL NAME [assemblyCLRUtilities].[CLRUtilities.StoredProcedures].[clrGetFileInfo]

