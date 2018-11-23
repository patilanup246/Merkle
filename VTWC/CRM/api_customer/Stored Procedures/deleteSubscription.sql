CREATE PROCEDURE [api_customer].[deleteSubscription]
     @userid int,
     @TypeID varchar(3),
     @EncryptedEmail varchar(4000) = NULL,
     @TCSCustomerID int = NULL
  ----------------------------------------
  AS 
  
    set nocount on;
    
    DECLARE @CustomerID int
    DECLARE @IndividualID int
    DECLARE @SubscriptionTypeID int
    DECLARE @SubscriptionChannelTypeID int
    DECLARE @InformationSourceID int
    DECLARE @RowCount int = 0
    DECLARE @SourceChangeDate DATETIME = GETDATE()
    DECLARE @CustomerXEmail int = 0  
    DECLARE @ErrMsg varchar(512)

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
      SET @ErrMsg = 'TCS id '+ CAST(@TCSCustomerID AS VARCHAR(20)) +' is not recognised by CEM';
      THROW 90508, @ErrMsg,1
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
    SET @ErrMsg = 'EncryptedEmail cannot be NULL';
    THROW 90508, @ErrMsg,1
  END

    SELECT @CustomerXEmail = COUNT(1) 
    FROM api_customer.ContactInformation ci 
    WHERE ci.EncryptedEmail = @EncryptedEmail

    IF @CustomerXEmail > 1
    BEGIN
        SET @ErrMsg = 'Unable to modify the specified email. Multiple Customers per email.';
        THROW 51403, @ErrMsg,1
    END  

  -- Does this encrypted email belongs to an existing customer?
    BEGIN TRY
      EXEC api_shared.getCustomerID @EncryptedEmail, @CustomerID OUTPUT
    END TRY
    BEGIN CATCH
      PRINT 'Unable to find CustomerID for Encrypted Email ('+@EncryptedEmail+')'
    END CATCH

  -- Does this encrypted email belongs to an existing individual?
    BEGIN TRY
      EXEC api_shared.getIndividualID @EncryptedEmail, @IndividualID OUTPUT
    END TRY
    BEGIN CATCH
      PRINT 'Unable to find IndividualID for Encrypted Email ('+@EncryptedEmail+')'
    END CATCH 
  
  IF @CustomerID IS NULL and @IndividualID IS NULL
  BEGIN
    SET @ErrMsg = 'Unable to find Customer or Individual id for Encrypted Email ('+@EncryptedEmail+')';
    THROW 90508, @ErrMsg,1
  END

  -- Check if subscription type exists
  SELECT @SubscriptionTypeID = SubscriptionTypeID
  FROM Reference.SubscriptionType
  WHERE MessageTypeCd = @TypeID

  IF @SubscriptionTypeID IS NULL
  BEGIN
    SET @ErrMsg = 'The subscription type (' + @TypeID + ') does not exist';
    THROW 90508, @ErrMsg,1
  END

  -- Check if there are subscription for the customer
  IF EXISTS(SELECT 1
        FROM Reference.SubscriptionType st INNER JOIN Reference.SubscriptionChannelType sct ON st.SubscriptionTypeID = sct.SubscriptionTypeID
                         INNER JOIN Staging.STG_CustomerSubscriptionPreference csp ON sct.SubscriptionChannelTypeID = csp.SubscriptionChannelTypeID
        WHERE st.MessageTypeCd = @TypeID AND csp.CustomerID = @CustomerID AND csp.ArchivedInd = 0)
  BEGIN
    -- Declare cursor to go through all channels associated with the subscription
    DECLARE CurChannelType CURSOR FAST_FORWARD READ_ONLY
    FOR
      SELECT  SubscriptionChannelTypeID
      FROM    Reference.SubscriptionChannelType
      WHERE SubscriptionTypeID = @SubscriptionTypeID
      ORDER BY SubscriptionChannelTypeID
    OPEN CurChannelType

    FETCH NEXT FROM CurChannelType INTO @SubscriptionChannelTypeID

    WHILE @@FETCH_STATUS = 0
    BEGIN   

      IF EXISTS (SELECT 1 
             FROM Staging.STG_CustomerSubscriptionPreference
             WHERE CustomerID = @CustomerID AND SubscriptionChannelTypeID = @SubscriptionChannelTypeID AND ArchivedInd = 0)
      BEGIN     
        --Delete the row
        UPDATE Staging.STG_CustomerSubscriptionPreference SET ArchivedInd = 1
        WHERE CustomerID = @CustomerID AND SubscriptionChannelTypeID = @SubscriptionChannelTypeID AND ArchivedInd = 0
      
        SET @RowCount = @@ROWCOUNT
        IF @RowCount = 0
        BEGIN
          SET @ErrMsg = 'Error deleting customer subscription data (Customer ID:' + CAST(@CustomerID as varchar) + ',Encrypted Email: ' + @EncryptedEmail + ', Subscription Type:' + CAST(@TypeID as varchar) + ')';
          THROW 90508, @ErrMsg,1
        END
      END
    
      FETCH NEXT FROM CurChannelType INTO @SubscriptionChannelTypeID
    END

    CLOSE CurChannelType
    DEALLOCATE CurChannelType
  END
  ELSE
  BEGIN
    IF EXISTS(SELECT 1
          FROM Reference.SubscriptionType st INNER JOIN Reference.SubscriptionChannelType sct ON st.SubscriptionTypeID = sct.SubscriptionTypeID
                           INNER JOIN Staging.STG_IndividualSubscriptionPreference isp ON sct.SubscriptionChannelTypeID = isp.SubscriptionChannelTypeID
          WHERE st.MessageTypeCd = @TypeID AND isp.IndividualID = @IndividualID AND isp.ArchivedInd = 0)
    BEGIN
      -- Declare cursor to go through all channels associated with the subscription
      DECLARE CurChannelType CURSOR FAST_FORWARD READ_ONLY
      FOR
        SELECT  SubscriptionChannelTypeID
        FROM    Reference.SubscriptionChannelType
        WHERE SubscriptionTypeID = @SubscriptionTypeID
        ORDER BY SubscriptionChannelTypeID
      OPEN CurChannelType

      FETCH NEXT FROM CurChannelType INTO @SubscriptionChannelTypeID

      WHILE @@FETCH_STATUS = 0
      BEGIN   

        IF EXISTS (SELECT 1 
               FROM Staging.STG_IndividualSubscriptionPreference
               WHERE IndividualID = @IndividualID AND SubscriptionChannelTypeID = @SubscriptionChannelTypeID AND ArchivedInd = 0)
        BEGIN
          --Delete the row
          UPDATE Staging.STG_IndividualSubscriptionPreference SET ArchivedInd = 1
          WHERE IndividualID = @IndividualID AND SubscriptionChannelTypeID = @SubscriptionChannelTypeID AND ArchivedInd = 0   
      
          SET @RowCount = @@ROWCOUNT
          IF @RowCount = 0
          BEGIN
            SET @ErrMsg = 'Error deleting individual subscription data (Individual ID:' + CAST(@IndividualID as varchar) + ',Encrypted Email: ' + @EncryptedEmail + ', Subscription Type:' + CAST(@TypeID as varchar) + ')';
            THROW 90508, @ErrMsg,1
          END
        END
    
        FETCH NEXT FROM CurChannelType INTO @SubscriptionChannelTypeID
      END

      CLOSE CurChannelType
      DEALLOCATE CurChannelType
    END
    
  END
    
    RETURN 1