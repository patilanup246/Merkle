  CREATE PROCEDURE [api_customer].[setCustomersPersonalDetails]
     @userid int,
     @encryptedEmail varchar(max),
  -- Columns to be updated ---------------
     @salutation varchar(512),
     @forename varchar(512),
     @surname varchar(512)

  AS 
    set nocount on;

    DECLARE @informationsourceid int
    DECLARE @sourcemodifieddate datetime  = GETDATE()
    DECLARE @archivedind bit              = 0
    DECLARE @middlename nvarchar(64)      = NULL
    DECLARE @datefirstpurchase datetime
    DECLARE @recordcount int = 0
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


    SELECT @datefirstpurchase=  MIN(SalesTransactionDate) 
      FROM Staging.STG_SalesTransaction 
     WHERE CustomerID = @CustomerID
       AND SalesTransactionDate IS NOT NULL;

    EXECUTE [Staging].[STG_Customer_Update] 
       @userid
      ,@informationsourceid
      ,@CustomerID
      ,@sourcemodifieddate
      ,@archivedind
      ,@salutation
      ,@forename
      ,@middlename
      ,@surname
      ,@datefirstpurchase
      ,@recordcount OUTPUT

    return @recordcount;