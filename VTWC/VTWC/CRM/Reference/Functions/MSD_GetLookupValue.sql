CREATE FUNCTION [Reference].[MSD_GetLookupValue]
(
 @tablename         NVARCHAR(256) = NULL,
 @attributename     NVARCHAR(256) = NULL,
 @attributevalue    NVARCHAR(256) = NULL
)
RETURNS NVARCHAR(256)
AS
BEGIN
    DECLARE @value    NVARCHAR(256)
	
	SELECT @value = CAST(Value AS NVARCHAR(256))
	FROM   [Reference].[MSD_StringMapBase] sm,
           [Reference].[MSD_Entity] e
    WHERE  e.ObjectTypeCode  = sm.ObjectTypeCode
	AND    e.OverwriteTime   = 0
	AND    e.ComponentState  = 0
	AND    e.PhysicalName    = @tablename
	AND    sm.AttributeName  = @attributename
	AND    sm.AttributeValue = @attributevalue

	IF @value IS NULL
	BEGIN
	    SELECT @value = CAST(Value AS NVARCHAR(256))
	FROM   [Reference].[MSD_StringMapBase] sm,
           [Reference].[MSD_Entity] e
        WHERE  e.ObjectTypeCode  = sm.ObjectTypeCode
	    AND    e.OverwriteTime   = 0
	    AND    e.ComponentState  = 0
	    AND    e.BaseTableName   = @tablename
	    AND    sm.AttributeName  = @attributename
	    AND    sm.AttributeValue = @attributevalue
    END

	IF @value IS NULL
	BEGIN
	    SELECT @value = CAST(Value AS NVARCHAR(256))
	FROM   [Reference].[MSD_StringMapBase] sm,
           [Reference].[MSD_Entity] e
        WHERE  e.ObjectTypeCode       = sm.ObjectTypeCode
        AND    e.OverwriteTime   = 0
	    AND    e.ComponentState  = 0
	    AND    e.ExtensionTableName   = @tablename
	    AND    sm.AttributeName       = @attributename
	    AND    sm.AttributeValue      = @attributevalue
    END

	RETURN @value
END