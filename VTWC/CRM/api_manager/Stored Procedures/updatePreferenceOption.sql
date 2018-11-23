  CREATE PROCEDURE [api_manager].[updatePreferenceOption] 
     @userid                 int,          -- who has requested the action
	 @PreferenceId           int = NULL,
	 @OptionName			 varchar(256) = NULL,
     @DefaultValue			 bit = NULL
     
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

	-- Check if the specified preference exists in CEM
	IF NOT EXISTS (SELECT 1
				   FROM Staging.STG_Preference WITH (NOLOCK)
                   WHERE PreferenceID = @PreferenceID)
	BEGIN
		SET @ErrMsg = 'Unable to find a Preference with id (' + CAST(@PreferenceId AS varchar) + ')';
		THROW 90508, @ErrMsg,1
	END

  	-- Check if the specified option exists for the specified preference in CEM
	SELECT @OptionId = OptionID
	FROM Staging.STG_PreferenceOptions WITH (NOLOCK)
	WHERE OptionName = @OptionName and PreferenceID = @PreferenceId

	-- Update data
	IF NOT EXISTS (SELECT 1
				   FROM Staging.STG_PreferenceOptions WITH (NOLOCK)
				   WHERE PreferenceID = @PreferenceID AND OptionID = @OptionId)
	BEGIN
		--If preference option doesn't exist, we insert it
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
	END
	ELSE
	BEGIN
		--Update reference option
		UPDATE Staging.STG_PreferenceOptions
		SET OptionName = @OptionName,
			DefaultValue = @DefaultValue,
			LastModifiedBy = @userid,
			LastModifiedDate = GETDATE()
		WHERE PreferenceID = @PreferenceID AND OptionID = @OptionId
	END
  
	SET @RowCount = @@ROWCOUNT
	
	IF @RowCount = 0
	BEGIN
      SET @ErrMsg = 'Unable to add Preference' ;
      THROW 90508, @ErrMsg,1
	END  

    RETURN @RowCount;