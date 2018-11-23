
  CREATE PROCEDURE [api_shared].[getNewsletterIDs]
    --@SubscriptionTypeID int OUTPUT,
    --@ChannelTypeID int OUTPUT,
    @InformationSourceID int OUTPUT,
    @SubscriptionChannelTypeID int OUTPUT  
  AS
    BEGIN

    DECLARE @SubscriptionTypeID int
    DECLARE @ChannelTypeID int
    -- Assuming that all Newsletter actions are going to be requested from 'Website - Newsletter Signup'
      -- If in the future we've a second Subscription we can possible move these 3 varaibles and other related data
      -- into a table
      SET @SubscriptionTypeID  = 1 --'General Marketing Opt-In'
      SET @ChannelTypeID       = 1 --'Email'
      SET @InformationSourceID = 6 --'Website - Newsletter Signup'
    
      SELECT @SubscriptionChannelTypeID = sct.SubscriptionChannelTypeID
        FROM Reference.SubscriptionChannelType sct INNER JOIN Reference.SubscriptionType st
         ON sct.SubscriptionTypeID = st.SubscriptionTypeID INNER JOIN  Reference.ChannelType ct
         ON sct.ChannelTypeID = ct.ChannelTypeID
      WHERE st.SubscriptionTypeID = @SubscriptionTypeID
        AND ct.ChannelTypeID = @ChannelTypeID
        AND st.ArchivedInd = 0 
        AND ct.ArchivedInd = 0    
    END