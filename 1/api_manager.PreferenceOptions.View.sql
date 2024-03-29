USE [CEM]
GO
/****** Object:  View [api_manager].[PreferenceOptions]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

GO
