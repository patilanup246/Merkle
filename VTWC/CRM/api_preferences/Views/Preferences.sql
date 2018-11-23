  create view [api_preferences].[Preferences] as
     SELECT st.SubscriptionTypeID as PreferenceID
           ,st.Name -- PreferenceName
           ,st.Description --PreferenceDescription
           ,st.AllowMultipleInd
           ,st.CaptureTimeInd
           ,st.OptInDefault
           ,st.DisplayName
           ,st.DisplayDescription
           ,st.MessageTypeCd
           ,st.OptInMandatoryInd
           ,st.ArchivedInd as isVisible
      FROM [Reference].[SubscriptionType] st