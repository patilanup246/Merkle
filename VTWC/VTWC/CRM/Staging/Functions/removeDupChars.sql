	CREATE FUNCTION [Staging].[removeDupChars](@string VARCHAR(4000)) RETURNS VARCHAR(4000)
	AS
	BEGIN
		DECLARE @result VARCHAR(100)
		SET @result=''
		SET @string = Staging.RemoveNonAlphaCharacters(@string)
		SELECT @result =
			 RTRIM(LTRIM(UPPER(REPLACE(CASE 
				 WHEN @string NOT LIKE '%[^,]%' 
					 THEN '' /*The string is exclusively commas*/
				 ELSE 
					REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@string,
					REPLICATE(',',16),','), /*399/16 = 24 remainder 15*/
					REPLICATE(',',8),','),  /* 39/ 8 =  4 remainder 7*/
					REPLICATE(',',4),','),  /* 11/ 4 =  2 remainder 3*/
					REPLICATE(',',2),','),  /*  5/ 2 =  2 remainder 1*/
					REPLICATE(',',2),',')   /*  3/ 2 =  1 remainder 1*/
				 END, ' ',''))))

		RETURN @result
	END