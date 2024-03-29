USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_JourneyLeg_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_JourneyLeg_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

--OutBound
    INSERT INTO [Staging].[STG_JourneyLeg]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[JourneyID]
		   ,[RSID]
           ,[LegNumber]
           ,[TicketClassID]
           ,[LocationIDOrigin]
           ,[LocationIDDestination]
		   ,[SeatReservation]
		   ,[TOCID]
		   ,[DirectionCd])
    SELECT GETDATE()
	       ,@userid
		   ,GETDATE()
		   ,@userid
	       ,a.JourneyID
		   ,d.Leg_RSID
           ,d.Leg_SeqNo
	       ,e.TicketClassID
	       ,f.LocationID
	       ,g.LocationID
		   ,d.leg_reservation
		   ,h.TOCID
		   ,CASE WHEN SUBSTRING(d.Leg_RSID,1,2) = 'GR' AND SUBSTRING(d.Leg_RSID,3,1)%2 <> 0 THEN 'South' 
	             WHEN SUBSTRING(d.Leg_RSID,1,2) = 'GR' AND SUBSTRING(d.Leg_RSID,3,1)%2  = 0 THEN 'North' END
    FROM Staging.STG_Journey a
    INNER JOIN Staging.STG_SalesDetail b ON a.SalesDetailID = b.SalesDetailID
    INNER JOIN Staging.STG_SalesTransaction c ON c.SalesTransactionID = b.SalesTransactionID
    INNER JOIN Migration.MSD_SalesOrderJourney d ON CAST(d.SalesOrderId AS nvarchar(256)) = c.ExtReference
    LEFT JOIN  Reference.TicketClass e ON e.Name = d.leg_class
    LEFT JOIN  Reference.LocationAlias f ON f.Name = d.leg_origin
    LEFT JOIN  Reference.LocationAlias g ON g.Name = d.leg_destination
	LEFT JOIN  Reference.TOC h ON d.leg_TOC = h.ShortCode
    WHERE d.leg_OutBoundInd = 1
    AND   b.IsTrainTicketInd = 1
    AND   a.IsOutboundInd = 1

	SELECT @recordcount = @@ROWCOUNT

--Returns

    INSERT INTO [Staging].[STG_JourneyLeg]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[JourneyID]
		   ,[RSID]
           ,[LegNumber]
           ,[TicketClassID]
           ,[LocationIDOrigin]
           ,[LocationIDDestination]
		   ,[SeatReservation]
		   ,[DirectionCd])
    SELECT GETDATE()
	       ,@userid
		   ,GETDATE()
		   ,@userid
	       ,a.JourneyID
		   ,d.Leg_RSID
           ,d.Leg_SeqNo
	       ,e.TicketClassID
	       ,f.LocationID
	       ,g.LocationID
		   ,d.leg_reservation
		   ,CASE WHEN SUBSTRING(d.Leg_RSID,1,2) = 'GR' AND SUBSTRING(d.Leg_RSID,3,1)%2 <> 0 THEN 'South'  
	             WHEN SUBSTRING(d.Leg_RSID,1,2) = 'GR' AND SUBSTRING(d.Leg_RSID,3,1)%2  = 0 THEN 'North' END
    FROM Staging.STG_Journey a
    INNER JOIN Staging.STG_SalesDetail b ON a.SalesDetailID = b.SalesDetailID
    INNER JOIN Staging.STG_SalesTransaction c ON c.SalesTransactionID = b.SalesTransactionID
    INNER JOIN Migration.MSD_SalesOrderJourney d ON CAST(d.SalesOrderId AS nvarchar(256)) = c.ExtReference
    LEFT JOIN  Reference.TicketClass e ON e.Name = d.leg_class
    LEFT JOIN  Reference.LocationAlias f ON f.Name = d.leg_origin
    LEFT JOIN  Reference.LocationAlias g ON g.Name = d.leg_destination
    WHERE (d.leg_OutBoundInd = 0
    AND   b.IsTrainTicketInd = 1
    AND   a.IsReturnInd = 0
	AND   a.IsOutboundInd = 0)
	OR    (d.leg_OutBoundInd = 0
    AND   b.IsTrainTicketInd = 1
	AND   b.IsReturnInferredInd = 1
	AND   a.IsOutboundInd = 0)

	SELECT @recordcount = @recordcount + @@ROWCOUNT

--Cater for where the reservation information is truncated, e.g. D 61, D 62Leg 3:

	UPDATE [Staging].[STG_JourneyLeg]
	SET    SeatReservation = SUBSTRING(SeatReservation,1,CHARINDEX('Leg',seatreservation,1)-1)
	WHERE  SeatReservation like '%leg%'


/** Need to amend the following once ticket types details are resolved. Reservation vs. inferred journey **/

	UPDATE a
	SET  ECJourneyScore = 50
	FROM [Staging].[STG_Journey] a,
	     [Staging].[STG_JourneyLeg] b
    WHERE a.JourneyID = b.JourneyID
	AND   SUBSTRING(b.RSID,1,2) = 'GR'

    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END











GO
