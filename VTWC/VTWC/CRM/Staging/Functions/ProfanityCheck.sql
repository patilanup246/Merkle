
	CREATE FUNCTION [Staging].[ProfanityCheck](
		@String AS VARCHAR(100)

	) RETURNS char (1) 

 AS
	BEGIN
	
	declare @Profanityind char (1)


set @profanityind = 'N'

--check string against reference.profanity
if exists(
select * from reference.profanity
where @String like '%'+profanity+'%')
set @profanityind = 'Y'



		RETURN @profanityind


	END