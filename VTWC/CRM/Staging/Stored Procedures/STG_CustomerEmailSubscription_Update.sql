
CREATE PROCEDURE [Staging].[STG_CustomerEmailSubscription_Update]
(
	@userid                       INTEGER       = 0,   
	@recordcount                  INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @emailpreferenceid                   INTEGER
	DECLARE @WCApreferenceid                   INTEGER
	DECLARE @channelid						INTEGER
	DECLARE @customerid							  INTEGER
	DECLARE @eventstamp							  DATETIME
	DECLARE @optinind							  BIT
	DECLARE @records							  INTEGER = 0

	SELECT @WCApreferenceid = PreferenceID
    FROM   [Reference].[Preference]
    WHERE  Name = 'IBM WCA optouts'

	SELECT @emailpreferenceid = PreferenceID
    FROM   [Reference].[Preference]
    WHERE  Name = 'General Marketing Opt-In'
	
    SELECT @channelid = ChannelID
      FROM Reference.Channel
     WHERE name = 'Email'

	DECLARE @OptOuts as CURSOR
	SET @OptOuts = CURSOR FOR
		select 
		b.CustomerID, a.EventTimeStamp, 0 [optinind]
		from [ibm_system].[dbo].[SP_OptOut] a with(nolock)
		inner join Staging.STG_ElectronicAddress b with(nolock) on a.email=b.Address and b.AddressTypeID=3 and b.primaryInd=1
		inner join Production.Customer c with(nolock) on c.customerid = b.customerid
		left join [Staging].[STG_CustomerPreference] d on d.CustomerID=c.CustomerID
		left join [Reference].[Preference] e on e.PreferenceID=d.PreferenceID and e.Name='IBM WCA optouts'
		left join [Reference].[Channel] f on f.ChannelID=d.ChannelID and f.Name='Email'
		where c.OptInLeisureInd=1 
		and a.EventTimeStamp>d.lastmodifieddate
		and a.IsProcessedInd=0
union  select
		b.CustomerID, a.EventTimeStamp, 0 [optinind]
		from [ibm_system].[dbo].[SP_EmailOptOut] a with(nolock)
		inner join Staging.STG_ElectronicAddress b with(nolock) on a.email=b.Address and b.AddressTypeID=3 and b.primaryInd=1
		inner join Production.Customer c with(nolock) on c.customerid = b.customerid
		left join [Staging].[STG_CustomerPreference] d on d.CustomerID=c.CustomerID
		left join [Reference].[Preference] e on e.PreferenceID=d.PreferenceID and e.Name='IBM WCA optouts'
		left join [Reference].[Channel] f on f.ChannelID=d.ChannelID and f.Name='Email'
		where c.OptInLeisureInd=1 
		and a.EventTimeStamp>d.lastmodifieddate
		and a.IsProcessedInd=0
 
	OPEN @OptOuts
	FETCH NEXT FROM @OptOuts INTO @customerid, @eventstamp, @optinind
 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		 --PRINT 'CustomerID='+cast(@customerid as VARCHAR (50)) + ',Stamp=' + cast(@eventstamp as VARCHAR (50))+ ',InfoSourceId=' + cast(@informationsourceid  as VARCHAR (5)) + ',Optin='+cast(@optinind as VARCHAR(1))

		exec [Staging].[STG_CustomerPreference_Update] 
						@userid						= @userid,
						@customerid					= @customerid,
						@preferenceid				= @WCApreferenceid,
						@channelid					= @channelid,
						@value                      = 1,
						@sourcecreateddate			= @eventstamp,
						@sourcemodifieddate			= @eventstamp

		exec [Staging].[STG_CustomerPreference_Update] 
						@userid						= @userid,
						@customerid					= @customerid,
						@preferenceid				= @emailpreferenceid,
						@channelid					= @channelid,
						@value                      = 0,
						@sourcecreateddate			= @eventstamp,
						@sourcemodifieddate			= @eventstamp
		SELECT @records = @records + 1

	 FETCH NEXT FROM @OptOuts INTO @customerid, @eventstamp, @optinind
	END
 
	CLOSE @OptOuts
	DEALLOCATE @OptOuts

    SELECT @recordcount = @records

	RETURN 
END