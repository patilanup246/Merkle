  CREATE PROCEDURE [api_preferences].[deletePreference]
   @userid       int,               -- Portal User ID that is requesting the action.
	 @preferenceID int = NULL OUTPUT
  ----------------------------------------

  AS 
    set nocount on;
    
    DECLARE @preferenceName    varchar(256)
    DECLARE @preferenceDesc    varchar(4000)
    DECLARE @allowmultipleind  bit        
    DECLARE @capturetimeind    bit
    DECLARE @defaultValue      bit
    DECLARE @displayName       varchar(256)
    DECLARE @displayDesc       varchar(2000)
    DECLARE @type              varchar(3)
    DECLARE @optinmandatoryind bit


    SELECT @preferenceName     = st.Name -- PreferenceName
          ,@preferenceDesc     = st.Description --PreferenceDescription
          ,@allowmultipleind   = st.AllowMultipleInd
          ,@capturetimeind     = st.CaptureTimeInd
          ,@defaultValue       = st.OptInDefault
          ,@displayName        = st.DisplayName
          ,@displayDesc        = st.DisplayDescription
          ,@type               = st.MessageTypeCd
          ,@optinmandatoryind  = st.OptInMandatoryInd
      FROM [Reference].[SubscriptionType] st
     WHERE SubscriptionTypeID = @preferenceID
       AND ArchivedInd = 0

  EXECUTE [Reference].[SubscriptionType_Set] 
     @userid
    
    ,@preferenceName
    ,@preferenceDesc

    , 1  -- @ArchivedInd

    ,@allowmultipleind 
    ,@capturetimeind 

    ,@defaultValue
    ,@displayName
    ,@displayDesc
    ,@type 
    ,@optinmandatoryind 
    ,@preferenceID OUTPUT

	IF (@preferenceID IS NOT NULL ) 
    RETURN 1
  ELSE
    RETURN 0