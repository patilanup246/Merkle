USE [CEM]
GO
/****** Object:  View [api_shared].[ContactEmail]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
  CREATE VIEW [api_shared].[ContactEmail] AS
    SELECT ea.CustomerID       AS CustomerID,
		   ea.IndividualID	   AS IndividualID,
           ea.Address    AS ContactEmail,
           ea.EncrytpedAddress AS EncryptedEmail

		FROM Staging.STG_ElectronicAddress ea


GO
