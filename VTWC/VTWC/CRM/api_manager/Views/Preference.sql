CREATE VIEW [api_manager].[Preference] AS
    SELECT p.PreferenceID,
         p.PreferenceName,       
         dt.Name dataType,
         CASE p.ArchivedInd WHEN 0 THEN 1 ELSE 0 END AS Visibility
		 
		 FROM Staging.STG_Preference p WITH (NOLOCK)
		 INNER JOIN Reference.DataType dt WITH (NOLOCK) ON dt.DataTypeID = p.PreferenceDataTypeID

		 WHERE p.ArchivedInd = 0