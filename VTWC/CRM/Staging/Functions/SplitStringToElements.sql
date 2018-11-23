CREATE FUNCTION [Staging].[SplitStringToElements]
(
    @string		NVARCHAR(2000),
    @delimiter	NVARCHAR(5),
	@elementnum int
)  
RETURNS NVARCHAR(2000)
AS  
BEGIN
	
	DECLARE @value		NVARCHAR(MAX)
	DECLARE @split TABLE (ID INTEGER IDENTITY(1,1), Value NVARCHAR(MAX)) 
		 
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

	DECLARE @counter int
	DECLARE @retstring NVARCHAR(2000)

	SET @counter = 0

	WHILE @counter < (SELECT  
					 MAX(ID) 
					 FROM @split)
		BEGIN
			SELECT @retstring = value 
			FROM @split 
			WHERE ID = @elementnum

			SET @counter = @counter + 1
		END
			
   RETURN @retstring
END