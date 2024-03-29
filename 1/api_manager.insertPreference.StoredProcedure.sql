USE [CEM]
GO
/****** Object:  StoredProcedure [api_manager].[insertPreference]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_manager].[insertPreference] 
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

	-- Check if the specified preference exists in CEM
	SELECT @PreferenceID = PreferenceId
	FROM Staging.STG_Preference
	WHERE PreferenceName = @PreferenceName

	IF @PreferenceID IS NOT NULL
    BEGIN
		SET @ErrMsg = 'Preference already exists (' + @PreferenceName + ')' ;
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

	INSERT INTO Staging.STG_Preference
    (
    PreferenceName,
    Visible,
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
    @IsVisible, 
    @PreferenceDataTypeID,
    GETDATE(),
    @userid,
    GETDATE(),
    @userid,
	0
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
	
    RETURN @RowCount;

GO
