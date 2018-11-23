
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

	DECLARE @channelid							INTEGER = ( SELECT ChannelID    FROM [Reference].[Channel]    WHERE name = 'Email')
	DECLARE @emailpreferenceid                  INTEGER = ( SELECT PreferenceID FROM [Reference].[Preference] WHERE Name = 'General Marketing Opt-In')
	DECLARE @WCApreferenceid					INTEGER = (	SELECT PreferenceID FROM [Reference].[Preference] WHERE Name = 'IBM WCA optouts')
		
	DECLARE @OptOuts as CURSOR
	SET @OptOuts = CURSOR FOR
		select 
		b.individualid, a.EventTimeStamp, 0 [optinind]
		from [ibm_system].[dbo].[SP_OptOut] a with(nolock)
		inner join Staging.STG_ElectronicAddress b with(nolock) on a.email=b.Address and b.AddressTypeID=3
		inner join Production.Individual c with(nolock) on c.individualid = b.individualid
		inner join [Staging].[STG_IndividualPreference] d on d.IndividualID=c.IndividualID
		inner join [Reference].[Preference] e on e.PreferenceID=d.PreferenceID and e.Name='IBM WCA optouts'
		inner join [Reference].[Channel] f on f.ChannelID=d.ChannelID and f.Name='Email'
		where c.OptInLeisureInd=1 
		and a.EventTimeStamp>d.lastmodifieddate
		and a.IsProcessedInd=0
union  select
		a.CustomerID, a.EventTimeStamp, 0 [optinind]
		from [ibm_system].[dbo].[SP_EmailOptOut] a with(nolock)
		inner join Staging.STG_ElectronicAddress b with(nolock) on a.email=b.Address and b.AddressTypeID=3 and b.primaryInd=1
		inner join Production.Individual c with(nolock) on c.individualid = b.individualid
		inner join [Staging].[STG_IndividualPreference] d on d.IndividualID=c.IndividualID
		inner join [Reference].[Preference] e on e.PreferenceID=d.PreferenceID and e.Name='IBM WCA optouts'
		inner join [Reference].[Channel] f on f.ChannelID=d.ChannelID and f.Name='Email'
		where c.OptInLeisureInd=1 
		and a.EventTimeStamp>d.lastmodifieddate
		and a.IsProcessedInd=0 

	OPEN @OptOuts
	FETCH NEXT FROM @OptOuts INTO @individualid, @eventstamp, @optinind
 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		 --PRINT 'individualid='+cast(@individualid as VARCHAR (50)) + ',Stamp=' + cast(@eventstamp as VARCHAR (50))+ ',InfoSourceId=' + cast(@informationsourceid  as VARCHAR (5)) + ',Optin='+cast(@optinind as VARCHAR(1))
		exec [Staging].[STG_individualPreference_Update] 
						@userid						= @userid,
						@individualid				= @individualid,
						@preferenceid				= @WCApreferenceid,
						@channelid					= @channelid,
						@value                      = 1,
						@sourcecreateddate			= @eventstamp,
						@sourcemodifieddate			= @eventstamp

		exec [Staging].[STG_CustomerPreference_Update] 
						@userid						= @userid,
						@individualid				= @individualid,
						@preferenceid				= @emailpreferenceid,
						@channelid					= @channelid,
						@value                      = 0,
						@sourcecreateddate			= @eventstamp,
						@sourcemodifieddate			= @eventstamp

	 FETCH NEXT FROM @OptOuts INTO @individualid, @eventstamp, @optinind
	END
 
	CLOSE @OptOuts
	DEALLOCATE @OptOuts

    SELECT @recordcount = @records

	RETURN 
END