CREATE PROCEDURE [Staging].[STG_CustomerSubscriptionPreference_Update]
(
	@userid                       INTEGER       = 0,   
	@informationsourceid          INTEGER,
	@customerid                   INTEGER,
	@sourcechangedate             DATETIME,
	@archivedind                  BIT           = 0,
	@subscriptionchanneltypeid    INTEGER,
	@optinind                     BIT,
	@starttime                    DATETIME      = NULL,
	@endtime                      DATETIME      = NULL,
	@daysofweek                   NVARCHAR(16)  = NULL,
	@recordcount                  INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname                        NVARCHAR(256)
	DECLARE @logtimingidnew                INTEGER
	DECLARE @logmessage                    NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    SET @logmessage = '@userid = '                       +  ISNULL(CAST(@userid AS NVARCHAR(256)),'NULL') +
	                  ', @informationsourceid = '        +  ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
					  ', @customerid = '                 +  ISNULL(CAST(@customerid AS NVARCHAR(256)),'NULL') +
					  ', @sourcechangedate = '           +  ISNULL(CAST(@sourcechangedate AS NVARCHAR(256)),'NULL') +
					  ', @archivedind = '                +  ISNULL(CAST(@archivedind AS NVARCHAR(256)),'NULL') +
					  ', @subscriptionchanneltypeid = '  +  ISNULL(CAST(@subscriptionchanneltypeid AS NVARCHAR(256)),'NULL') + 
					  ', @optinind = '                   +  ISNULL(CAST(@optinind AS NVARCHAR(256)),'NULL') + 
					  ', @starttime = '                  +  ISNULL(CAST(@starttime AS NVARCHAR(256)),'NULL') + 
					  ', @endtime = '                    +  ISNULL(CAST(@endtime AS NVARCHAR(256)),'NULL') + 
					  ', @daysofweek = '                 +  ISNULL(CAST(@daysofweek AS NVARCHAR(256)),'NULL')
	    
    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                  @logsource       = @spname,
									      @logmessage      = @logmessage,
										  @logmessagelevel = 'DEBUG',
									      @messagetypecd   = NULL

    --Is the new value same as previous? If yes, return

	IF EXISTS(SELECT 1
	          FROM [Staging].[STG_CustomerSubscriptionPreference]
			  WHERE CustomerID                = @customerid
	          AND   SubscriptionChannelTypeID = @subscriptionchanneltypeid
			  AND   ArchivedInd               = 0
			  AND   OptInInd                  = @optinind)
	BEGIN
	    SET @recordcount = 0

		RETURN
	END

    --Is this the lastest change? If not return

	IF EXISTS(SELECT 1
	          FROM [Staging].[STG_CustomerSubscriptionPreference]
			  WHERE CustomerID                = @customerid
	          AND   SubscriptionChannelTypeID = @subscriptionchanneltypeid
			  AND   ArchivedInd               = 0
			  AND   SourceChangeDate          >= @sourcechangedate)
	BEGIN
	    SET @recordcount = 0

		RETURN
	END

    --Change the current

    UPDATE [Staging].[STG_CustomerSubscriptionPreference]
	SET    ArchivedInd               = 1,
	       LastModifiedBy            = @userid,
		   LastModifiedDate          = GETDATE()
	WHERE  CustomerID                = @customerid
	AND    SubscriptionChannelTypeID = @subscriptionchanneltypeid

	--Add the new record

	INSERT INTO [Staging].[STG_CustomerSubscriptionPreference]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SourceChangeDate]
		   ,[CustomerID]
           ,[SubscriptionChannelTypeID]
           ,[OptInInd]
           ,[StartTime]
           ,[EndTime]
           ,[DaysofWeek]
           ,[InformationSourceID])
     VALUES
           (GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,@sourcechangedate
           ,@customerid
           ,@subscriptionchanneltypeid
           ,@optinind
           ,@starttime
           ,@endtime
           ,@daysofweek
           ,@informationsourceid)

    SELECT @recordcount = @@ROWCOUNT

    --For TCS Customers, now need to update STG_CustomerPreference for channel preferences shown on the web site

	IF EXISTS (SELECT 1
	           FROM Staging.STG_KeyMapping WITH (NOLOCK)
			   WHERE CustomerID = @customerid
			   AND   TCSCustomerID IS NOT NULL)
    BEGIN
	    EXEC [Staging].[STG_CustomerPreference_Update] @userid                    = @userid,   
	                                                   @customerid                = @customerid,
                                                       @subscriptionchanneltypeid = @subscriptionchanneltypeid
    END

	RETURN 
END