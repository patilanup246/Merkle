CREATE FUNCTION [Staging].[SplitStringToTable]
(
    @string    NVARCHAR(MAX),
    @delimiter NVARCHAR(5)
)  
RETURNS @split TABLE 
(
    
    ID       INTEGER IDENTITY(1,1),
	Value    NVARCHAR(MAX)
) 
AS  
BEGIN
	DECLARE @value    NVARCHAR(MAX)
	 
    WHILE (CHARINDEX(@delimiter,@string) >0)
    BEGIN
        SET @value = LTRIM(RTRIM(SUBSTRING(@string,1,CHARINDEX(@delimiter,@string)-1)))

        INSERT INTO @split
		    (Value)
        VALUES
		    (@value)

		SET @string = SUBSTRING(@string,CHARINDEX(@delimiter,@string) + LEN(@delimiter),LEN(@string))
    END

    INSERT INTO @split
	    (Value)
    VALUES
	    (@string)
	
    RETURN
END