USE [CEM]
GO
/****** Object:  StoredProcedure [api_shared].[getIndividualID]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

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
         AND ea.EncrytpedAddress = @EncryptedEmail

      IF @@ROWCOUNT = 0
         BEGIN
           SET @ErrMsg = 'Unable to find IndividualID for Encrypted Email ('+@EncryptedEmail+')';
           THROW 51403, @ErrMsg,1
         END 
    END 


GO
