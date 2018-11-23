

CREATE PROCEDURE [Staging].[STG_Train_RSID_Mapping_Insert]
(
    @userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @spname                 NVARCHAR(256)
    DECLARE @recordcount            INTEGER
    DECLARE @logtimingidnew         INTEGER
    DECLARE @logmessage             NVARCHAR(MAX)

    SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    --Log start time--

    EXEC [Operations].[LogTiming_Record] @userid         = @userid,
                                         @logsource      = @spname,
                                         @logtimingidnew = @logtimingidnew OUTPUT

	select
		convert(date, j.OutDepartureDateTime) [TravelDate],
		left(convert(time(0), j.OutDepartureDateTime),5) [TravelTime],
		right(l.rsid,6) [RSID],
		l.LocationIDOrigin [OriginID],
		l.LocationIDDestination [DestID]
		into #journeys
		from [Staging].[STG_Journey] j
		inner join Staging.stg_journeyLeg l on j.journeyid=l.JourneyID and l.tocid=31 and j.LocationIDOrigin=l.LocationIDOrigin
		where j.OutDepartureDateTime between convert(date,dateadd(mm,-6,getdate())) and convert(date,dateadd(day,+14,getdate()));

	create index tmp_Journeys on #journeys([TravelDate], [OriginID]) include ( [RSID], [TravelTime] , [DestID]);

	IF OBJECT_ID('Staging.STG_Train_RSID_Mapping') IS NOT NULL
		drop table Staging.STG_Train_RSID_Mapping;

	select
	x.TravelDate, x.RSID, max(d.trainId) [trainid], min(x.TravelTime) [StartTime], left(max(convert(time(0), isnull(d.pta, d.wta))),5) [ArrivalTime]
	into   Staging.STG_Train_RSID_Mapping
	from   #journeys x with(nolock)
	inner join [Railtimetable].JourneyStages s with(nolock)
	  on s.toc='VT'	
	  and s.ssd=x.[TravelDate]
	  and s.locationID = x.OriginID
	  and (s.stage in ('OR','IP') and TravelTime in (s.ptd, s.wtd) ) -- Origin or Station
	  and s.isPassengersvc='true'
	  and s.trainId<>'0B00' -- skip Bus Replacements and Freight
	inner join [Railtimetable].[JourneyStages] d with(nolock)
		on s.rid=d.rid and s.uid=d.uid and s.ssd=d.ssd and s.toc=d.toc and x.DestID=d.locationID
		and len(isnull(d.pta, d.wta))>0
		and convert(time, isnull(d.pta, d.wta)) > convert(time, isnull(s.ptd, s.wtd))
	group by x.TravelDate, x.RSID;

	CREATE UNIQUE CLUSTERED INDEX [ix_Train_RSID_Mapping] ON [Staging].[STG_Train_RSID_Mapping]
	(
		[TravelDate] ASC,
		[RSID] ASC,
		[trainId] ASC
	);
    --Log end time

    EXEC [Operations].[LogTiming_Record] @userid         = @userid,
                                         @logsource      = @spname,
                                         @logtimingid    = @logtimingidnew,
                                         @recordcount    = @recordcount,
                                         @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END