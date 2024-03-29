USE [CEM]
GO
/****** Object:  UserDefinedFunction [dbo].[CapitalizeFirstCh]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE FUNCTION [dbo].[CapitalizeFirstCh]
   (@text varchar(50))
      RETURNS varchar(50)
  AS
  BEGIN

	DECLARE @txt varchar(50) = ''
	DECLARE @txt_part varchar(50)
	DECLARE @numberofwords int

	SET @numberofwords = LEN(@text) - LEN(REPLACE(@text, ' ', ''))
		
	WHILE @numberofwords > 1
	BEGIN
		SET @txt_part = LEFT(@text, CHARINDEX(' ',@text) - 1)
		SET @txt = @txt + ' ' + UPPER(SUBSTRING(@txt_part,1,1)) + LOWER(SUBSTRING(@txt_part,2,LEN(@txt_part)-1))
		SET @text = REPLACE(@text,@txt_part + ' ','')
		SET @numberofwords=(LEN(@text) - LEN(REPLACE(@text, ' ', '')) + 1)
	END

	SET @txt = @txt + ' ' + UPPER(SUBSTRING(@text,1,1)) + LOWER(SUBSTRING(@text,2,LEN(@text)-1))
	SET @txt = RTRIM(@txt)
		
	RETURN @txt
END


GO
