USE [CEM]
GO
/****** Object:  View [api_customer].[PreProcessing_CVICustomerResponses]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE VIEW [api_customer].[PreProcessing_CVICustomerResponses]
	AS

	SELECT	NULL as CustomerID,
			c.CBECustomerID,
			--c.EncryptedEmail,
			cq.CVIQuestionID AS QuestionId,
			cg.displayName as groupName,
			cqa.CVIAnswerID AS AnswerID,
			ans.DisplayName AS AnswerName, 
			COALESCE (crc.Response,(CASE WHEN dt.SimpleType = 'Boolean' THEN 'false' ELSE '' END)) AS Response, 
			dt.SimpleType AS ResponseSimpleType
						 
	FROM	((SELECT DISTINCT CBECustomerID FROM [PreProcessing].[API_CustomerRegistration])
			UNION
			(SELECT DISTINCT CBECustomerID FROM [Staging].[STG_KeyMapping] WHERE CBECustomerID IS NOT NULL)) AS c
			CROSS JOIN
			Reference.CVIQuestion AS cq LEFT JOIN
			Reference.CVIQuestionGroup AS d ON cq.CVIQuestionID = d.CVIQuestionID LEFT JOIN
			Reference.CVIGroup AS cg ON d.CVIGroupID = cg.CVIGroupID LEFT JOIN 
			Reference.DataType AS dt ON cq.ResponseTypeID = dt.DataTypeID RIGHT OUTER JOIN
			Reference.CVIQuestionAnswer cqa ON cq.CVIQuestionID = cqa.CVIQuestionID INNER JOIN
			Reference.CVIAnswer ans ON ans.CVIAnswerID = cqa.CVIAnswerID LEFT JOIN
			[PreProcessing].[API_CVIResponseCustomer] AS crc
				ON	c.CBECustomerID = crc.CBECustomerID
				AND cqa.CVIQuestionAnswerID = crc.CVIQuestionAnswerID
				AND d.CVIQuestionGroupID = crc.CVIQuestionGroupID

	WHERE 	c.CBECustomerID IS NOT NULL
	  AND	cq.ArchivedInd = 0
	  AND	d.ArchivedInd = 0
	  AND	cq.ArchivedInd = 0
	  



GO
