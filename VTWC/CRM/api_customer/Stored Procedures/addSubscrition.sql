

  CREATE PROCEDURE [api_customer].[addSubscrition]
     @userid int,
     @TypeID varchar(3),
     @EncryptedEmail varchar(4000),
     @Salutation varchar(64),
     @Forename varchar(64),
     @Surname varchar(64),
     @Email varchar(256)   
   
  AS 
    
    set nocount on;

    -- Validating that provided email match with the encrypted email
    IF (@EncryptedEmail != Staging.[VT_HASH](lower(@Email)))
      THROW 51403, 'Invalid Encrypted Email',1

    IF (@TypeID != 'NWL')
      THROW 51403, 'Invalid Subscription Type',1



    DECLARE @CustomerID int
    DECLARE @IndividualID int
    DECLARE @SubscriptionChannelTypeID int
    DECLARE @InformationSourceID int
    DECLARE @RecordCount int
    DECLARE @SourceChangeDate DATETIME = GETDATE()
	DECLARE @lowerEmail varchar(256) = lower(@Email)
    DECLARE @ErrMsg varchar(max)

    EXEC api_shared.getNewsletterIDs
      @InformationSourceID       = @InformationSourceID OUTPUT,
      @SubscriptionChannelTypeID = @SubscriptionChannelTypeID OUTPUT  

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

    -- Check if that email is already subscribed
    IF EXISTS (SELECT DISTINCT CAST(Registered AS BIT) 
                 FROM ( SELECT 1 AS Registered
                          FROM api_customer.CustomerSubscription
                         WHERE EncryptedEmail = @EncryptedEmail) res)
      THROW 51403, 'The provided email is already subscribed', 1
    


    IF (@CustomerID IS NOT NULL)
      BEGIN
        EXEC [Staging].[STG_CustomerSubscriptionPreference_Update]
          @userid                      = @userid,   
          @informationsourceid         = @InformationSourceID,
          @customerid                  = @CustomerID,
          @sourcechangedate            = @SourceChangeDate,
          @archivedind                 = 0,
          @subscriptionchanneltypeid   = @SubscriptionChannelTypeID,
          @optinind                    = 1,
          @recordcount                 = @RecordCount OUTPUT            
      END
    ELSE
      BEGIN

        IF ( @IndividualID IS NULL)
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
          END

          IF @IndividualID IS NULL
             BEGIN
               SET @ErrMsg = 'Unable to create an individual';
               THROW 51403, @ErrMsg,1
             END  
          
          -- Associate electronica address (email) to the new individual
          BEGIN
              DECLARE @electronicaddressid int
              
              SELECT @electronicaddressid = ElectronicAddressID
                  FROM [Staging].[STG_ElectronicAddress]
                 WHERE IndividualID = @IndividualID
                   AND [HashedAddress] = @EncryptedEmail
                   and ArchivedInd = 0

              IF @electronicaddressid IS NULL
                BEGIN
                  

                  EXEC [Staging].[STG_IndividualElectronicAddress_Add]
                    @userid                 = @userid,   
                    @informationsourceid    = @InformationSourceID,
                    @individualid           = @IndividualID,
                    @sourcemodifeddate      = @SourceChangeDate,
                    @address                = @lowerEmail,
                    @parsedaddress          = @lowerEmail,
                    @parsedind              = 0,
                    @parsedscore            = 0,
                    @addresstypeid          = 3,
                    @archivedind            = 0,
                    @electronicaddressid    = @electronicaddressid OUTPUT

                  IF @electronicaddressid IS NULL
                     BEGIN
                       SET @ErrMsg = 'Unable to create an ElectronicAddress Record for IndividualID ('+ CAST(@IndividualID AS VARCHAR(15)) +')';
                       THROW 51403, @ErrMsg,1
                     END            
                END
            
          
            -- Create Subscription for that Individual
            BEGIN
              EXEC [Staging].[STG_IndividualSubscriptionPreference_Update]
                @userid                       = @userid,   
                @informationsourceid          = @InformationSourceID,
                @individualid                 = @IndividualID,
                @sourcechangedate             = @SourceChangeDate,
                @archivedind                  = 0,
                @subscriptionchanneltypeid    = @SubscriptionChannelTypeID,
                @optinind                     = 1,
                @recordcount                  = @RecordCount OUTPUT            
                
            END
          END
      END

    IF (@RecordCount = 0)
      RETURN 0
    ELSE
      RETURN 1