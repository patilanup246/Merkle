  CREATE VIEW [api_shared].[ContactEmail] AS
    SELECT ea.CustomerID       AS CustomerID,
		   ea.IndividualID	   AS IndividualID,
           ea.Address    AS ContactEmail,
           ea.[HashedAddress] AS EncryptedEmail

		FROM Staging.STG_ElectronicAddress ea