CREATE FUNCTION [Reference].[CustomerType_GetSubTypeID]
(
	@type       NVARCHAR(256),    
	@subtype    NVARCHAR(256)
)  
RETURNS INTEGER		
AS  
	
BEGIN 
    DECLARE @subtypeid    INTEGER;
         
    SELECT @subtypeid = b.CustomerTypeID
    FROM Reference.CustomerType a,
         Reference.CustomerType b
    WHERE a.CustomerTypeID = b.CustomerTypeIDParent
	AND   a.Name = @type
	AND   b.Name = @subtype

     
	RETURN @subtypeid
	
END