CREATE PROCEDURE [api_customer].[setCustomersContactInfo]
     @userid int,
  -- Search criteria ---------------------
     @encryptedEmail varchar(max),
  -- Columns to be updated ---------------
     @contactPhoneNumber varchar(256) ,
     @contactEmail varchar(256)

  AS 
    set nocount on;

    -- Getting CEM API Information SourceID
    DECLARE @parsedind bit
    DECLARE @parsedscore int
    DECLARE @archivedind bit             
    DECLARE @recordcount int
    DECLARE @informationsourceid int 
    DECLARE @sourcemodifeddate datetime  = GETDATE()
    DECLARE @addresstypeid int
    DECLARE @address nvarchar(256)
    DECLARE @parsedaddress nvarchar(256)
    DECLARE @EmailRecordCount int        = 0
    DECLARE @MPNRecordCount int          = 0
    DECLARE @CustomerID int
    
    DECLARE @ErrMsg varchar(512)

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

    SELECT @CustomerID = CustomerID
      FROM Staging.STG_ElectronicAddress ea
     WHERE ea.[HashedAddress] = @encryptedEmail
       AND ea.ArchivedInd = 0 
       AND ea.PrimaryInd = 1 

   IF @@ROWCOUNT = 0
     BEGIN
      SET @ErrMsg = 'Unable to find a Customer for the specified encrypted Email ('+@encryptedEmail+')';
      THROW 51403, @ErrMsg,1
     END  

        
    IF (@contactEmail IS NOT NULL) AND 
       (NOT EXISTS (SELECT 1
                      FROM Staging.STG_ElectronicAddress ea
                     WHERE ea.CustomerID = @CustomerID
                       AND ea.Address = @contactEmail
                       AND ea.PrimaryInd = 1
                       AND ea.ArchivedInd = 0))
      BEGIN
        /* Updating Customer Email Address */
        SET @addresstypeid       = 3             -- Email
        SET @address             = @contactEmail
        SET @parsedaddress       = @contactEmail
        
        SELECT @parsedind   = COALESCE(ParsedInd, 1),
               @parsedscore = ParsedScore,
               @archivedind = ArchivedInd
          FROM Staging.STG_ElectronicAddress 
         WHERE CustomerID    = @CustomerID
           AND AddressTypeID = @addresstypeid
           AND PrimaryInd    = 1;

		IF ( @parsedind IS NULL )
			SET @parsedind = 1

		IF ( @parsedscore IS NULL )
		    SET @parsedscore = 0

		IF ( @archivedind IS NULL )
			SET @archivedind = 0

        EXECUTE [Staging].[STG_ElectronicAddress_Update] 
             @userid              = @userid
            ,@informationsourceid = @informationsourceid
            ,@customerid          = @CustomerID
            ,@sourcemodifeddate   = @sourcemodifeddate
            ,@address             = @address
            ,@parsedaddress       = @parsedaddress
            ,@parsedind           = @parsedind
            ,@parsedscore         = @parsedscore
            ,@addresstypeid       = @addresstypeid
            ,@archivedind         = @archivedind
            ,@recordcount         = @EmailRecordCount  OUTPUT
        
        IF @EmailRecordCount = 0
           BEGIN
             SET @ErrMsg = 'Unable to update CustomerID ('+CAST(@CustomerID AS VARCHAR(250))+') email';
             THROW 90508, @ErrMsg,1
           END   
      END

    IF (@contactPhoneNumber IS NOT NULL) AND 
       (NOT EXISTS (SELECT 1
                      FROM Staging.STG_ElectronicAddress ea
                     WHERE ea.CustomerID = @CustomerID
                       AND ea.Address = @contactPhoneNumber
                       AND ea.PrimaryInd = 1
                       AND ea.ArchivedInd = 0))
      BEGIN
        /* Updating Customer Mobile Phone Number */
        SET @addresstypeid       = 4             -- Phone
        SET @address             = @contactPhoneNumber
        SET @parsedaddress       = @contactPhoneNumber
        
        SELECT @parsedind   = COALESCE(ParsedInd, 1),
               @parsedscore = ParsedScore,
               @archivedind = ArchivedInd
          FROM Staging.STG_ElectronicAddress 
         WHERE CustomerID    = @CustomerID
           AND AddressTypeID = @addresstypeid
           AND PrimaryInd    = 1;

		IF ( @parsedind IS NULL )
			SET @parsedind = 1

		IF ( @parsedscore IS NULL )
		    SET @parsedscore = 0

		IF ( @archivedind IS NULL )
			SET @archivedind = 0

        EXECUTE [Staging].[STG_ElectronicAddress_Update] 
             @userid              = @userid
            ,@informationsourceid = @informationsourceid
            ,@CustomerID          = @CustomerID
            ,@sourcemodifeddate   = @sourcemodifeddate
            ,@address             = @address
            ,@parsedaddress       = @parsedaddress
            ,@parsedind           = @parsedind
            ,@parsedscore         = @parsedscore
            ,@addresstypeid       = @addresstypeid
            ,@archivedind         = @archivedind
            ,@recordcount         = @MPNRecordCount OUTPUT

        IF @MPNRecordCount = 0
         BEGIN
           SET @ErrMsg = 'Unable to update CustomerID ('+CAST(@CustomerID AS VARCHAR(256))+') phone number';
           THROW 90508, @ErrMsg,1
         END   
        
      END

    IF (@MPNRecordCount = 0 AND @EmailRecordCount = 0)
      return 0
    ELSE
      return 1