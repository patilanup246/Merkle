  CREATE PROCEDURE [api_customer].[addAlert]
     @userid int,
     @Title varchar(64) ,
     @Forename varchar(64) ,
     @Surname varchar(64) ,
     @Email varchar(256) ,
     @EncryptedEmail varchar(256),
     @From char(3) ,
     @To char(3) ,
     @AlertName varchar(max),
     @DurationStartDate datetime,
     @DurationEndDate datetime,
     @outwardJourney datetime,
     @returnJourney datetime,
	 @createdAnonymously bit,
	 @AlertID bigint OUTPUT
	 
  AS 

    SET nocount on;
    SET @AlertID = -1
	
	IF @createdAnonymously IS NULL
		SET @createdAnonymously = CAST(0 AS BIT)

	DECLARE @CustomerID int = NULL
	DECLARE @IndividualID int = NULL
	DECLARE @CustomerXEmail int = 0
    DECLARE @InformationSourceID int
    DECLARE @SourceChangeDate DATETIME = GETDATE()
    DECLARE @RowCountRes int = 0
	DECLARE @ErrMsg varchar(512)
	
	--Getting Information Source
	SELECT @InformationSourceID = InformationSourceID 
	FROM [Reference].[InformationSource] 
	WHERE Name = 'CEM API' 

    -- Validating that CRS Code exists.
    IF NOT EXISTS ( SELECT CAST(1 AS BIT)
			          FROM Reference.Location
			         WHERE CRSCode = COALESCE(@From, 'NULL'))
    BEGIN
		SET @ErrMsg = 'Unable to find the specified CRS Code ('+ COALESCE(@From, 'NULL') +')';
		THROW 51403, @ErrMsg,1
    END   

    -- Validating that CRS Code exists.
    IF NOT EXISTS (SELECT CAST(1 AS BIT)
		           FROM Reference.Location
			       WHERE CRSCode = COALESCE(@To, 'NULL'))
    BEGIN
		SET @ErrMsg = 'Unable to find the specified CRS Code ('+ COALESCE(@To, 'NULL') +')';
		THROW 51403, @ErrMsg,1
    END  

	-- Check if @EncryptedEmail is NULL
	IF @EncryptedEmail IS NULL 
	BEGIN
		SET @ErrMsg = 'EncryptedEmail cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	BEGIN TRY
      EXEC api_shared.getCustomerID @EncryptedEmail, @CustomerID OUTPUT
    END TRY
    BEGIN CATCH
      PRINT 'Unable to find CustomerID for Encrypted Email ('+@EncryptedEmail+')'
    END CATCH

    -- Does this encrypted email belongs to an exiting individual?
    BEGIN TRY
      EXEC api_shared.getIndividualID @EncryptedEmail, @IndividualID OUTPUT
    END TRY
    BEGIN CATCH
      PRINT 'Unable to find IndividualID for Encrypted Email ('+@EncryptedEmail+')'
    END CATCH 

	-- Check if Account has been created without log in.
	IF @createdAnonymously =  CAST(1 AS BIT)
	BEGIN
		--If CustomerID is NULL, check if IndividualID is NULL, if it is, inser Individual and Address
		IF @IndividualID IS NULL
		BEGIN
			EXEC [Staging].[STG_Individual_Add]
            @userid                 = @userid,   
            @informationsourceid    = @InformationSourceID,
            @sourcecreateddate      = @SourceChangeDate,
            @sourcemodifieddate     = NULL,
            @archivedind            = 0,
            @salutation             = @Title,
            @firstname              = @Forename,
            @lastname               = @Surname,
            @individualid           = @IndividualID OUTPUT    

			--Add EmailAddress and Individual in ElectronicAddress
			INSERT INTO [Staging].[STG_ElectronicAddress]
			([CreatedDate]
			,[CreatedBy]
			,[LastModifiedDate]
			,[LastModifiedBy]
			,[ArchivedInd]
			,[InformationSourceID]
			,[SourceChangeDate]
			,[Address]
			,[PrimaryInd]
			,[AddressTypeID]
			,[ParsedAddress]
			,[ParsedInd]
			,[ParsedScore]
			,[IndividualID]
			,[HashedAddress])
			VALUES
			(GETDATE()
			,@userid
			,GETDATE()
			,@userid
			,0
			,@informationsourceid
			,@SourceChangeDate
			,@Email
			,1
			,3
			,@Email
			,0
			,0
			,@IndividualID
			,@EncryptedEmail)		
		END
	

		BEGIN
			SELECT @AlertID  = ia.IndividualAlertID
			FROM Staging.STG_IndividualAlert ia
			WHERE ia.Email          = @Email          AND
				  ia.LocationFrom   = @From           AND
				  ia.LocationTo     = @To             AND
				  ia.OutwardJourney = @outwardJourney AND
				  ia.ReturnJourney  = @returnJourney  AND 
				  ia.ArchivedInd    = 0

			IF @@ROWCOUNT >  0
			BEGIN
				SET @ErrMsg = 'Alert already exists for Individual (' + @EncryptedEmail + ')';
				THROW 51403, @ErrMsg,1
			END

			INSERT INTO Staging.STG_IndividualAlert
			(Title,
			Forename,
			Surname,
			Email,
			EncryptedEmail,
			LocationFrom,
			LocationTo,
			AlertName,
			DurationStartDate,
			DurationEndDate,
			OutwardJourney,
			ReturnJourney,
			CreatedDate,
			CreatedBy,
			LastModifiedDate,
			LastModifiedBy
			)
			VALUES
			(@Title,
			@Forename,
			@Surname,
			@Email,
			@EncryptedEmail,
			@From,
			@To,
			@AlertName,
			@DurationStartDate,
			@DurationEndDate,
			@outwardJourney,
			@returnJourney,
			GETDATE(),
			@userid,
			GETDATE(),
			@userid
			)

			SET @RowCountRes = @@ROWCOUNT
			SET @AlertID = SCOPE_IDENTITY()		
		END

	END

    --IF @CustomerID IS NOT NULL
	IF @createdAnonymously =  CAST(0 AS BIT)
	BEGIN
		SELECT @AlertID  = ca.CustomerAlertID
		FROM Staging.STG_CustomerAlert ca
		WHERE ca.Email          = @Email          AND
			  ca.LocationFrom   = @From           AND
			  ca.LocationTo     = @To             AND
			  ca.OutwardJourney = @outwardJourney AND
			  ca.ReturnJourney  = @returnJourney  AND 
			  ca.ArchivedInd    = 0

		IF @@ROWCOUNT >  0
		BEGIN
			SET @ErrMsg = 'Alert already exists for CustomeRr (' + @EncryptedEmail + ')';
			THROW 51403, @ErrMsg,1
		END

		INSERT INTO Staging.STG_CustomerAlert
		(Title,
		Forename,
		Surname,
		Email,
		EncryptedEmail,
		LocationFrom,
		LocationTo,
		AlertName,
		DurationStartDate,
		DurationEndDate,
		OutwardJourney,
		ReturnJourney,
		CreatedDate,
		CreatedBy,
		LastModifiedDate,
		LastModifiedBy
		)
		VALUES
		(@Title,
		@Forename,
		@Surname,
		@Email,
		@EncryptedEmail,
		@From,
		@To,
		@AlertName,
		@DurationStartDate,
		@DurationEndDate,
		@outwardJourney,
		@returnJourney,
		GETDATE(),
		@userid,
		GETDATE(),
		@userid
		)

		SET @RowCountRes = @@ROWCOUNT
		SET @AlertID = SCOPE_IDENTITY()
	END

	RETURN @RowCountRes