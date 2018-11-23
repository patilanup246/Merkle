
/*===========================================================================================
Name:			uspInsertConfigurationParameter
Purpose:		Inserts or updates an new configuration parameter
Parameters:		@Parameter - The parameter name
				      @Description - The sdescription 
				      @Datatype - The datatype - Date (YYYYMMDD), Datetime (YYYYMMDD HH:MM), Int, Numeric, Text
				      @RowChangeReason - Was this row last changed by the [E]TL process [T]ouchpoint, [M] Manual
				      @RowChangeOperator - shows SYSTEM_USER if not specified
Notes:			
Created:		2010-07-06 Colin Thomas
Modified:   2011-02-22 Philip Robinson. Removed transaction as this causes tran count probelsm is outer proc has trans.
            2012-04-02 Philip Robinson. Removed XACT_ABORT ON. This is a utility proc called by different types of procedures 
                       where XACT_ABORT ON may not be appropriate.

Peer Review:	
Call script:	EXEC uspInsertConfigurationParameter ?,?
=================================================================================================*/
CREATE PROCEDURE dbo.uspInsertConfigurationParameter
				 @Parameter VARCHAR(50)
				,@Description VARCHAR(500)
				,@DataType VARCHAR(20) = NULL
				,@RowChangeReason CHAR(1) = 'M'  -- this proc will usually be called manually
				,@RowChangeOperator VARCHAR(20) = NULL
AS
BEGIN TRY

	--Set RowChangeOperator to System User if its not explicitly specified
	IF @RowChangeOperator IS NULL 	SET @RowChangeOperator = LEFT(SYSTEM_USER,20)
	
	-- Add new row when parameter doesn't exist
	INSERT INTO dbgConfigurationParameters
	(Parameter, [Description], DataType, RowChangeReason, RowChangeOperator)
	SELECT @Parameter, @Description, @DataType, @RowChangeReason, @RowChangeOperator
	WHERE NOT EXISTS 
	 (SELECT * 
	  FROM dbgConfigurationParameters
	  WHERE Parameter=@Parameter)

	-- Update row where parameter already exists
	IF @@ROWCOUNT=0
		UPDATE dbgConfigurationParameters
		SET  DataType=@DataType
			,[Description]=@Description
			,DateUpdated=GETDATE()
			,RowChangeReason=@RowChangeReason
			,RowChangeOperator=@RowChangeOperator
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