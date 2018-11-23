CREATE FUNCTION [Reference].[Configuration_GetSetting]
(
	@type             NVARCHAR(256),    
	@configuration    NVARCHAR(256)
)  
RETURNS NVARCHAR(MAX)		
AS  
	
BEGIN 
    DECLARE @setting    NVARCHAR(MAX);
         
    SELECT @setting = a.Setting
    FROM   [Reference].[Configuration] a,
           [Reference].[ConfigurationType] b
    WHERE  b.ConfigurationTypeID = a.ConfigurationTypeID
    AND    a.Name = @configuration
    AND    b.Name = @type
     
	RETURN @setting
	
END