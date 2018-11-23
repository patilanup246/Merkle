  CREATE PROCEDURE [api_customer].[setCustomersPreference]
     @userid int,
     @EncryptedEmail varchar(512),
     @preferenceID int,  -- Review Usage of PreferenceID
     @ChannelType varchar(150), -- Communication Channel for that preference
     @PreferenceType varchar(150), -- Subscription Type for this preference
  -- Columns to be updated ---------------
     @preferenceValue bit

  AS 
    set nocount on;


    DECLARE @informationsourceid int
    DECLARE @customerid int                
    DECLARE @sourcechangedate datetime     = GETDATE();
    DECLARE @archivedind bit               = 0
    DECLARE @subscriptionchanneltypeid int 
    DECLARE @optinind bit                  = @preferenceValue
    DECLARE @starttime datetime            = NULL
    DECLARE @endtime datetime              = NULL
    DECLARE @daysofweek nvarchar(16)       = NULL
    DECLARE @recordcount int               
    DECLARE @TotalRecordCount int          = 0
    DECLARE @CustomersPerEmail int         = 0
    DECLARE @CustomerXEmail int            = 0

    DECLARE @ErrMsg varchar(512)


    SELECT @CustomerXEmail = COUNT(1) 
      FROM api_customer.ContactInformation ci 
     WHERE ci.EncryptedEmail = @EncryptedEmail

    IF @CustomerXEmail > 1
      BEGIN
        SET @ErrMsg = 'Unable to modify the specified email. Multiple Customers per email.';
        THROW 51403, @ErrMsg,1
      END   

    -- CEM API is the InformationSource for this change
    SELECT @InformationSourceID = InformationSourceID
      FROM Reference.InformationSource
     WHERE Name = 'CEM API'
       AND ArchivedInd = 0

    IF @@ROWCOUNT = 0
      BEGIN
        SET @ErrMsg = 'Unable to find the specified Informaion Soucre (CEM API)';
        THROW 51403, @ErrMsg,1
      END         

    SELECT @subscriptionchanneltypeid = sct.SubscriptionChannelTypeID
      FROM Reference.SubscriptionChannelType sct INNER JOIN reference.ChannelType ct
        ON sct.ChannelTypeID = ct.ChannelTypeID INNER JOIN reference.SubscriptionType st
        ON sct.SubscriptionTypeID = st.SubscriptionTypeID
     WHERE sct.ArchivedInd = 0
       AND ct.name = @ChannelType
       AND st.Name = @PreferenceType

    IF @@ROWCOUNT = 0
      BEGIN
        SET @ErrMsg = 'Unable to find the specified Subscription Channel Type for Channel Type = ' + @ChannelType +' and Subscription Type = ' + @PreferenceType;
        THROW 51403, @ErrMsg,1
      END         

    SELECT @customerid = CustomerID 
      FROM api_customer.ContactInformation ci 
     WHERE ci.EncryptedEmail = @EncryptedEmail

    EXECUTE [Staging].[STG_CustomerSubscriptionPreference_Update] 
       @userid
      ,@InformationSourceID
      ,@customerid
      ,@sourcechangedate
      ,@archivedind
      ,@subscriptionchanneltypeid
      ,@preferenceValue
      ,@starttime
      ,@endtime
      ,@daysofweek
      ,@recordcount OUTPUT

  RETURN @recordcount;