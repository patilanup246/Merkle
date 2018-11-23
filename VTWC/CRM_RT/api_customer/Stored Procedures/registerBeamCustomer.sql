CREATE PROCEDURE api_customer.registerBeamCustomer
	@firstName NVARCHAR(255) , 
	@lastName  NVARCHAR(255),
	@email     NVARCHAR(255),
	@optIn     BIT,
	@visitorID NVARCHAR(255),
	@isBeamCustomerInserted BIT OUTPUT AS
SET XACT_ABORT ON;
SET NOCOUNT ON;
BEGIN TRY
	INSERT INTO api_customer.BeamCustomer
	( FirstName
	, LastName
	, Email
	, OptIn
	, VisitorID)
	VALUES
	( @firstName
	, @lastName
	, @email   
	, @optIn   
	, @visitorID);

	SET @isBeamCustomerInserted = CAST(@@ROWCOUNT AS BIT);

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