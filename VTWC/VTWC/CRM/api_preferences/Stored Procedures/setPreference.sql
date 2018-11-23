
  CREATE PROCEDURE [api_preferences].[setPreference] 
  -- Preference data ---------------------
     @userid       int,                      -- Portal User ID that is requesting the action.
     
     -- Internal information 
     @preferenceName varchar(256),           -- Internal Preference Name
     @preferenceDesc varchar(4000) = NULL,   -- Useful information about what is this preference going to manage
     
     -- External information that will be consumed by Web and Portal (possibly more channels)
	 @displayName varchar(256),              -- User friendly Prefernce text
	 @displayDesc varchar(2000) = NULL,      -- Descripiton to be displayed to the preference consumer
	 
	 -- Default behavior / values for that specific prefence
     @defaultValue bit = 1,                  -- Default value
     @type         varchar(3) = 'Marketing', 
     
     -- Outputs
	 @preferenceID int = NULL OUTPUT         -- PreferenceID for the new preference
  ----------------------------------------

  AS 
    set nocount on;

	/* [Reference].[SubscriptionType_Set] unmapped parameters description:

		   @allowmultipleind  : This is to allow for a contact to have multiple current subscriptions for the same type.
							    Example being I want to subscribe to train delays between 7am to 9am Monday, Wednesday and Friday

	       @capturetimeind    : Linked to the above. This caters for subscriptions where time could be component and needs to be captured.
	       @optinmandatoryind : Flag to indicate that the Customer or Individual cannot opt out of the Subscription type. 
	                            If true, then the Customer/Individual can decide on the channel to be receive the information and they must 
	                            select at least one Channel Type
	       @ArchivedInd       : It means Archived Indicator and flag if the row is available or not (logical delete)
    */
	DECLARE @allowmultipleind bit        = 1
	DECLARE @capturetimeind bit          = 0
	DECLARE @optinmandatoryind bit       = 0 
	DECLARE @ArchivedInd bit             = 0
	DECLARE @returnid int

	DECLARE @ErrMsg VARCHAR(250)

	EXECUTE [Reference].[SubscriptionType_Set] 
	   @userid
	  
	  ,@preferenceName
	  ,@preferenceDesc

	  ,@ArchivedInd

	  ,@allowmultipleind 
	  ,@capturetimeind 

	  ,@defaultValue
	  ,@displayName
	  ,@displayDesc
	  ,@type 
	  ,@optinmandatoryind 
	  ,@preferenceID OUTPUT

	SELECT @returnid = COUNT(1) 
	  FROM [Reference].[SubscriptionType]
	 WHERE SubscriptionTypeid = @preferenceID

	RETURN @returnid;