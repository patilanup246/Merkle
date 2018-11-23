CREATE PROCEDURE [api_customer].[insertCustomerPreference] 
     @userid      int,          -- who has requested the action
     @OptionName    varchar(256) = NULL,
     @EncryptedEmail  varchar(512) = NULL,
     @TCSCustomerID   int = NULL,
     @PreferenceId    int = NULL,
     @Value       bit = NULL
     
  AS 
  select 1
  --  set nocount on;
   
  --  DECLARE @CustomerId int = NULL
  --  DECLARE @CustomerXEmail int = 0
  --  DECLARE @OptionId int = NULL
  --  DECLARE @ErrMsg varchar(512)
  --  DECLARE @RowCount int = 0

  ---- Check if customer identifiers are not null
  --IF @EncryptedEmail IS NULL and @TCSCustomerID IS NULL
  --BEGIN
  --  SET @ErrMsg = 'Customer identifier cannot be NULL';
  --  THROW 90508, @ErrMsg,1
  --END

  ---- Get Encrypted email from TCS Customer ID
  --IF @TCSCustomerID IS NOT NULL
  --BEGIN
  --  SELECT @EncryptedEmail = ea.EncrytpedAddress
  --    FROM Staging.STG_KeyMapping AS km WITH (NOLOCK) INNER JOIN
  --         Staging.STG_ElectronicAddress AS ea WITH (NOLOCK) ON km.CustomerID = ea.CustomerID
  --   WHERE km.TCSCustomerID = @TCSCustomerID
  --     AND ea.ArchivedInd = 0
  --     AND ea.AddressTypeID = 3
  --     AND ea.EncrytpedAddress IS NOT NULL

  --  IF @EncryptedEmail IS NULL
  --  BEGIN
  --    SET @ErrMsg = 'TCS id '+ CAST(@TCSCustomerID AS VARCHAR(20)) +' is not recognised by CEM';
  --    THROW 90508, @ErrMsg,1
  --  END    

  --END
    
  ---- Check if Preference Value is NULL
  --IF @Value IS NULL 
  --BEGIN
  --  SET @ErrMsg = 'Value cannot be NULL';
  --  THROW 90508, @ErrMsg,1
  --END

  ---- Check if OptionName is NULL
  --IF @OptionName IS NULL 
  --BEGIN
  --  SET @ErrMsg = 'OptionName cannot be NULL';
  --  THROW 90508, @ErrMsg,1
  --END

  ---- Check if CustomerId is NULL
  --IF @CustomerId IS NULL 
  --BEGIN
  --  SET @ErrMsg = 'CustomerId cannot be NULL';
  --  THROW 90508, @ErrMsg,1
  --END

  ---- Check if PreferenceId is NULL
  --IF @PreferenceId IS NULL 
  --BEGIN
  --  SET @ErrMsg = 'PreferenceId cannot be NULL';
  --  THROW 90508, @ErrMsg,1
  --END
  
  ---- Check if the specified preference exists and it is not deleted
  --IF NOT EXISTS (SELECT 1 FROM Staging.STG_Preference WITH (NOLOCK) WHERE PreferenceID = @PreferenceId and ArchivedInd = 0)
  --BEGIN
  --  SET @ErrMsg = 'The preference with id (' + CAST(@PreferenceId as varchar) + ') does not exist or has been deleted.';
  --  THROW 90508, @ErrMsg,1    
  --END 
    
  --  -- Check if the specified option exists for the specified preference in CEM
  --SELECT @OptionId = OptionID
  --FROM Staging.STG_PreferenceOptions WITH (NOLOCK)
  --WHERE OptionName = @OptionName and PreferenceID = @PreferenceId

  --IF @OptionId IS NULL
  --  BEGIN
  --  SET @ErrMsg = 'The preference option (' + @OptionName + ') does not exist for the preference with id (' + CAST(@PreferenceId as varchar) + ')';
  --  THROW 90508, @ErrMsg,1
  --END     

  --  --Check if there are multiple customers per email
  --SELECT @CustomerXEmail = COUNT(1) 
  --  FROM api_customer.ContactInformation ci WITH (NOLOCK) 
  --  WHERE ci.EncryptedEmail = @EncryptedEmail
  --    AND ci.EncryptedEmail IS NOT NULL
      
  --  IF @CustomerXEmail > 1
  --  BEGIN
  --      SET @ErrMsg = 'Unable to modify the specified email. Multiple Customers per email.';
  --      THROW 51403, @ErrMsg,1
  --  END   
           
  ----Get CustomerID
  --  SELECT @CustomerId = CustomerID
  --    FROM Staging.STG_ElectronicAddress ea WITH (NOLOCK)
  --   WHERE ea.EncrytpedAddress = @encryptedEmail
  --     AND ea.ArchivedInd = 0 
  --     AND ea.PrimaryInd = 1 
  
  ---- Check if CustomerId is NULL
  --IF @CustomerId IS NULL 
  --BEGIN
  --  SET @ErrMsg = 'Customer does not exist';
  --  THROW 90508, @ErrMsg,1
  --END

  ---- Insert customer preference data
  --IF EXISTS (SELECT 1 
  --       FROM Staging.STG_CustomerPreference WITH (NOLOCK)
  --       WHERE CustomerID = @CustomerId AND OptionID = @OptionId)
  --BEGIN
  --  SET @ErrMsg = 'The preference option (' + @OptionName + ') already exist for the customer with id (' + CAST(@CustomerId as varchar) + ')';
  --  THROW 90508, @ErrMsg,1
  --END
  --ELSE
  --BEGIN 
  --  INSERT INTO Staging.STG_CustomerPreference
  --  (
  --  CustomerID,
  --  OptionID,
  --  PreferenceValue,
  --  CreatedDate,
  --  CreatedBy,
  --  LastModifiedDate,
  --  LastModifiedBy,
  --  ArchivedInd
  --  )
  --  VALUES
  --  ( 
  --  @CustomerId,
  --  @OptionId, 
  --  @Value,
  --  GETDATE(),
  --  @userid,
  --  GETDATE(),
  --  @userid,
  --  0
  --  )
  --END   
    
  --SET @RowCount = @@ROWCOUNT
  
  --IF @RowCount = 0
  --BEGIN
  --  SET @ErrMsg = 'Unable to add Customer Preference' ;
  --  THROW 90508, @ErrMsg,1
  --END
  
  --  RETURN @RowCount
