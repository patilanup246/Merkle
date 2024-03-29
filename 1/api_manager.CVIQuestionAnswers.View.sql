USE [CEM]
GO
/****** Object:  View [api_manager].[CVIQuestionAnswers]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [api_manager].[CVIQuestionAnswers] AS
		 
		SELECT 	cqn.CVIQuestionID AS questionID,
				cg.DisplayName AS questionType,
				ans.CVIAnswerID AS answerID,
				dt.SimpleType AS simpleType, -- programming data types - should only ever include the following: "Boolean", "String", "Datetime", "Integer".
				ans.DisplayName AS displayValue,
				CASE 
					WHEN dt.SimpleType = 'Boolean' THEN 'false' ELSE '' END AS defaultValue
					--default values hardcoded for now as we do not allow users to specify this, these should be moved to Reference.DataType
		 
		 FROM 	[Reference].[CVIQuestionAnswer] qa WITH (NOLOCK) INNER JOIN
				[Reference].[CVIAnswer] ans WITH (NOLOCK) ON ans.CVIAnswerID = qa.CVIAnswerID INNER JOIN
				[Reference].[CVIQuestion] cqn WITH (NOLOCK) ON cqn.CVIQuestionID = qa.CVIQuestionID INNER JOIN		
				[Reference].[DataType] dt WITH (NOLOCK) ON cqn.ResponseTypeId = dt.DataTypeId INNER JOIN
				[Reference].[CVIQuestionGroup] qg WITH (NOLOCK) ON cqn.CVIQuestionID = qg.CVIQuestionID INNER JOIN
				[Reference].[CVIGroup] cg WITH (NOLOCK) ON cg.CVIGroupID = qg.CVIGroupID

		WHERE	cqn.ArchivedInd = 0
		  AND	cg.ArchivedInd = 0
		 

GO
