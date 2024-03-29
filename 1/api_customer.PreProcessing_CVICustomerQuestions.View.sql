USE [CEM]
GO
/****** Object:  View [api_customer].[PreProcessing_CVICustomerQuestions]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



	CREATE VIEW [api_customer].[PreProcessing_CVICustomerQuestions]
	AS
	SELECT	DISTINCT
			NULL as CustomerID,
			c.CBECustomerID,
			--c.EncryptedEmail,	
			cg.DisplayName AS GroupName,
			cg.CVIGroupID AS GroupId,
			cq.CVIQuestionID AS QuestionId,
			cq.DisplayName as QuestionName,
			(CASE cq.ArchivedInd WHEN 0 THEN 1 ELSE 1 END) as Visible,
			dt.Name AS ResponseType
					 
	FROM	((SELECT DISTINCT CBECustomerID FROM [PreProcessing].[API_CustomerRegistration])
			UNION
			(SELECT DISTINCT CBECustomerID FROM [Staging].[STG_KeyMapping] WHERE CBECustomerID IS NOT NULL)) AS c
			CROSS JOIN
			Reference.CVIQuestionGroup AS d LEFT JOIN
			Reference.CVIQuestion AS cq ON cq.CVIQuestionID = d.CVIQuestionID LEFT JOIN
			Reference.CVIGroup AS cg ON d.CVIGroupID = cg.CVIGroupID LEFT JOIN 
			Reference.DataType AS dt ON cq.ResponseTypeID = dt.DataTypeID

	WHERE 	c.CBECustomerID IS NOT NULL
	  AND	cq.ArchivedInd = 0
	  AND	d.ArchivedInd = 0
	  AND	cq.ArchivedInd = 0



GO
