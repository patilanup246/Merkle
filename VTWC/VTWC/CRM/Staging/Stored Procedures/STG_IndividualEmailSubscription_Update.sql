
CREATE PROCEDURE [Staging].[STG_IndividualEmailSubscription_Update]
(
	@userid                       INTEGER       = 0,   
	@recordcount                  INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @defaultoptinleisure                  INTEGER
	DECLARE @subscriptionchanneltypeidleisure     INTEGER
	DECLARE @informationsourceid				  INTEGER --'IBM Silverpop - Email'
	DECLARE @individualid						  INTEGER
	DECLARE @eventstamp							  DATETIME
	DECLARE @optinind							  BIT
	DECLARE @records							  INTEGER = 0

	SELECT @defaultoptinleisure = SubscriptionTypeID
    FROM   [Reference].[SubscriptionType]
    WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Leisure Subscription Type')

    SELECT @informationsourceid = informationsourceid 
      FROM Reference.InformationSource 
     WHERE name = 'IBM Silverpop - Email'

	SELECT @subscriptionchanneltypeidleisure = SubscriptionChannelTypeID
	FROM   Reference.SubscriptionChannelType a,
	       Reference.SubscriptionType b,
	 	   Reference.ChannelType c
	WHERE  a.SubscriptionTypeID = b.SubscriptionTypeID
	AND    a.ChannelTypeID      = c.ChannelTypeID
	AND    b.SubscriptionTypeID = @defaultoptinleisure
	AND    c.Name = 'Email'

	DECLARE @OptOuts as CURSOR
	SET @OptOuts = CURSOR FOR
		select 
		--top 10
		b.individualid, a.EventTimeStamp, 0 [optinind]
		from emm_sys..SP_OptOut a with(nolock)
		inner join Staging.STG_ElectronicAddress b with(nolock) on a.email=b.Address and b.AddressTypeID=3
		inner join Production.Individual c with(nolock) on c.individualid = b.individualid
		inner join [Staging].[STG_IndividualSubscriptionPreference] p with(nolock) on p.individualid=c.individualid and p.SubscriptionChannelTypeID=@subscriptionchanneltypeidleisure and p.ArchivedInd=0
		where c.OptInLeisureInd=1 
		and EventTimeStamp>p.SourceChangeDate
 
	OPEN @OptOuts
	FETCH NEXT FROM @OptOuts INTO @individualid, @eventstamp, @optinind
 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		 --PRINT 'individualid='+cast(@individualid as VARCHAR (50)) + ',Stamp=' + cast(@eventstamp as VARCHAR (50))+ ',InfoSourceId=' + cast(@informationsourceid  as VARCHAR (5)) + ',Optin='+cast(@optinind as VARCHAR(1))

		exec [Staging].[STG_IndividualSubscriptionPreference_Update] 
						@userid						= @userid,
						@informationsourceid		= @informationsourceid,
						@individualid				= @individualid,
						@sourcechangedate			= @eventstamp,
						@subscriptionchanneltypeid	= @defaultoptinleisure,
						@optinind                   = @optinind,
						@recordcount                = @recordcount
		SELECT @records = @records + 1

	 FETCH NEXT FROM @OptOuts INTO @individualid, @eventstamp, @optinind
	END
 
	CLOSE @OptOuts
	DEALLOCATE @OptOuts

    SELECT @recordcount = @records

	RETURN 
END