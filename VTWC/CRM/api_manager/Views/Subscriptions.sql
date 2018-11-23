
CREATE VIEW [api_manager].[Subscriptions] AS
SELECT st.SubscriptionTypeID,
       st.MessageTypeCd AS TypeID,
       st.DisplayDescription AS external_name,
       CASE WHEN st.ArchivedInd = 1 THEN 0 ELSE 1 END AS visible,
       st.OptInMandatoryInd AS OptinMandatory,
       st.AllowMultipleInd AS AllowMultiple
FROM Reference.SubscriptionType st
where 
	   LEN(st.MessageTypeCd) <= 3