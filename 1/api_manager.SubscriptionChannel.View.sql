USE [CEM]
GO
/****** Object:  View [api_manager].[SubscriptionChannel]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [api_manager].[SubscriptionChannel] AS
SELECT st.DisplayName AS TypeID,
       ct.Name
FROM Reference.SubscriptionType st
INNER JOIN Reference.SubscriptionChannelType sct ON st.SubscriptionTypeID = sct.SubscriptionTypeID
INNER JOIN Reference.ChannelType ct ON sct.ChannelTypeID = ct.ChannelTypeID
WHERE
	   LEN(st.MessageTypeCd) <= 3

GO
