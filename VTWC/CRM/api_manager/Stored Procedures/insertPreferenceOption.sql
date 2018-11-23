  CREATE PROCEDURE [api_manager].[insertPreferenceOption] 
     @userid                int,          -- who has requested the action
	 @PreferenceId			int = NULL,
	 @OptionName			varchar(256) = NULL,
     @DefaultValue          bit = NULL
     
  AS 

    set nocount on;
   
    DECLARE @OptionId int = NULL
    DECLARE @ErrMsg varchar(512)
    DECLARE @RowCount int = 0
	    
	-- Check if PreferenceId is NULL
	IF @PreferenceId IS NULL 
	BEGIN
		SET @ErrMsg = 'PreferenceId cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if DefaultValue is NULL
	IF @DefaultValue IS NULL 
	BEGIN
		SET @ErrMsg = 'DefaultValue cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if OptionName is NULL
	IF @OptionName IS NULL 
	BEGIN
		SET @ErrMsg = 'OptionName cannot be NULL';
		THROW 90508, @ErrMsg,1
	END
	  
   	-- Check if the specified option exists for the specified preference in CEM
	SELECT @OptionId = OptionID
	FROM Staging.STG_PreferenceOptions WITH (NOLOCK)
	WHERE OptionName = @OptionName and PreferenceID = @PreferenceId

	IF @OptionId IS NOT NULL
    BEGIN
		SET @ErrMsg = 'The preference option (' + @OptionName + ') already exists for the preference with id (' + CAST(@PreferenceId as varchar) + ')';
		THROW 90508, @ErrMsg,1
	END     
	
	INSERT INTO Staging.STG_PreferenceOptions
     (
	  PreferenceID,
      OptionName,
      DefaultValue,
      CreatedDate,
      CreatedBy,
      LastModifiedDate,
      LastModifiedBy,
	  ArchivedInd
     )
     VALUES
     ( 
      @PreferenceId,
      @OptionName, 
      @DefaultValue,
      GETDATE(),
      @userid,
      GETDATE(),
      @userid,
	  0
     )
   
    SET @RowCount = @@ROWCOUNT
	
	IF @RowCount = 0
	BEGIN
		SET @ErrMsg = 'Unable to add Preference Option' ;
		THROW 90508, @ErrMsg,1
	END
	 
    RETURN @RowCount;