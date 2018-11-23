  CREATE PROCEDURE [api_customer].[setCustomersAddress] 
     @userid     int,          -- who has requested the action
     @encryptedEmail varchar(max),
     @address1   varchar(512) = NULL,
     @address2   varchar(512) = NULL,
     @address3   varchar(512) = NULL,
     @address4   varchar(512) = NULL,
     @address5   varchar(512) = NULL,
     @city       varchar(512) = NULL,
     @county     varchar(512) = NULL,
     @postcode   varchar(512) = NULL,
     @country    varchar(512) = NULL
  ----------------------------------------
  AS 


   set nocount on;

   DECLARE @CreatedDate datetime        = GETDATE()
   DECLARE @LastModifiedDate datetime   = GETDATE()

   DECLARE @SourceCreatedDate datetime  = GETDATE()
   DECLARE @SourceModifiedDate datetime = GETDATE()

   DECLARE @ArchivedInd int             = 0
   DECLARE @PrimaryInd int              = 1
   DECLARE @AddressTypeID int           = 1 -- Postal Address
   DECLARE @CustomerID int              = 0

   DECLARE @countryID int;
   DECLARE @InformationSourceID int 

   DECLARE @ErrMsg varchar(512)
   DECLARE @RowCount int = 0;

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

   -- Getting Country ID from Country Name
   SELECT @countryID = CountryID
     FROM Reference.Country C
    WHERE C.Name = @country;

   IF @@ROWCOUNT = 0
     BEGIN
      SET @ErrMsg = 'Unable to find the specified country ('+@country+')';
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
    -- Logical delete of the current address
    /* No error control applied.
       Reason: We can have a customer without address.*/
   IF NOT EXISTS ( SELECT 1 
                     FROM Staging.STG_Address a           
                    WHERE a.AddressLine1 = @address1
                      AND a.AddressLine2 = @address2
                      AND a.AddressLine3 = @address3
                      AND a.AddressLine4 = @address4
                      AND a.AddressLine5 = @address5
                      AND a.TownCity     = @city
                      AND a.County       = @county
                      AND a.PostalCode   = @postcode
                      AND a.CountryID    = @CountryID 
                      AND a.CustomerID   = @CustomerID)
     BEGIN
       UPDATE Staging.STG_Address
          SET ArchivedInd      = 1, 
              LastModifiedBy   = @userid,
              LastModifiedDate = GETDATE(),
              PrimaryInd       = 0 
        WHERE CustomerID    = @CustomerID
          AND AddressTypeID = 1
          AND PrimaryInd    = 1;
     END
   
   -- Inserting new Customer Postal Address Information
   INSERT INTO Staging.STG_Address
     ( CreatedDate,
       CreatedBy,
       LastModifiedDate,
       LastModifiedBy,
       ArchivedInd,
       InformationSourceID,
       SourceCreatedDate,
       SourceModifiedDate,
       AddressLine1,
       AddressLine2,
       AddressLine3,
       AddressLine4,
       AddressLine5,
       TownCity,
       County,
       PostalCode,
       CountryID,
       PrimaryInd,
       AddressTypeID,
       CustomerID )
    VALUES
     ( @CreatedDate,
       @userid,
       @LastModifiedDate,
       @userid,
       @ArchivedInd,
       @InformationSourceID,
       @SourceCreateDDate,
       @SourceModifiedDate,
       @address1,
       @address2,
       @address3,
       @address4,
       @address5,
       @city,
       @County,
       @postcode,
       @CountryID,
       @PrimaryInd,
       @AddressTypeID,
       @CustomerID )
    
   SET @RowCount = @@ROWCOUNT
   


   IF @RowCount = 0
     BEGIN
      SET @ErrMsg = 'Unable to add Address';
      THROW 90508, @ErrMsg,1
   END  
    return @RowCount;