﻿CREATE VIEW [CRM].[vw_Contact_History_Live]

as 

SELECT  
  CustomerID,
  IndividualID,
  HouseholdID,
  EmailAddress,
  TreatmentInstID,
  CellID,
  PackageID,
  ContactDateTime,
  UpdateDateTime,
  ContactStatusID,
  DateID,
  TimeID,
  CellName,
  CellCode,
  ControlCell,
  CampaignCode,
  TreatmentCode,
  OfferCode,
  Channel,
  Customer_Life_Stage,
  Customer_Segment,
  Model_Name,
  Model_Score,
  Model_nTile,
  AdHoc_Key_1,
  AdHoc_Value_1,
  AdHoc_Key_2,
  AdHoc_Value_2,
  AdHoc_Key_3,
  AdHoc_Value_3,
  AdHoc_Key_4,
  AdHoc_Value_4,
  AdHoc_Key_5,
  AdHoc_Value_5,
  AdHoc_Key_6,
  AdHoc_Value_6,
  AdHoc_Key_7,
  AdHoc_Value_7,
  AdHoc_Key_8,
  AdHoc_Value_8,
  AdHoc_Key_9,
  AdHoc_Value_9,
  AdHoc_Key_10,
  AdHoc_Value_10,
  IsDeleted,
  CH_source 
  
  from  [$(IBM_System)].[dbo].[vw_ContactHistory_live]
