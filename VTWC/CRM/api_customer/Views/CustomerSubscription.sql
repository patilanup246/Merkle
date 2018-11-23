
CREATE VIEW [api_customer].[CustomerSubscription] (subscriptionID, CBECustomerID, EncryptedEmail,TypeID) AS
   SELECT 1, * FROM
   (
     SELECT DISTINCT km.TCSCustomerID AS TCSCustomerID, ea.[HashedAddress] AS EncryptedEmail, st.[MessageTypeCd] AS TypeID
     --currently we do not differentiate between channel types, just an existing subscription for any channel
     -- therefore only distinc records to be selected

     FROM [Staging].[STG_CustomerSubscriptionPreference] cs WITH (NOLOCK)
       INNER JOIN [Reference].[SubscriptionChannelType] sct WITH (NOLOCK)
           ON cs.[SubscriptionChannelTypeID] = sct.[SubscriptionChannelTypeID]
       INNER JOIN [Reference].[SubscriptionType] st WITH (NOLOCK)
           ON sct.[SubscriptionTypeID] = st.[SubscriptionTypeID]
       INNER JOIN [Staging].[STG_ElectronicAddress] ea WITH (NOLOCK)
           ON ea.[CustomerID] = cs.[CustomerID]
       LEFT JOIN Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.CustomerID = km.CustomerID
     --remove all archived = "hidden" records
     WHERE cs.ArchivedInd = 0
       AND sct.ArchivedInd = 0
       AND st.ArchivedInd = 0
       AND ea.ArchivedInd = 0
     --get only the most current email address types
       AND ea.PrimaryInd = 1
       AND ea.AddressTypeID = 3
       AND ea.ParsedInd = 1
     --only customers who have opted indexes
       AND [OptInInd] = 1
     AND LEN(st.MessageTypeCd) <= 3
       UNION ALL
      SELECT DISTINCT km.TCSCustomerID AS TCSCustomerID, ea.[HashedAddress] AS EncryptedEmail, st.[MessageTypeCd] AS TypeID
    
       FROM [Staging].[STG_IndividualSubscriptionPreference] cs WITH (NOLOCK)
       INNER JOIN [Reference].[SubscriptionChannelType] sct WITH (NOLOCK)
           ON cs.[SubscriptionChannelTypeID] = sct.[SubscriptionChannelTypeID]
       INNER JOIN [Reference].[SubscriptionType] st WITH (NOLOCK)
           ON sct.[SubscriptionTypeID] = st.[SubscriptionTypeID]
       INNER JOIN [Staging].[STG_ElectronicAddress] ea WITH (NOLOCK)
           ON ea.[IndividualID] = cs.[IndividualID]
       LEFT JOIN Staging.STG_KeyMapping AS km WITH (NOLOCK) ON ea.IndividualID = km.IndividualID
     --remove all archived = "hidden" records
     WHERE cs.ArchivedInd = 0
       AND sct.ArchivedInd = 0
       AND st.ArchivedInd = 0
       AND ea.ArchivedInd = 0
     --get only the most current email address types
       AND ea.PrimaryInd = 1
       AND ea.AddressTypeID = 3
       --AND ea.ParsedInd = 1
     --only customers who have opted indexes
       AND [OptInInd] = 1
     AND LEN(st.MessageTypeCd) <= 3
  )  AS x