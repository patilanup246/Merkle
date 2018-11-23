	CREATE FUNCTION [Staging].[getFirstInitial](
		@FirstName AS VARCHAR(64)
	  , @MiddleName AS VARCHAR(64)
	  , @LastName AS VARCHAR(64)
	) RETURNS VARCHAR(1) AS
	BEGIN
		DECLARE @return VARCHAR(1)

		SELECT @return=UPPER(LEFT(CONCAT(COALESCE(@FirstName,''),
							             COALESCE(@MiddleName,''),
							             COALESCE(@LastName,'')),1))

		RETURN @return

	END