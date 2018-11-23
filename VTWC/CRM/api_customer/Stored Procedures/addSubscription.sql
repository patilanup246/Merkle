CREATE PROCEDURE [api_customer].[addSubscription]
     @userid int = NULL,
     @TypeID varchar(3) = NULL,
     @EncryptedEmail varchar(4000) = NULL,
     @TCSCustomerID int = NULL,
     @Salutation varchar(64),
     @Forename varchar(64),
     @Surname varchar(64),
     @Email varchar(256) = NULL  
   
  AS 
    
    set nocount on

    DECLARE @CustomerID int = NULL
    DECLARE @IndividualID int = NULL
    DECLARE @CustomerXEmail int = 0
    DECLARE @DecryptedEmail varchar(256) = NULL
    DECLARE @SubscriptionTypeID int = NULL
    DECLARE @SubscriptionChannelTypeID int = NULL
    DECLARE @InformationSourceID int
    DECLARE @RowCount int = 0
    DECLARE @RowCountTotal int = 0
    DECLARE @SourceChangeDate DATETIME = GETDATE()
    DECLARE @ErrMsg varchar(max)
    DECLARE @SubscriptionArchiveInd bit

  --Getting Information Source
  SELECT @InformationSourceID = InformationSourceID 
  FROM [Reference].[InformationSource] WITH (NOLOCK) 
  WHERE Name = 'Website - Newsletter Signup' 

  -- Check if customer identifiers are not null
  IF @EncryptedEmail IS NULL and @TCSCustomerID IS NULL
  BEGIN
    SET @ErrMsg = 'Customer identifier cannot be NULL';
    THROW 90508, @ErrMsg,1
  END

  -- Get Encrypted email from TCS Customer ID
  IF @TCSCustomerID IS NOT NULL
  BEGIN
    SELECT @EncryptedEmail = ea.[HashedAddress]
     FROM Staging.STG_KeyMapping AS km WITH (NOLOCK) INNER JOIN
          Staging.STG_ElectronicAddress AS ea WITH (NOLOCK) ON km.CustomerID = ea.CustomerID
    WHERE km.TCSCustomerID = @TCSCustomerID
      AND ea.ArchivedInd = 0
      AND ea.AddressTypeID = 3

    IF @EncryptedEmail IS NULL
    BEGIN

      -- IF TCS Customer ID does not exists into CEM then store 
      -- Subscription Preference on PreProcessing area
      INSERT INTO PreProcessing.API_CustomerSubscription
        ([CreatedDate]
        ,[CreatedBy]
        ,[LastModifiedDate]
        ,[LastModifiedBy]
        ,[ArchivedInd]
        ,[TCSCustomerID]
        ,[SubscriptionChannelTypeID]
        ,[OptInInd]
        ,[StartTime]
        ,[EndTime]
        ,[DaysofWeek]
        ,[InformationSourceID]
        ,[ProcessedInd]
        ,[DataImportDetailID] )
        SELECT GETDATE()
              ,@userid
              ,GETDATE()
              ,@userid
              ,0
              ,@TCSCustomerID
              ,SubscriptionChannelTypeID
              ,1
              ,NULL
              ,NULL
              ,NULL
              ,@InformationSourceID
              ,0
              ,NULL
         FROM Reference.SubscriptionChannelType sct WITH (NOLOCK) 
              INNER JOIN Reference.SubscriptionType st WITH (NOLOCK) ON sct.SubscriptionTypeID = st.SubscriptionTypeID
        WHERE st.MessageTypeCd = @TypeID

        SET @RowCount = @@ROWCOUNT
        IF @RowCount = 0
          BEGIN
            SET @ErrMsg = 'Unable to add subscription to Customer ' + CAST(@TCSCustomerID AS VARCHAR(15));
            THROW 90508, @ErrMsg,1
          END
        ELSE
          BEGIN
            RETURN 1
          END

    END      
  END

  -- Check if @userid is NULL
  IF @userid IS NULL 
  BEGIN
    SET @ErrMsg = 'User Id cannot be NULL';
    THROW 90508, @ErrMsg,1
  END

  -- Check if @TypeID is NULL
  IF @TypeID IS NULL 
  BEGIN
    SET @ErrMsg = 'TypeID cannot be NULL';
    THROW 90508, @ErrMsg,1
  END

  -- Check if @EncryptedEmail is NULL
  IF @EncryptedEmail IS NULL 
  BEGIN
    SET @ErrMsg = 'Customer identifier cannot be NULL';
    THROW 90508, @ErrMsg,1
  END

  IF @Email IS NOT NULL 
  BEGIN
    IF Staging.[VT_HASH](@email) <> @EncryptedEmail
    BEGIN
      SET @ErrMsg = 'Email address does not match the provided ID.';
      THROW 90508, @ErrMsg,1
    END
  END
  
  --Check if there are multiple customers per email
  SELECT @CustomerXEmail = COUNT(1) 
    FROM api_customer.ContactInformation ci WITH (NOLOCK) 
    WHERE ci.EncryptedEmail = @EncryptedEmail

    IF @CustomerXEmail > 1
    BEGIN
        SET @ErrMsg = 'Unable to modify the specified email. Multiple Customers per email.';
        THROW 51403, @ErrMsg,1
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
             
  -- Check if CustomerId is NULL
  IF @CustomerId IS NULL 
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
            @salutation             = @Salutation,
            @firstname              = @Forename,
            @lastname               = @Surname,
            @individualid           = @IndividualID OUTPUT    

      
      IF @Email IS NULL
      BEGIN
        SET @ErrMsg = 'An email address must be provided when subscribing an unknown customer.';
        THROW 51403, @ErrMsg,1
      END

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
  END   
  
  -- Check if subscription type exists
  SELECT @SubscriptionTypeID = SubscriptionTypeID
    FROM Reference.SubscriptionType WITH (NOLOCK)
   WHERE MessageTypeCd = @TypeID

  IF @SubscriptionTypeID IS NULL
  BEGIN
    SET @ErrMsg = 'The subscription type (' + @TypeID + ') does not exist';
    THROW 90508, @ErrMsg,1
  END

  IF NOT EXISTS (SELECT 1
           FROM Reference.SubscriptionChannelType WITH (NOLOCK)
           WHERE SubscriptionTypeID = @SubscriptionTypeID)
  BEGIN
    SET @ErrMsg = 'The subscription type (' + @TypeID + ') is not associated to any channel';
    THROW 90508, @ErrMsg,1
  END

    -- Declare cursor to go through all channels associated with the subscription
  DECLARE CurChannelType CURSOR FAST_FORWARD READ_ONLY
  FOR
    SELECT  SubscriptionChannelTypeID
    FROM    Reference.SubscriptionChannelType WITH (NOLOCK)
    WHERE SubscriptionTypeID = @SubscriptionTypeID
    ORDER BY SubscriptionChannelTypeID

  OPEN CurChannelType

  FETCH NEXT FROM CurChannelType INTO @SubscriptionChannelTypeID

  WHILE @@FETCH_STATUS = 0
    BEGIN 
    
    IF @CustomerID IS NOT NULL
    BEGIN
      --Check if the subscription already exists for Customer
      SELECT  @SubscriptionArchiveInd = ArchivedInd 
      FROM (SELECT row_number() over(partition by CustomerId,SubscriptionChannelTypeID 
          order by SourceChangeDate desc) RNK, ArchivedInd
          FROM [Staging].[STG_CustomerSubscriptionPreference] WITH (NOLOCK)
          WHERE CustomerID =  @CustomerID AND SubscriptionChannelTypeID = @SubscriptionChannelTypeID) RES
      WHERE RES.RNK = 1

      IF (@SubscriptionArchiveInd != 0 OR @SubscriptionArchiveInd IS NULL ) -- Cater for new SubscriptionChannelTypes
      BEGIN

        INSERT INTO [Staging].[STG_CustomerSubscriptionPreference]
        ([Name]
        ,[Description]
        ,[CreatedDate]
        ,[CreatedBy]
        ,[LastModifiedDate]
        ,[LastModifiedBy]
        ,[ArchivedInd]
        ,[SourceChangeDate]
        ,[CustomerID]
        ,[SubscriptionChannelTypeID]
        ,[OptInInd]
        ,[StartTime]
        ,[EndTime]
        ,[DaysofWeek]
        ,[InformationSourceID])
        VALUES
        (NULL
        ,NULL
        ,GETDATE()
        ,@userid
        ,GETDATE()
        ,@userid
        ,0
        ,GETDATE()
        ,@CustomerID
        ,@SubscriptionChannelTypeID
        ,1
        ,NULL
        ,NULL
        ,NULL
        ,@InformationSourceID)
              
        SET @RowCount = @@ROWCOUNT
        PRINT CAST(@RowCount as varchar)
        IF @RowCount = 0
        BEGIN
          CLOSE CurChannelType
          DEALLOCATE CurChannelType
          SET @ErrMsg = 'Unable to add subscription to Customer';
          THROW 90508, @ErrMsg,1
        END

      END    


    END
    ELSE
    BEGIN
      --Check if the subscription already exists for Individual
      SELECT  @SubscriptionArchiveInd = ArchivedInd 
       FROM ( SELECT row_number() 
                   over( partition by IndividualID, 
                        SubscriptionChannelTypeID 
                   order by SourceChangeDate desc) RNK, 
               ArchivedInd
            FROM [Staging].[STG_IndividualSubscriptionPreference] WITH (NOLOCK)
           WHERE IndividualID =  @IndividualID 
             AND SubscriptionChannelTypeID = @SubscriptionChannelTypeID) RES
      WHERE RES.RNK = 1

      IF (@SubscriptionArchiveInd != 0 OR @SubscriptionArchiveInd IS NULL ) -- Cater for new SubscriptionChannelTypes
      BEGIN
        INSERT INTO [Staging].[STG_IndividualSubscriptionPreference]
        ([Name]
        ,[Description]
        ,[CreatedDate]
        ,[CreatedBy]
        ,[LastModifiedDate]
        ,[LastModifiedBy]
        ,[ArchivedInd]
        ,[SourceChangeDate]
        ,[IndividualID]
        ,[SubscriptionChannelTypeID]
        ,[OptInInd]
        ,[StartTime]
        ,[EndTime]
        ,[DaysofWeek]
        ,[InformationSourceID])
        VALUES
        (NULL
        ,NULL
        ,GETDATE()
        ,@userid
        ,GETDATE()
        ,@userid
        ,0
        ,GETDATE()
        ,@IndividualID
        ,@SubscriptionChannelTypeID
        ,1
        ,NULL
        ,NULL
        ,NULL
        ,@InformationSourceID)
              
        SET @RowCount = @@ROWCOUNT
        PRINT CAST(@RowCount as varchar)
        IF @RowCount = 0
        BEGIN
          CLOSE CurChannelType
          DEALLOCATE CurChannelType
          SET @ErrMsg = 'Unable to add subscription to Individual'; 
          THROW 90508, @ErrMsg,1
        END     
      END

    END
        FETCH NEXT FROM CurChannelType INTO @SubscriptionChannelTypeID
    END

  CLOSE CurChannelType
  DEALLOCATE CurChannelType
    
    RETURN 1 /* Updated to change from @RowCount to 1 */