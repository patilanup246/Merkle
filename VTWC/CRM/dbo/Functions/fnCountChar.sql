

CREATE FUNCTION [dbo].[fnCountChar] ( @pInput VARCHAR(100), @pSearchChar CHAR(1) )
RETURNS INT
/*===========================================================================================
Name:			fnCountChar
Purpose:		Counts the occurance of a character in a string.
Parameters:		@pInput			input string
				@pSearchChar	character to search   
Notes:			    
			
Created:		2010-10-15	Nitin
Modified:		
Peer Review:	
Call script:	fnCountChar](?,?)
=================================================================================================*/

BEGIN

DECLARE @vInputLength        INT
DECLARE @vIndex              INT
DECLARE @vCount              INT

SET @vCount = 0
SET @vIndex = 1
SET @vInputLength = LEN(@pInput)

WHILE @vIndex <= @vInputLength
BEGIN
    IF SUBSTRING(@pInput, @vIndex, 1) = @pSearchChar
        SET @vCount = @vCount + 1

    SET @vIndex = @vIndex + 1
END

RETURN @vCount

END