
  CREATE PROCEDURE [api_shared].[getIndividualID]
    @EncryptedEmail VARCHAR(256),
    @IndividualID int OUTPUT  
  AS
    BEGIN

      DECLARE @ErrMsg VARCHAR(MAX)

      SELECT @IndividualID = ea.IndividualID
        FROM Staging.STG_ElectronicAddress ea
       WHERE ea.AddressTypeID = 3
         AND ea.PrimaryInd = 1
         and ea.ArchivedInd = 0
         AND ea.[HashedAddress] = @EncryptedEmail

      IF @@ROWCOUNT = 0
         BEGIN
           SET @ErrMsg = 'Unable to find IndividualID for Encrypted Email ('+@EncryptedEmail+')';
           THROW 51403, @ErrMsg,1
         END 
    END