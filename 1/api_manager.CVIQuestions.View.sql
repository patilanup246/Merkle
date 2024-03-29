USE [CEM]
GO
/****** Object:  View [api_manager].[CVIQuestions]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [api_manager].[CVIQuestions] AS
  SELECT cqn.CVIQuestionID AS questionID,
       cg.DisplayName AS questionType,
       --CVI question group type
       (CASE cqn.ArchivedInd
        WHEN 0 THEN 1
        ELSE 0
      END) AS visible,
       /* Based on the design provided by steve.riley@cometgc.com this is the only column that can be treated as a visibility flag.*/
       dt.Name AS dataType,
       -- can be SINGLE_CHOICE, MULTI_CHOICE, CRS_CODE, etc.
       --dt.SimpleType AS simpleType, -- the above translated into programming data types i.e. Boolean, String, etc.
       cqn.DisplayName AS displayValue
    FROM [Reference].[CVIQuestionGroup] qg WITH (NOLOCK)
       INNER JOIN [Reference].[CVIGroup] cg WITH (NOLOCK) ON cg.CVIGroupID = qg.CVIGroupID
       INNER JOIN [Reference].[CVIQuestion] cqn WITH (NOLOCK) ON cqn.CVIQuestionID = qg.CVIQuestionID
       INNER JOIN [Reference].[DataType] dt WITH (NOLOCK) ON cqn.ResponseTypeId = dt.DataTypeId
   WHERE cg.ArchivedInd = 0
GO
