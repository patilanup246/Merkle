USE [CEM]
GO
/****** Object:  View [api_customer].[CVICustomerQuestions]    Script Date: 24/07/2018 14:20:08 ******/
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
		Fixed select statements and join conditions to get rid of inconsistent retrieval of customer CVI questions
 *
 * Description:
 * Displays metadata for CVI Customer Questions.
 *
 */

CREATE VIEW [api_customer].[CVICustomerQuestions]
AS
SELECT      c.CustomerID, km.CBECustomerID AS CBECustomerID, ea.EncrytpedAddress AS EncryptedEmail, cg.DisplayName AS GroupName, cg.CVIGroupID AS GroupId, cq.CVIQuestionID AS QuestionId, 
            cq.DisplayName AS QuestionName, (CASE cq.ArchivedInd WHEN 0 THEN 1 ELSE 1 END) AS Visible, dt.Name AS ResponseType
FROM        Staging.STG_Customer AS c WITH (NOLOCK) CROSS JOIN
            Reference.CVIQuestionGroup AS cqg WITH (NOLOCK) INNER JOIN
            Reference.CVIQuestion AS cq WITH (NOLOCK) ON cq.CVIQuestionID = cqg.CVIQuestionID LEFT OUTER JOIN
            Staging.STG_ElectronicAddress AS ea WITH (NOLOCK) ON c.CustomerID = ea.CustomerID LEFT OUTER JOIN
            Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.CustomerID = km.CustomerID INNER JOIN
            Reference.CVIGroup AS cg WITH (NOLOCK) ON cg.CVIGroupID = cqg.CVIGroupID INNER JOIN
            Reference.DataType AS dt WITH (NOLOCK) ON cq.ResponseTypeID = dt.DataTypeID
WHERE       (ea.PrimaryInd = 1 OR ea.PrimaryInd IS NULL)
  AND 		(ea.ArchivedInd = 0 OR ea.ArchivedInd IS NULL)
  AND 		(ea.AddressTypeID = 3 OR ea.AddressTypeID IS NULL)
  AND 		(c.ArchivedInd = 0)
  AND 		(cqg.ArchivedInd = 0)
  AND 		(cg.ArchivedInd = 0)
  AND 		(cq.ArchivedInd = 0)



GO
