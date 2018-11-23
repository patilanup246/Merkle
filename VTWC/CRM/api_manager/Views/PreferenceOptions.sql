CREATE VIEW [api_manager].[PreferenceOptions] AS
    SELECT 
			p.PreferenceID,
			po.OptionID,
			po.OptionName,
			po.DefaultValue
		 
	FROM		Staging.STG_Preference p WITH (NOLOCK)
	INNER JOIN	Staging.STG_PreferenceOptions po WITH (NOLOCK) ON p.PreferenceID = po.PreferenceID

	WHERE	p.ArchivedInd = 0
	  AND	po.ArchivedInd = 0