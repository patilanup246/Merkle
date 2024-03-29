USE [CEM]
GO
/****** Object:  StoredProcedure [api_manager].[updatePreference]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_manager].[updatePreference] 
     @userid                 int,          -- who has requested the action
	 @PreferenceId           int = NULL,
	 @PreferenceName         varchar(256) = NULL,
     @IsVisible              bit = NULL,
     @DataType               varchar(50) = NULL
     
  AS 

   set nocount on;
   
	DECLARE @PreferenceDataTypeID int = NULL
	DECLARE @ErrMsg varchar(512)
	DECLARE @RowCount int = 0

    -- Check if @PreferenceId is NULL
	IF @PreferenceId IS NULL 
	BEGIN
		SET @ErrMsg = 'PreferenceId cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

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
		
	IF Exists(SELECT 1 FROM Staging.STG_Preference WHERE PreferenceName = @PreferenceName and PreferenceID != @PreferenceId)
    BEGIN
		SET @ErrMsg = 'A preference with the same name already exists (' + @PreferenceName + ')' ;
		THROW 90508, @ErrMsg,1
	END     

	-- Check if the specified preference data type exists in CEM
	SELECT @PreferenceDataTypeID = DataTypeID
	FROM Reference.DataType dt
	WHERE dt.Name = @DataType

	IF @PreferenceDataTypeID IS NULL
    BEGIN
		SET @ErrMsg = 'Unable to find Preference Data Type (' + @DataType + ')' ;
		THROW 90508, @ErrMsg,1
	END     

	IF NOT EXISTS (SELECT 1
				   FROM Staging.STG_Preference p
				   WHERE p.PreferenceID = @PreferenceID)
	BEGIN
		SET @ErrMsg = 'Unable to find Preference (' + @PreferenceName + ')' ;
		THROW 90508, @ErrMsg,1	
	END
	ELSE
	BEGIN
		--INSERT DATA IN ARCHIVE DB
		INSERT INTO CEM_ARCHIVE.Staging.STG_Preference
		(
		PreferenceID,
		PreferenceName,
		Visible,
		PreferenceDataTypeID,
		CreatedDate,
		CreatedBy,
		LastModifiedDate,
		LastModifiedBy,
		ArchivedInd
		)
		SELECT PreferenceId,PreferenceName,Visible,PreferenceDataTypeID,CreatedDate,CreatedBy,LastModifiedDate,LastModifiedBy,ArchivedInd
		FROM Staging.STG_Preference
		WHERE PreferenceID = @PreferenceId

		--UPDATE DATA IN CE DB
		UPDATE Staging.STG_Preference
		SET PreferenceName = @PreferenceName,
			Visible = @IsVisible,
			PreferenceDataTypeID = @PreferenceDataTypeID,
			LastModifiedBy = @userid,
			LastModifiedDate = GETDATE()
		WHERE PreferenceID = @PreferenceID
	END
  
	SET @RowCount = @@ROWCOUNT

	IF @RowCount = 0
	BEGIN
      SET @ErrMsg = 'Unable to update Preference' ;
      THROW 90508, @ErrMsg,1
	END  

    RETURN @RowCount;

GO
