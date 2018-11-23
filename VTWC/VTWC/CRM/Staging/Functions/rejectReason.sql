	CREATE FUNCTION [Staging].[rejectReason](
	    @FullKey VARCHAR(200)
	  , @FirstName VARCHAR(64)
	  , @MiddleName VARCHAR(64)
	  , @LastName VARCHAR(64)
	  , @AddressLine1 VARCHAR(512)
	  , @AddressLine2 VARCHAR(512)) RETURNS VARCHAR(4000)
	AS
	BEGIN
		DECLARE @result VARCHAR(100)
		DECLARE @reason VARCHAR(100)
		DECLARE @AddressLine VARCHAR(512)
		DECLARE @delim VARCHAR(5)

		SET @result=''
		SET @AddressLine = @AddressLine1

		IF  @AddressLine1 like '%'+@LastName+'%'
			SET @AddressLine = @AddressLine2

		IF @AddressLine IS NULL
		  BEGIN
		    IF @reason IS NOT NULL
				SET @delim = ' AND '

		    SET @reason = 'Address Line empty'
		  END

		IF LEN(@FullKey) <= 15
		  BEGIN
		    IF @reason IS NOT NULL
				SET @delim = ' AND '

			SET @reason = CONCAT(@reason, @delim , 'FullKey too small')
		  END

		IF @FirstName IS NULL OR @FirstName = 'Customer'
		  BEGIN
		    IF @reason IS NOT NULL
				SET @delim = ' AND '

			SET @reason = CONCAT(@reason, @delim , 'Name is NULL/Incompleted')
		  END

		IF @LastName IS NULL OR @LastName = 'Customer'
		  BEGIN
		    IF @reason IS NOT NULL
				SET @delim = ' AND '
			
			SET @reason = CONCAT(@reason, @delim , 'MiddleName or LastName is NULL/Incompleted')
		  END

		RETURN @reason

	END