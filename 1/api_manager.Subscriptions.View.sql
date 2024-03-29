USE [CEM]
GO
/****** Object:  View [api_manager].[Subscriptions]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

GO
