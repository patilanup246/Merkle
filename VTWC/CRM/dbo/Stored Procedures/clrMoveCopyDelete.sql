CREATE PROCEDURE [dbo].[clrMoveCopyDelete]
@sqlSourceFolder NVARCHAR (4000) NULL, @sqlSourceFile NVARCHAR (4000) NULL, @sqlTargetFolder NVARCHAR (4000) NULL, @sqlTargetFile NVARCHAR (4000) NULL, @sqlAction NVARCHAR (4000) NULL, @sqlOptions NVARCHAR (4000) NULL, @sqlDebug BIT NULL
AS EXTERNAL NAME [assemblyCLRUtilities].[CLRUtilities.StoredProcedures].[clrMoveCopyDelete]

