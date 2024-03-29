USE [CEM]
GO
/****** Object:  View [api_customer].[CVICustomerResponses]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 * Created by: david.marin@cometgc.com
 * Created on: 20/10/2016
 * 
 * Modification history:
 * 21/10/2016	tomas.kostan@cometgc.com
		Fixed select and join conditions, added a valid statement to get customer responses or default values if not provided, applied 
		standard table exclusions for the staging schema to remove duplicates and polished code structure.
 *
 * Description:
 * Displays metadata for CVI Customer Responses.
 *
 */
 

CREATE VIEW [api_customer].[CVICustomerResponses]
AS

SELECT c.CustomerID, km.CBECustomerID AS CBECustomerID, ea.EncrytpedAddress AS EncryptedEmail, cq.CVIQuestionID AS QuestionId, cg.DisplayName AS groupName, cqa.CVIAnswerID AS AnswerId, 
       ans.DisplayName AS AnswerName, 
	   COALESCE (crc.Response, (CASE WHEN dt.SimpleType = 'Boolean' THEN 'false' ELSE CASE WHEN dt.Name = 'REASON_FOR_TRAVEL' AND ans.DisplayName <> 'Customer Booking Reference' THEN 'false' ELSE '' END END)) AS Response, 
	   CASE WHEN dt.Name = 'REASON_FOR_TRAVEL' AND ans.DisplayName <> 'Customer Booking Reference' THEN 'Boolean' ELSE dt.SimpleType END AS ResponseSimpleType
FROM   Staging.STG_Customer AS c WITH (NOLOCK) CROSS JOIN
	   Reference.CVIQuestionGroup AS cqg WITH (NOLOCK) INNER JOIN
	   Reference.CVIQuestion AS cq WITH (NOLOCK) ON cq.CVIQuestionID = cqg.CVIQuestionID LEFT OUTER JOIN
	   Staging.STG_ElectronicAddress AS ea WITH (NOLOCK) ON c.CustomerID = ea.CustomerID LEFT OUTER JOIN
	   Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.CustomerID = km.CustomerID INNER JOIN
	   Reference.CVIGroup AS cg WITH (NOLOCK) ON cg.CVIGroupID = cqg.CVIGroupID INNER JOIN
	   Reference.DataType AS dt WITH (NOLOCK) ON cq.ResponseTypeID = dt.DataTypeID LEFT OUTER JOIN
	   Reference.CVIQuestionAnswer AS cqa WITH (NOLOCK) ON cq.CVIQuestionID = cqa.CVIQuestionID INNER JOIN
	   Reference.CVIAnswer AS ans WITH (NOLOCK) ON ans.CVIAnswerID = cqa.CVIAnswerID LEFT OUTER JOIN
	   Staging.STG_CVIResponseCustomer AS crc WITH (NOLOCK) ON c.CustomerID = crc.CustomerID AND cqa.CVIQuestionAnswerID = crc.CVIQuestionAnswerID AND 
	   cqg.CVIQuestionGroupID = crc.CVIQuestionGroupID
WHERE  (ea.PrimaryInd = 1 OR ea.PrimaryInd IS NULL)
  AND (ea.ArchivedInd = 0 OR ea.ArchivedInd IS NULL)
  AND (ea.AddressTypeID = 3 OR ea.AddressTypeID IS NULL)
  AND (c.ArchivedInd = 0 OR c.ArchivedInd IS NULL)
  AND (cqg.ArchivedInd = 0 OR cqg.ArchivedInd IS NULL)
  AND (cq.ArchivedInd = 0 OR cq.ArchivedInd IS NULL)
  AND (cqa.ArchivedInd = 0 OR cqa.ArchivedInd IS NULL)
  AND (ans.ArchivedInd = 0 OR ans.ArchivedInd IS NULL)
  AND (crc.ArchivedInd = 0 OR crc.ArchivedInd IS NULL)
		




GO
