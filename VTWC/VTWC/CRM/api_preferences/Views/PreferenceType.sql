  CREATE VIEW [api_preferences].[PreferenceType] AS 
     SELECT distinct st.Name dataType
       FROM Reference.SubscriptionType st;