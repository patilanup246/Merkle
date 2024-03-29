USE [CEM]
GO
/****** Object:  View [api_manager].[Preference]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [api_manager].[Preference] AS
    SELECT p.PreferenceID,
         p.PreferenceName,       
         dt.Name dataType,
         CASE p.ArchivedInd WHEN 0 THEN 1 ELSE 0 END AS Visibility
		 
		 FROM Staging.STG_Preference p WITH (NOLOCK)
		 INNER JOIN Reference.DataType dt WITH (NOLOCK) ON dt.DataTypeID = p.PreferenceDataTypeID

		 WHERE p.ArchivedInd = 0

GO
