
CREATE VIEW [Reference].[ChannelSubscriptionType] AS
SELECT a.Name As SubscriptionType
      ,b.Name AS ChannelType
	  ,a.SubscriptionTypeID
	  ,b.ChannelTypeID
	  ,c.SubscriptionChannelTypeID
FROM Reference.SubscriptionType a,
     Reference.ChannelType b,
	 Reference.SubscriptionChannelType c
WHERE a.SubscriptionTypeID = c.SubscriptionTypeID
AND   b.ChannelTypeID = c.ChannelTypeID