USE [CEM]
GO
/****** Object:  View [api_preferences].[PreferenceType]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE VIEW [api_preferences].[PreferenceType] AS 
     SELECT distinct st.Name dataType
       FROM Reference.SubscriptionType st;

GO
