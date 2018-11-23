﻿
	CREATE FUNCTION [Staging].[ValidateMobile]
	(
		@Mobile AS VARCHAR(25)
	)
	RETURNS  @parsedphone TABLE
(
parsedind bit,
cleanmobile varchar (25),
mobilescore int
)
AS  
BEGIN
declare @parsedind_tmp bit
declare @cleanmobile_tmp varchar (25)
declare @mobilescore_tmp char (3)

set @cleanmobile_tmp = @mobile
SET @parsedind_tmp=1
set @mobilescore_tmp = 100

--strip non-numerics
    WHILE PATINDEX('%[^0-9]%', @cleanmobile_tmp) > 0
    BEGIN
        SET @cleanmobile_tmp = STUFF(@cleanmobile_tmp, PATINDEX('%[^0-9]%', @cleanmobile_tmp), 1, '')
    END
	
--check mobile length
if len(@cleanmobile_tmp) <10 or len(@cleanmobile_tmp) > 15 
begin
	set @parsedind_tmp = 0
	set @mobilescore_tmp = 0
	set @cleanmobile_tmp = null
end		

--Only interested in righthand 10 nums
set @cleanmobile_tmp = right(@cleanmobile_tmp,10)

--check for nulls
If @mobile is null or @mobile = ''
begin
	set @parsedind_tmp = 0
	set @mobilescore_tmp = 0
	set @cleanmobile_tmp = null
end

--check US numbers
if (@mobile like '+1%' and len(@cleanmobile_tmp)= 10)
begin
	set @parsedind_tmp = 1
	set @mobilescore_tmp = 80
end


else 	--check UK numbers
	if (@cleanmobile_tmp NOT like  '7%' or len(@cleanmobile_tmp)< 10)
	begin
		set @parsedind_tmp = 0
		set @mobilescore_tmp = 0
		set @cleanmobile_tmp = null
	end
	else	--format valid UK numbers
		set @cleanmobile_tmp = '0'+@cleanmobile_tmp
	


		

    INSERT INTO @parsedphone
	    (parsedind, cleanmobile,mobilescore)
    VALUES
	    (@parsedind_tmp, @cleanmobile_tmp, @mobilescore_tmp)
		RETURN
	END