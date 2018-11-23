  CREATE PROCEDURE [PreProcessing].[Beam_Customer_Insert]
	@userid int = NULL,
	@VisitorId uniqueidentifier = NULL,
	@FirstName nvarchar(64) = NULL,
	@LastName nvarchar(64) = NULL,
	@Email nvarchar(256) = NULL,
	@OptIn bit = false,
	@ParsedAddressEmail nvarchar(100) = NULL,
	@ParsedEmailInd bit = 0,
	@ParsedEmailScore int = 0,
	@ProfanityInd bit = 0

  AS 
    
    set nocount on;

    DECLARE @RowCount int = 0
    DECLARE @ErrMsg varchar(max)

	-- Check if @userid is NULL
	IF @userid IS NULL 
	BEGIN
		SET @ErrMsg = 'User Id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @VisitorId is NULL
	IF @VisitorId IS NULL 
	BEGIN
		SET @ErrMsg = 'Visitor id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @FirstName is NULL
	IF @FirstName IS NULL 
	BEGIN
		SET @ErrMsg = 'First name cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @LastName is NULL
	IF @LastName IS NULL 
	BEGIN
		SET @ErrMsg = 'Last name cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @Email is NULL
	IF @Email IS NULL 
	BEGIN
		SET @ErrMsg = 'Email cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	--Insert Beam Customer registration data
	INSERT INTO [PreProcessing].[Beam_Customer]
    ([VisitorID]
    ,[FirstName]
    ,[LastName]
    ,[EmailAddress]
    ,[OptIn]
    ,[CreatedDate]
    ,[CreatedBy]
    ,[LastModifiedDate]
    ,[LastModifiedBy]
	,[CustomerID]
	,[IndividualID]
	,[MatchedInd]
	,[ParsedAddressEmail]
	,[ParsedEmailInd]
	,[ParsedEmailScore]
	,[ProfanityInd]
	,[ProcessedInd]
	,[DataImportDetailID])
	VALUES        
	(@VisitorId,
	 @FirstName,
	 @LastName,
	 @Email,
	 @OptIn,
	 GETDATE(),
	 @userid,
	 GETDATE(),
	 @userid,
	 NULL,
	 NULL,
	 0,
	 @ParsedAddressEmail,
	 @ParsedEmailInd,
	 @ParsedEmailScore,
	 @ProfanityInd,
	 0,
	 NULL)

	SET @RowCount = @@ROWCOUNT
		
	IF @RowCount = 0
	BEGIN
		SET @ErrMsg = 'Unable to insert beam customer registration data' ;
		THROW 90508, @ErrMsg,1
	END

    RETURN @RowCount;