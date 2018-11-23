USE [CRM]
GO
/****** Object:  StoredProcedure [Staging].[STG_CustomerPreference_Update]    Script Date: 31/07/2018 11:25:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Staging].[STG_CustomerPreference_Update]
(
	@userid                       INTEGER       = 0,   
	@customerid                   INTEGER,
	@subscriptionchanneltypeid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @channeltype               NVARCHAR(256)
	DECLARE @optoutchanneltype         NVARCHAR(256) = 'Opt out from all channels'
    DECLARE @currentpreferencevalue    INTEGER
    DECLARE @newpreferencevalue        INTEGER
    DECLARE @otherpreferencevalue      INTEGER

	DECLARE @spname                        NVARCHAR(256)
	DECLARE @logtimingidnew                INTEGER
	DECLARE @logmessage                    NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    SET @logmessage = '@userid = '                       +  ISNULL(CAST(@userid AS NVARCHAR(256)),'NULL') +
					  ', @customerid = '                 +  ISNULL(CAST(@customerid AS NVARCHAR(256)),'NULL') +
					  ', @subscriptionchanneltypeid = '  +  ISNULL(CAST(@subscriptionchanneltypeid AS NVARCHAR(256)),'NULL')
	    
    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                  @logsource       = @spname,
									      @logmessage      = @logmessage,
										  @logmessagelevel = 'DEBUG',
									      @messagetypecd   = NULL

    --Get channel for the supplied subscription
    
    SELECT @channeltype = ChannelType
    FROM   Reference.ChannelSubscriptionType
    WHERE  SubscriptionChannelTypeID = @subscriptionchanneltypeid

	--Get the latest channel preference based on latest subscription change

	SELECT @newpreferencevalue = CASE WHEN SUM(CAST(a.OptInInd AS INTEGER)) > 0 THEN 1 ELSE 0 END
    FROM   Staging.STG_CustomerSubscriptionPreference a WITH (NOLOCK)
    INNER JOIN Reference.ChannelSubscriptionType b ON b.SubscriptionChannelTypeID = a.SubscriptionChannelTypeID
    WHERE  a.CustomerID = @customerid
	AND    b.ChannelType = @channeltype
	AND    a.ArchivedInd = 0
   
    --Get the current channel preference

    SELECT @currentpreferencevalue = a.PreferenceValue
    FROM  Staging.STG_CustomerPreference a WITH (NOLOCK)
    INNER JOIN Staging.STG_PreferenceOptions b ON a.OptionID = b.OptionID
    WHERE a.CustomerID = @customerid
    AND   b.OptionName = @channeltype
    AND   a.ArchivedInd = 0

	IF @currentpreferencevalue = @newpreferencevalue
	BEGIN
	    --if same then no change required
	    RETURN
    END

	UPDATE a
	SET LastModifiedDate = GETDATE()
	   ,LastModifiedBy   = @userid
	   ,ArchivedInd      = 1
	FROM Staging.STG_CustomerPreference a
	INNER JOIN Staging.STG_PreferenceOptions b ON a.OptionID = b.OptionID
    WHERE a.CustomerID = @customerid
    AND   b.OptionName = @channeltype
    AND   a.ArchivedInd = 0

	INSERT INTO Staging.STG_CustomerPreference
	      (CustomerID
		  ,OptionID
		  ,PreferenceValue
		  ,CreatedDate
		  ,CreatedBy
		  ,LastModifiedDate
		  ,LastModifiedBy
		  ,ArchivedInd)
    SELECT @CustomerId
		  ,OptionID  
		  ,@newpreferencevalue
	      ,GETDATE()
		  ,@userid
		  ,GETDATE()
		  ,@userid
		  ,0
    FROM Staging.STG_PreferenceOptions
	WHERE OptionName = @channeltype

	--Is new preference 0, if so need to compare with other channel

	IF @newpreferencevalue = 0
	BEGIN
	    SELECT @otherpreferencevalue = a.PreferenceValue
	    FROM   Staging.STG_CustomerPreference a WITH (NOLOCK)
	    INNER JOIN Staging.STG_PreferenceOptions b ON a.OptionID = b.OptionID
        WHERE a.CustomerID = @customerid
        AND   b.OptionName != @channeltype
	    AND   b.OptionName != @optoutchanneltype
        AND   a.ArchivedInd = 0

	    IF @newpreferencevalue != @otherpreferencevalue
	    BEGIN
	        --Different so no other changes required
		
		    RETURN
        END

		--Both opted out, so need to set all opt out value to true

		UPDATE a
	    SET LastModifiedDate = GETDATE()
	       ,LastModifiedBy   = @userid
	       ,ArchivedInd      = 1
	    FROM Staging.STG_CustomerPreference a
	    INNER JOIN Staging.STG_PreferenceOptions b ON a.OptionID = b.OptionID
        WHERE a.CustomerID = @customerid
        AND   b.OptionName = @optoutchanneltype
        AND   a.ArchivedInd = 0

        INSERT INTO Staging.STG_CustomerPreference
	          (CustomerID
		      ,OptionID
		      ,PreferenceValue
	    	  ,CreatedDate
    		  ,CreatedBy
		      ,LastModifiedDate
		      ,LastModifiedBy
		      ,ArchivedInd)
        SELECT @CustomerId
		      ,OptionID  
		      ,1
	          ,GETDATE()
		      ,@userid
		      ,GETDATE()
		      ,@userid
		      ,0
        FROM Staging.STG_PreferenceOptions
	    WHERE OptionName = @optoutchanneltype
    END
  
    --If opting in, need make sure optall all is not set

	SELECT @newpreferencevalue

	IF @newpreferencevalue = 1
	BEGIN
	    IF EXISTS (SELECT 1
		           FROM Staging.STG_CustomerPreference a
				   INNER JOIN Staging.STG_PreferenceOptions b ON b.OptionID = a.OptionID
				   WHERE b.OptionName = @optoutchanneltype
				   AND   a.PreferenceValue = 1
				   AND   a.ArchivedInd = 0)
        BEGIN
		    UPDATE a
	        SET LastModifiedDate = GETDATE()
	           ,LastModifiedBy   = @userid
	           ,ArchivedInd      = 1
	        FROM Staging.STG_CustomerPreference a
	        INNER JOIN Staging.STG_PreferenceOptions b ON a.OptionID = b.OptionID
            WHERE a.CustomerID = @customerid
            AND   b.OptionName = @optoutchanneltype
            AND   a.ArchivedInd = 0

            INSERT INTO Staging.STG_CustomerPreference
	              (CustomerID
		          ,OptionID
		          ,PreferenceValue
	    	      ,CreatedDate
    		      ,CreatedBy
		          ,LastModifiedDate
		          ,LastModifiedBy
		          ,ArchivedInd)
            SELECT @CustomerId
		          ,OptionID  
		          ,0
	              ,GETDATE()
		          ,@userid
		          ,GETDATE()
		          ,@userid
		          ,0
            FROM Staging.STG_PreferenceOptions
	        WHERE OptionName = @optoutchanneltype
        END
    END

	RETURN 
END




