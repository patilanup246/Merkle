CREATE FUNCTION [Reference].[MSD_GetLookupValue_All]
(
 @tablename         NVARCHAR(256) = NULL,
 @attributename     NVARCHAR(256) = NULL
)
RETURNS @values TABLE
(
    AttributeName    NVARCHAR(256),
	Value            NVARCHAR(256),
	ValueName        NVARCHAR(256))
	
AS
BEGIN
    
	INSERT INTO @values
	    (AttributeName,
		 Value,
		 ValueName)
	SELECT sm.AttributeName,
	       sm.AttributeValue,
		   sm.Value
	FROM   [Reference].[MSD_StringMapBase] sm,
           [Reference].[MSD_Entity] e
    WHERE  e.ObjectTypeCode  = sm.ObjectTypeCode
	AND    e.PhysicalName    = @tablename
	AND    sm.AttributeName  = @attributename
	AND    e.OverwriteTime   = 0
	AND    e.ComponentState  = 0

	RETURN
END