USE [CEM]
GO
/****** Object:  View [api_customer].[Alerts]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [api_customer].[Alerts] AS 
 SELECT DISTINCT
        --km.MSDID		   as CBECustomerID,
        ca.EncryptedEmail  as EncryptedEmail, 
        ca.CustomerAlertID as AlertID,
        ca.Title           as Title,
        ca.Forename        as Forename,
        ca.Surname         as Surname,
        ca.Email           as Email,
        ca.LocationFrom    as StationFrom,
        ca.LocationTo      as StationTo,
        ca.AlertName       as AlertName,
        ca.DurationStartDate as DurationStartDate,
        ca.DurationEndDate as DurationEndDate,
        ca.OutwardJourney  as OutwardJourney,
        ca.ReturnJourney   as ReturnJourney,
        CAST(0 AS BIT)     as createdAnonymously
   FROM Staging.STG_CustomerAlert ca 
  WHERE ca.ArchivedInd = 0

GO
