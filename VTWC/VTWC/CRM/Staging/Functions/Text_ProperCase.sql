CREATE FUNCTION [Staging].[Text_ProperCase]
(
    @string NVARCHAR(2000)
)
RETURNS NVARCHAR(2000)
AS
BEGIN

    DECLARE @previousByte int
    DECLARE @byte int

    SET @string = LOWER(@string)
    IF LEFT(@string, 1) LIKE '[a-z]'
    SET @string = STUFF(@string, 1, 1, UPPER(LEFT(@string, 1)))

    SET @previousByte = 2

    WHILE 1 = 1
    BEGIN
        SET @byte = PATINDEX('%[^a-z0-9][a-z]%', SUBSTRING(@string, @previousByte, 2000))
        IF @byte = 0
            BREAK
    
	    SET @string = STUFF(@string, @previousByte + @byte, 1, UPPER(SUBSTRING(@string, @previousByte + @byte, 1)))
        SET @previousByte = @previousByte + @byte + 1
    
    END

    RETURN @string

END