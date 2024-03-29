USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_IndividualSubscriptionPreference_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_IndividualSubscriptionPreference_Insert]
(
    @userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	/**********************************************************************************
	**  Date: 10-08-2016                                                             **
	**                                                                               **
	**  Amendment to support processing of additionl Zeta Prospects:                 **
	**  1. Prevent same ZetaCustomerID being process                                 **
	**  2. To reference field Migration.Zeta_Prospect.FinalMigrateInd rather than    **
	**     Migration.Zeta_Prospect.MigrateInd used to first migration                **
	**                                                                               **
	**********************************************************************************/

	DECLARE @informationsourceid          INTEGER
    DECLARE @subscriptionchanneltypeid    INTEGER
	DECLARE @defaultoptinleisure          INTEGER

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

	IF (@informationsourceid IS NULL) OR (@defaultoptinleisure IS NULL)
	BEGIN
	    SET @logmessage = 'No or invalid reference data; ' +
		                  ' @informationsourceid = '   + ISNULL(@informationsourceid,'NULL') + 
						  ' @defaultoptinleisure = '   + ISNULL(@defaultoptinleisure,'NULL') 
	    
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
    
    INSERT INTO [Staging].[STG_IndividualSubscriptionPreference]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[SourceChangeDate]
           ,[IndividualID]
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
		   ,a.CreatedDate
           ,a.IndividualID
           ,@subscriptionchanneltypeid
           ,c.Contactable
           ,NULL
           ,NULL
           ,NULL
           ,@informationsourceid
    FROM Staging.STG_Individual a
	INNER JOIN Staging.STG_KeyMapping b ON a.IndividualID = b.IndividualID
	INNER JOIN Migration.Zeta_Prospect c ON b.ZetaCustomerID = c.ZetaCustomerID
	LEFT JOIN  Staging.STG_IndividualSubscriptionPreference d ON a.IndividualID = d.IndividualID 
	WHERE d.IndividualID IS NULL
	AND   c.FinalMigrateInd = 1
	AND   a.ArchivedInd = 0

	SELECT @recordcount = @@ROWCOUNT

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

	RETURN
END













GO
