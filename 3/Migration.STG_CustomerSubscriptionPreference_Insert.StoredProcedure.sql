USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_CustomerSubscriptionPreference_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_CustomerSubscriptionPreference_Insert]
(
    @userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid          INTEGER
    DECLARE @subscriptionchanneltypeid    INTEGER
	DECLARE @defaultoptinleisure          INTEGER
	DECLARE @defaultoptincorporate        INTEGER	 

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    --Get Reference Information

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Legacy - Zeta'

	SELECT @defaultoptinleisure = SubscriptionTypeID
	FROM   [Reference].[SubscriptionType]
	WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Leisure Subscription Type')

	SELECT @defaultoptincorporate = SubscriptionTypeID
	FROM   [Reference].[SubscriptionType]
	WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Corporate Subscription Type')

	IF (@informationsourceid IS NULL) OR (@defaultoptinleisure IS NULL) OR (@defaultoptincorporate IS NULL)
	BEGIN
	    SET @logmessage = 'No or invalid reference data; ' +
		                  ' @informationsourceid = '   + ISNULL(@informationsourceid,'NULL') + 
						  ' @defaultoptinleisure = '   + ISNULL(@defaultoptinleisure,'NULL') + 
						  ' @defaultoptincorporate = ' + ISNULL(@defaultoptincorporate,'NULL') 
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

--Leisure

	SELECT @subscriptionchanneltypeid = SubscriptionChannelTypeID
	FROM   Reference.SubscriptionChannelType a,
	       Reference.SubscriptionType b,
	 	   Reference.ChannelType c
	WHERE  a.SubscriptionTypeID = b.SubscriptionTypeID
	AND    a.ChannelTypeID = c.ChannelTypeID
	AND    b.SubscriptionTypeID = @defaultoptinleisure
	AND    c.Name = 'Email'

--Get data
    
    INSERT INTO [Staging].[STG_CustomerSubscriptionPreference]
           ([Name]
           ,[Description]
           ,[CreatedDate]
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
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,a.SourceModifiedDate
           ,a.CustomerID
           ,@subscriptionchanneltypeid
           ,c.Contactable
           ,NULL
           ,NULL
           ,NULL
           ,@informationsourceid
    FROM Staging.STG_Customer a,
	     Staging.STG_KeyMapping b,
		 Migration.Zeta_Customer c
	WHERE a.CustomerID = b.CustomerID
	AND   b.ZetaCustomerID = c.ZetaCustomerID

	SELECT @recordcount = @@ROWCOUNT

--Corporate

	SELECT @subscriptionchanneltypeid = SubscriptionChannelTypeID
	FROM   Reference.SubscriptionChannelType a,
	       Reference.SubscriptionType b,
	 	   Reference.ChannelType c
	WHERE  a.SubscriptionTypeID = b.SubscriptionTypeID
	AND    a.ChannelTypeID = c.ChannelTypeID
	AND    b.SubscriptionTypeID = @defaultoptincorporate
	AND    c.Name = 'Email'

--Get data
    
    INSERT INTO [Staging].[STG_CustomerSubscriptionPreference]
           ([Name]
           ,[Description]
           ,[CreatedDate]
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
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,a.SourceModifiedDate
           ,a.CustomerID
           ,@subscriptionchanneltypeid
           ,CASE Corp_OptOut WHEN 'true' THEN 0 ELSE 1 END
           ,NULL
           ,NULL
           ,NULL
           ,@informationsourceid
    FROM Staging.STG_Customer a,
	     Staging.STG_KeyMapping b,
		 Migration.Zeta_Customer c
	WHERE a.CustomerID = b.CustomerID
	AND   b.ZetaCustomerID = c.ZetaCustomerID
	AND   (c.IsCorp = 'True' OR c.IsTMC = 'True')

	SELECT @recordcount = @recordcount + @@ROWCOUNT


	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

	RETURN
END











GO
