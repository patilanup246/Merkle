
--drop function [Staging].[ValidateEmail]
	CREATE function [Staging].[ValidateEmail](
		@Email AS VARCHAR(100)

	) RETURNS bit 

 AS
	BEGIN
	
	declare @parsedind bit
	declare @localpart VARCHAR(100)
	declare @domain VARCHAR(100)
	declare @localdomain VARCHAR(100)
	declare @topleveldomain VARCHAR(100)

set @parsedind = 1
	-- parse out local part
set @localpart = [Staging].[SplitStringToElements](@email, '@',1)
--parse out complete domain
set @domain = [Staging].[SplitStringToElements](@email, '@',2)
--parse out local domain from complete domain
SET @localdomain = [Staging].[SplitStringToElements](@domain, '.',1)
--parse out top level domain from complete domain
set @topleveldomain = Substring(@domain,LEN(@domain) - Charindex('.',Reverse(@domain))+2,LEN(@domain)) 


if @email  not like '%@%.%' --must have generic email structure of an '@' and a '.'
or @email like '%..%'        -- Cannot have two periods in a row
or @email like '%@%@%' -- cannot have 2 @ signs
or @email like '.%'  -- cannot start with '.'
or @localpart like '%.'  --  local part cannot end with '.'
OR @email IS NULL -- cannot be null
set @parsedind = 0





--check local part for valid characters
if patindex('%[^A-Z,a-z,0-9,.,'',_,+,!,#,$,%,&,*,/,=,?,^,{,},|,~,-]%', @localpart ) > 0 
	set @parsedind = 0


--check domain for valid characters
if patindex('%[^A-Z,a-z,0-9,.,_,-]%', @domain ) > 0 
	set @parsedind = 0


--check TLD against reference.emaildomain
if not exists (
select emaildomain from reference.emaildomain WHERE @topleveldomain = emaildomain)
set @parsedind = 0



		RETURN @parsedind


	END