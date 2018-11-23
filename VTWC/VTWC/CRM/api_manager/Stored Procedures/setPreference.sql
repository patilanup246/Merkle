  CREATE PROCEDURE [api_manager].[setPreference] 
     @userid                 int,          -- who has requested the action
	 @PreferenceName         varchar(256) = NULL,
     @IsVisible              bit = NULL,
     @DataType               varchar(50) = NULL,
	 @PreferenceID			 int OUTPUT	 
  AS 

   set nocount on;
   
   DECLARE @PreferenceDataTypeID int
   DECLARE @ErrMsg varchar(512)
   DECLARE @RowCount int = 0
   DECLARE @ArchivedInd bit = 0
     
   	-- Check if @PreferenceName is NULL
	IF @PreferenceName IS NULL 
	BEGIN
		SET @ErrMsg = 'PreferenceName cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @DataType is NULL
	IF @DataType IS NULL 
	BEGIN
		SET @ErrMsg = 'DataType cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check IsVisible value
	IF @IsVisible IS NULL OR (@IsVisible != 1 AND @IsVisible != 0)
	BEGIN
		SET @ErrMsg = 'IsVisible value has to be 1 or 0 and cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if the specified preference data type exists in CEM
	SELECT @PreferenceDataTypeID = DataTypeID
    FROM Reference.DataType dt WITH (NOLOCK)
	WHERE dt.Name = @DataType

	IF @PreferenceDataTypeID IS NULL
	BEGIN
      SET @ErrMsg = 'Unable to find Preference Data Type (' + @DataType + ')' ;
      THROW 90508, @ErrMsg,1
	END     

	-- Check if the specified preference exists in CEM
	SELECT TOP 1 @PreferenceID = PreferenceID,@ArchivedInd = ArchivedInd
	FROM Staging.STG_Preference WITH (NOLOCK)
	WHERE PreferenceName = @PreferenceName
	ORDER BY PreferenceID DESC

	IF @PreferenceID IS NOT NULL
    BEGIN
		IF @ArchivedInd = 0
		BEGIN
			SET @ErrMsg = 'A preference with the same name already exists (' + @PreferenceName + ')' ;
			THROW 90508, @ErrMsg,1
		END
		ELSE
		BEGIN
			INSERT INTO Staging.STG_Preference
			(
			PreferenceName,
			PreferenceDataTypeID,
			CreatedDate,
			CreatedBy,
			LastModifiedDate,
			LastModifiedBy,
			ArchivedInd
			)
			SELECT PreferenceName,PreferenceDataTypeID,GETDATE(),@userid,GETDATE(),@userid,0
			FROM Staging.STG_Preference WITH (NOLOCK)
			WHERE PreferenceID = @PreferenceID
   
			SET @RowCount = @@ROWCOUNT
	
			IF @RowCount = 0
			BEGIN
				SET @ErrMsg = 'Unable to add Preference' ;
				THROW 90508, @ErrMsg,1
			END
			ELSE
			BEGIN
				SET @PreferenceID = IDENT_CURRENT('Staging.STG_Preference')			
			END 
		END		
	END     
	ELSE
	BEGIN
		IF @IsVisible = 0
		BEGIN
			SET @ArchivedInd = 1
		END

		INSERT INTO Staging.STG_Preference
		(
		PreferenceName,
		PreferenceDataTypeID,
		CreatedDate,
		CreatedBy,
		LastModifiedDate,
		LastModifiedBy,
		ArchivedInd
		)
		VALUES
		( 
		@PreferenceName,     
		@PreferenceDataTypeID,
		GETDATE(),
		@userid,
		GETDATE(),
		@userid,
		@ArchivedInd
		)
   
		SET @RowCount = @@ROWCOUNT
	
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to add Preference' ;
			THROW 90508, @ErrMsg,1
		END
		ELSE
		BEGIN
			SET @PreferenceID = IDENT_CURRENT('Staging.STG_Preference')			
		END 
	END
    RETURN @RowCount;