CREATE FUNCTION [Staging].[IsUniqueIdentifier]
(
	@value    NVARCHAR(256)
)  
RETURNS INTEGER
AS  
	
BEGIN 
    DECLARE @result    INTEGER;
         
    SELECT @result = PATINDEX('%'+REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]')+'%',@value)
	
	RETURN @result
	
END