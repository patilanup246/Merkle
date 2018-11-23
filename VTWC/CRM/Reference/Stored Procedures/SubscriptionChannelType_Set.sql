

CREATE PROCEDURE [Reference].[SubscriptionChannelType_Set]
(
	@userid                  INTEGER       = 0,
    @subscriptiontypeid      INTEGER       = NULL,
	@channeltypeid           INTEGER       = NULL,
	@subscriptiontypename    NVARCHAR(256) = NULL,
	@channeltypename         NVARCHAR(256) = NULL,
	@archivedind             BIT           = 0,
	@returnid                INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER
	DECLARE @logmessage          NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	IF @subscriptiontypeid IS NULL
	BEGIN
	    SELECT @subscriptiontypeid = SubscriptionTypeID
		FROM   [Reference].[SubscriptionType]
		WHERE  Name = @subscriptiontypename
	END

	IF @channeltypeid IS NULL
	BEGIN
	    SELECT @channeltypeid = ChannelTypeID
		FROM   [Reference].[ChannelType]
		WHERE  Name = @channeltypename
	END

    IF (@subscriptiontypeid IS NULL) OR (@channeltypeid IS NULL)
	BEGIN
		SET @logmessage = 'No or invalid reference values.' +  
		                  ' @subscriptiontypeid = '    + ISNULL(@subscriptiontypeid,'NULL') +
						  ', @subscriptiontypename = ' + ISNULL(@subscriptiontypename,'NULL') +
						  ', @channeltypeid = '        + ISNULL(@channeltypeid,'NULL') +
						  ', @channeltypename = '      + ISNULL(@channeltypename,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        SET @returnid  = -1
		RETURN
	END


    IF EXISTS (SELECT 1
               FROM [Reference].[SubscriptionChannelType]
		       WHERE SubscriptionTypeID = @subscriptiontypeid
		       AND   ChannelTypeID = @channeltypeid)
    BEGIN
        UPDATE [Reference].[SubscriptionChannelType]
        SET [LastModifiedDate]   = GETDATE()
           ,[LastModifiedBy]     = @userid
           ,[ArchivedInd]        = @archivedind
        WHERE SubscriptionTypeID = @subscriptiontypeid
		AND   ChannelTypeID = @channeltypeid
	END 
    ELSE
    BEGIN
        INSERT INTO [Reference].[SubscriptionChannelType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SubscriptionTypeID]
           ,[ChannelTypeID])
        VALUES
           (NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,@archivedind
           ,@subscriptiontypeid
           ,@channeltypeid)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = SubscriptionChannelTypeID
	FROM   [Reference].[SubscriptionChannelType]
	WHERE  SubscriptionTypeID = @subscriptiontypeid
	AND    ChannelTypeID = @channeltypeid

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END