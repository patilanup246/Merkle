
/*===========================================================================================
Name:			uspUpdateConfigurationParameterValue
Purpose:		Inserts or updates an new configuration parameter
Parameters:		@Parameter - The parameter name
				@Value - The new parameter value
				@RowChangeReason - Was this row last changed by the [E]TL process [T]ouchpoint, [M] Manual
				@RowChangeOperator
Notes:			
			
Created:	2010-07-06	Colin Thomas
Modified:	2010-10-29 PhilipR. Added ActiveFrom,ActiveTo configuration params.
Modified:   2010-12-20 PhilipR. Bug fix - not updating ActiveFrom\To dates.
Modified:   2011-02-22 Philip Robinson. Removed transaction as this causes tran count probelsm is outer proc has trans.
Modified:   2011-03-04 Philip Robinson. Modifying pattern to value datetime from:
                          [12][0-9][0-9][0-9][01][0-9][0123][0-9] [12][0-9]:[0-6][0-9]
                       to [12][0-9][0-9][0-9][01][0-9][0123][0-9] [012][0-9]:[0-6][0-9]
                       otherwise the validation fails at times before midday.
            2012-02-15 Jim Shine.  Amended @RowChangeOperator parameter to VARCHAR(50) to allow for longer user names.
                                   Shortens to 20 chars at present, until all databases can accept 50 chars.
            2012-04-02 Philip Robinson. Removed XACT_ABORT ON. This is a utility proc called by different types of procedures 
                       where XACT_ABORT ON may not be appropriate.
                                    
Peer Review:	
Call script:	EXEC uspUpdateConfigurationParameterValue ?,?
=================================================================================================*/
CREATE PROCEDURE dbo.uspUpdateConfigurationParameterValue
				 @Parameter VARCHAR(50)
				,@NewValue VARCHAR(500)
				,@ActiveFrom smalldatetime = NULL
				,@ActiveTo smalldatetime = '20501231'
				,@RowChangeReason CHAR(1)
				,@RowChangeOperator VARCHAR(50) = NULL
AS

BEGIN TRY
  -- Default Active from today
  SET @ActiveFrom = COALESCE(@ActiveFrom, GETDATE())


	--Set RowChangeOperator to System User if its not explicitly specified
	IF @RowChangeOperator IS NULL
		SET @RowChangeOperator = LEFT(SYSTEM_USER,20)
	
	-- Check that value is of correct datatype
	DECLARE @DataType VARCHAR(20)
	SELECT @DataType = DataType 
	 FROM dbgConfigurationParameters
	 WHERE Parameter=@Parameter

	IF @datatype='Date' 
		and (@NewValue NOT LIKE '[12][0-9][0-9][0-9][01][0-9][0123][0-9]'
			 or ISDATE(@NewValue)=0)
		and @NewValue IS NOT NULL
		RAISERROR('Value %s is not in the correct date format (YYYYMMDD)',11,1, @NewValue)
	
	IF @datatype='DateTime' 
		and (@NewValue NOT LIKE '[12][0-9][0-9][0-9][01][0-9][0123][0-9] [012][0-9]:[0-6][0-9]'
			 or ISDATE(@NewValue)=0)
		and @NewValue IS NOT NULL
		RAISERROR('Value %s is not in the correct date format (YYYYMMDD HH:MM)',11,1, @NewValue)

	IF @datatype='Int' 
		and (@NewValue LIKE '%[.,£$]%'
			 or ISNUMERIC(@NewValue)=0)
		and @NewValue IS NOT NULL
		RAISERROR('Value %s is not an integer value',11,1, @NewValue)

	IF @datatype='Numeric' 
		and (@NewValue LIKE '%[£$]%'
			 or ISNUMERIC(@NewValue)=0)
		and @NewValue IS NOT NULL
		RAISERROR('Value %s is not a numeric value',11,1, @NewValue)

	-- Update parameter value
	UPDATE dbgConfigurationParameters
		SET  Value=@NewValue
		  ,ActiveFrom = @ActiveFrom
		  ,ActiveTo = @ActiveTo
			,DateUpdated=GETDATE()
			,RowChangeReason=@RowChangeReason
			,RowChangeOperator=LEFT(@RowChangeOperator,20)
		WHERE Parameter=@Parameter
	
END TRY
BEGIN CATCH
	DECLARE 
		@ErrorMessage VARCHAR(4000),
		@ErrorNumber INT,
		@ErrorSeverity INT,
		@ErrorState INT,
		@ErrorLine INT,
		@ErrorProcedure VARCHAR(126);

	SELECT 
		@ErrorNumber = ERROR_NUMBER(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE(),
		@ErrorLine = ERROR_LINE(),
		@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), 'N/A');

	--Build the error message string
	SELECT @ErrorMessage = 'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +
						   'Message: ' + ERROR_MESSAGE()      
	--Rethrow the error
	RAISERROR                                    
	(
		@ErrorMessage,
		@ErrorSeverity,
		1,
		@ErrorNumber,
		@ErrorSeverity,
		@ErrorState,
		@ErrorProcedure,
		@ErrorLine
	);    
END CATCH