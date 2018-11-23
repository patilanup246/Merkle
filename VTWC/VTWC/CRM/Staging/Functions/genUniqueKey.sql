	CREATE FUNCTION [Staging].[genUniqueKey](
		@FirstName VARCHAR(64)
	  , @MiddleName VARCHAR(64)
	  , @LastName VARCHAR(64)
	  , @PostCode VARCHAR(32)
	  , @AddressLine1 VARCHAR(512)
	  , @AddressLine2 VARCHAR(512)) RETURNS VARCHAR(4000)
	AS
	BEGIN

		DECLARE @AddressLine VARCHAR(512)

		SET @AddressLine = @AddressLine1

		IF  @AddressLine1 like '%'+@LastName+'%'
			SET @AddressLine = @AddressLine2

		RETURN CONCAT(
			      Staging.getFirstInitial(@FirstName, @MiddleName, @LastName)
				, Staging.removeDupChars(@LastName) 
				, Staging.removeDupChars(@PostCode)
				, Staging.removeDupChars(@AddressLine)
				) 

	END