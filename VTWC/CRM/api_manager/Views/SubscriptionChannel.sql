
CREATE VIEW [api_manager].[SubscriptionChannel] AS
SELECT st.DisplayName AS TypeID,
       ct.Name
FROM Reference.SubscriptionType st
INNER JOIN Reference.SubscriptionChannelType sct ON st.SubscriptionTypeID = sct.SubscriptionTypeID
INNER JOIN Reference.ChannelType ct ON sct.ChannelTypeID = ct.ChannelTypeID
WHERE
	   LEN(st.MessageTypeCd) <= 3