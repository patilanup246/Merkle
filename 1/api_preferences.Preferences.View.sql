USE [CEM]
GO
/****** Object:  View [api_preferences].[Preferences]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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


GO
