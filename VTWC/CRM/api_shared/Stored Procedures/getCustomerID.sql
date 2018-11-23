
  CREATE PROCEDURE [api_shared].[getCustomerID]
    @EncryptedEmail VARCHAR(256),
    @CustomerID int OUTPUT  
  AS
    BEGIN

      DECLARE @ErrMsg VARCHAR(MAX)

      SELECT @CustomerID = ea.CustomerID
        FROM Staging.STG_ElectronicAddress ea
       WHERE ea.AddressTypeID = 3 -- Email
         AND ea.PrimaryInd = 1
         AND ea.ArchivedInd = 0
         AND ea.[HashedAddress] = @EncryptedEmail

      IF @@ROWCOUNT = 0
         BEGIN
           SET @ErrMsg = 'Unable to find CustomerID for Encrypted Email ('+@EncryptedEmail+')';
           THROW 51403, @ErrMsg,1
         END 
    END