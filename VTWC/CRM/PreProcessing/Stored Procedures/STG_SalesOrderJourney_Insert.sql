CREATE PROCEDURE [PreProcessing].[STG_SalesOrderJourney_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @delimiter           NVARCHAR(5) = ','
	DECLARE @outboundind         BIT         = 1

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER     = 0
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

--Prepare Leg information from the Sales Transaction record

    CREATE TABLE #SalesOrderJourney (
	    [SalesOrderJourneyId]         [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	    [SalesOrderId]                [uniqueidentifier] NULL,
	    [ContactID]                   [uniqueidentifier] NULL,
	    [out_journeyorigin]           [nvarchar](512) NULL,
	    [out_journeydestination]      [nvarchar](512) NULL,
	    [out_route]                   [nvarchar](max) NULL,
	    [out_outlegclass]             [nvarchar](100) NULL,
	    [out_outretailserviceids]     [nvarchar](100) NULL,
	    [out_outseatreservations]     [nvarchar](640) NULL,
	    [out_outserviceoperators]     [nvarchar](100) NULL,
	    [out_outTOCdestination]       [nvarchar](100) NULL,
	    [out_outTOCorigin]            [nvarchar](100) NULL,
	    [out_retlegclass]             [nvarchar](100) NULL,
	    [out_retretailserviceids]     [nvarchar](100) NULL,
	    [out_retseatreservations]     [nvarchar](640) NULL,
	    [out_retserviceoperators]     [nvarchar](100) NULL,
	    [out_retTOCorigin]            [nvarchar](100) NULL,
	    [out_retTOCdestination]       [nvarchar](100) NULL,
	    [leg_seqno]                   [int] NULL,
	    [leg_rsid]                    [nvarchar](100) NULL,
	    [leg_TOC]                     [nvarchar](2) NULL,
	    [leg_origin]                  [nvarchar](100) NULL,
	    [leg_destination]             [nvarchar](100) NULL,
	    [leg_class]                   [nvarchar](100) NULL,
	    [leg_reservation]             [nvarchar](100) NULL,
	    [leg_outboundind]             [bit] NULL)

    CREATE CLUSTERED INDEX cndx_SalesOrderJourney_SalesOrderJourneyId
	    ON #SalesOrderJourney(SalesOrderJourneyId)
    
	CREATE NONCLUSTERED INDEX [ix_SalesOrderJourney_SalesOrderId]
        ON #SalesOrderJourney ([SalesOrderId],[leg_TOC],[leg_outboundind])

	INSERT INTO #SalesOrderJourney
           ([SalesOrderId]
		   ,[ContactID]
           ,[out_journeyorigin]
           ,[out_journeydestination]
           ,[out_route]
           ,[out_outlegclass]
           ,[out_outretailserviceids]
           ,[out_outseatreservations]
           ,[out_outserviceoperators]
           ,[out_outTOCdestination]
           ,[out_outTOCorigin]
           ,[out_retlegclass]
           ,[out_retretailserviceids]
           ,[out_retseatreservations]
           ,[out_retserviceoperators]
           ,[out_retTOCorigin]
           ,[out_retTOCdestination]
           ,[leg_seqno]
           ,[leg_rsid]
		   ,[leg_TOC]
		   ,[leg_outboundind])
    SELECT  a.[SalesOrderId]
	       ,a.[ContactID]
           ,a.[out_journeyorigin]
           ,a.[out_journeydestination]
           ,a.[out_route]
           ,a.[out_outlegclass]
           ,a.[out_outretailserviceids]
           ,a.[out_outseatreservations]
           ,a.[out_outserviceoperators]
           ,a.[out_outTOCdestination]
           ,a.[out_outTOCorigin]
           ,a.[out_retlegclass]
           ,a.[out_retretailserviceids]
           ,a.[out_retseatreservations]
           ,a.[out_retserviceoperators]
           ,a.[out_retTOCorigin]
           ,a.[out_retTOCdestination]
		   ,b.[ID]
		   ,RTRIM(LTRIM(b.[Value]))
		   ,SUBSTRING(RTRIM(LTRIM(b.[Value])),1,2)
		   ,@outboundind
    FROM [PreProcessing].[MSD_SalesOrder] a
	LEFT JOIN [Staging].[STG_SalesTransaction] c ON CAST(a.[SalesOrderId] AS NVARCHAR(256)) = c.[ExtReference]
	CROSS APPLY [Staging].[SplitStringToTable] (a.[out_outretailserviceids],@delimiter) b
	WHERE a.[out_outTOCorigin] IS NOT NULL
	AND   a.[DataImportDetailID] = @dataimportdetailid
	
	SELECT @recordcount = @recordcount + @@ROWCOUNT



--Link Origin to RSID

    UPDATE a
	SET   leg_origin = RTRIM(LTRIM(b.[Value]))
	FROM  #SalesOrderJourney a
	CROSS APPLY (SELECT TOP 1 ID,Value
                 FROM [Staging].[SplitStringToTable] (a.[out_outTOCorigin],@delimiter)
                 WHERE ID > (SELECT COUNT(1)
                             FROM #SalesOrderJourney
                             WHERE salesorderid = a.salesorderid
                             AND   leg_seqno < a.leg_seqno
				             AND   leg_outboundind =  @outboundind
                             AND   SUBSTRING(leg_rsid,1,2) = 'GR'
							 )) b 
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind


--Link Destination to RSID

    UPDATE a
	SET   leg_destination = RTRIM(LTRIM(b.[Value]))
	FROM  #SalesOrderJourney a
	CROSS APPLY (SELECT TOP 1 ID,Value
                 FROM [Staging].[SplitStringToTable] (a.[out_outTOCdestination],@delimiter)
                 WHERE ID > (SELECT COUNT(1)
                             FROM #SalesOrderJourney
                             WHERE salesorderid = a.salesorderid
                             AND   leg_seqno < a.leg_seqno
				             AND   leg_outboundind =  @outboundind
                             AND   SUBSTRING(leg_rsid,1,2) = 'GR'
							 )) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Class to RSID

    SET @delimiter = '|'

    UPDATE a
	SET   leg_class = RTRIM(LTRIM(SUBSTRING(b.[Value],CHARINDEX(':',b.[Value])+1,999)))
	FROM  #SalesOrderJourney a
	CROSS APPLY (SELECT TOP 1 ID,Value
                 FROM [Staging].[SplitStringToTable] (a.[out_outlegclass],@delimiter)
                 WHERE ID > (SELECT COUNT(1)
                             FROM #SalesOrderJourney
                             WHERE salesorderid = a.salesorderid
                             AND   leg_seqno < a.leg_seqno
				             AND   leg_outboundind =  @outboundind
                             AND   SUBSTRING(leg_rsid,1,2) = 'GR'
							 )) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Class to Reservation

    UPDATE a
	SET   leg_reservation = RTRIM(LTRIM(SUBSTRING(b.[Value],CHARINDEX(':',b.[Value])+1,999)))
	FROM  #SalesOrderJourney a
	CROSS APPLY (SELECT TOP 1 ID,Value
                 FROM [Staging].[SplitStringToTable] (a.[out_outseatreservations],@delimiter)
                 WHERE ID > (SELECT COUNT(1)
                             FROM #SalesOrderJourney
                             WHERE salesorderid = a.salesorderid
                             AND   leg_seqno < a.leg_seqno
				             AND   leg_outboundind =  @outboundind
							 )) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Return Journeys
    
    SET @outboundind = 0
	SET @delimiter = ','

    INSERT INTO #SalesOrderJourney
           ([SalesOrderId]
		   ,[ContactID]
           ,[out_journeyorigin]
           ,[out_journeydestination]
           ,[out_route]
           ,[out_outlegclass]
           ,[out_outretailserviceids]
           ,[out_outseatreservations]
           ,[out_outserviceoperators]
           ,[out_outTOCdestination]
           ,[out_outTOCorigin]
           ,[out_retlegclass]
           ,[out_retretailserviceids]
           ,[out_retseatreservations]
           ,[out_retserviceoperators]
           ,[out_retTOCorigin]
           ,[out_retTOCdestination]
           ,[leg_seqno]
           ,[leg_rsid]
		   ,[leg_TOC]
		   ,[leg_outboundind])
    SELECT  a.[SalesOrderId]
	       ,a.[ContactID]
           ,a.[out_journeyorigin]
           ,a.[out_journeydestination]
           ,a.[out_route]
           ,a.[out_outlegclass]
           ,a.[out_outretailserviceids]
           ,a.[out_outseatreservations]
           ,a.[out_outserviceoperators]
           ,a.[out_outTOCdestination]
           ,a.[out_outTOCorigin]
           ,a.[out_retlegclass]
           ,a.[out_retretailserviceids]
           ,a.[out_retseatreservations]
           ,a.[out_retserviceoperators]
           ,a.[out_retTOCorigin]
           ,a.[out_retTOCdestination]
		   ,b.[ID]
		   ,RTRIM(LTRIM(b.[Value]))
		   ,SUBSTRING(RTRIM(LTRIM(b.[Value])),1,2)
		   ,@outboundind
    FROM [PreProcessing].[MSD_SalesOrder] a
	LEFT JOIN [Staging].[STG_SalesTransaction] c ON CAST(a.[SalesOrderId] AS NVARCHAR(256)) = c.[ExtReference]
	CROSS APPLY [Staging].[SplitStringToTable] (a.[out_retretailserviceids],@delimiter) b
	WHERE a.[out_retTOCorigin] IS NOT NULL
    AND   a.[DataImportDetailID] = @dataimportdetailid
	
	SELECT @recordcount = @recordcount + @@ROWCOUNT


--Link Origin to RSID

    UPDATE a
	SET   leg_origin = RTRIM(LTRIM(b.[Value]))
	FROM  #SalesOrderJourney a
	CROSS APPLY (SELECT TOP 1 ID,Value
                 FROM [Staging].[SplitStringToTable] (a.[out_retTOCorigin],@delimiter)
                 WHERE ID > (SELECT COUNT(1)
                             FROM #SalesOrderJourney
                             WHERE salesorderid = a.salesorderid
                             AND   leg_seqno < a.leg_seqno
				             AND   leg_outboundind =  @outboundind
                             AND   SUBSTRING(leg_rsid,1,2) = 'GR')) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Destination to RSID

    UPDATE a
	SET   leg_destination = RTRIM(LTRIM(b.[Value]))
	FROM  #SalesOrderJourney a
	CROSS APPLY (SELECT TOP 1 ID,Value
                 FROM [Staging].[SplitStringToTable] (a.[out_retTOCdestination],@delimiter)
                 WHERE ID > (SELECT COUNT(1)
                             FROM #SalesOrderJourney
                             WHERE salesorderid = a.salesorderid
                             AND   leg_seqno < a.leg_seqno
				             AND   leg_outboundind =  @outboundind
                             AND   SUBSTRING(leg_rsid,1,2) = 'GR')) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Class to RSID

    SET @delimiter = '|'

    UPDATE a
	SET   leg_class = RTRIM(LTRIM(SUBSTRING(b.[Value],CHARINDEX(':',b.[Value])+1,999)))
	FROM  #SalesOrderJourney a
	CROSS APPLY (SELECT TOP 1 ID,Value
                 FROM [Staging].[SplitStringToTable] (a.[out_retlegclass],@delimiter)
                 WHERE ID > (SELECT COUNT(1)
                             FROM #SalesOrderJourney
                             WHERE salesorderid = a.salesorderid
                             AND   leg_seqno < a.leg_seqno
				             AND   leg_outboundind =  @outboundind
                             AND   SUBSTRING(leg_rsid,1,2) = 'GR')) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Class to Reservation

    SET @delimiter = '|'

    UPDATE a
	SET   leg_reservation = RTRIM(LTRIM(SUBSTRING(b.[Value],CHARINDEX(':',b.[Value])+1,999)))
	FROM  #SalesOrderJourney a
	CROSS APPLY (SELECT TOP 1 ID,Value
                 FROM [Staging].[SplitStringToTable] (a.[out_retseatreservations],@delimiter)
                 WHERE ID > (SELECT COUNT(1)
                             FROM #SalesOrderJourney
                             WHERE salesorderid = a.salesorderid
                             AND   leg_seqno < a.leg_seqno
				             AND   leg_outboundind =  @outboundind
							 )) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Cater for where the reservation information is truncated, e.g. D 61, D 62Leg 3:

	UPDATE #SalesOrderJourney
	SET    leg_reservation = SUBSTRING(leg_reservation,1,CHARINDEX('Leg',leg_reservation,1)-1)
	WHERE  leg_reservation like '%leg%'



--Add OutBound
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
    INNER JOIN #SalesOrderJourney d ON CAST(d.SalesOrderId AS nvarchar(256)) = c.ExtReference AND d.leg_OutBoundInd = 1
    LEFT JOIN  Reference.TicketClass e ON e.Name = d.leg_class
    LEFT JOIN  Reference.LocationAlias f ON f.Name = d.leg_origin
    LEFT JOIN  Reference.LocationAlias g ON g.Name = d.leg_destination
	LEFT JOIN  Reference.TOC h ON d.leg_TOC = h.ShortCode
	LEFT JOIN  Staging.STG_JourneyLeg i ON i.JourneyID = a.JourneyID
    WHERE b.IsTrainTicketInd = 1
    AND   a.IsOutboundInd = 1
	AND   i.JourneyID IS NULL
	
    SELECT @recordcount = @@ROWCOUNT

----Returns

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
    INNER JOIN #SalesOrderJourney d ON CAST(d.SalesOrderId AS nvarchar(256)) = c.ExtReference AND d.leg_OutBoundInd = 0
	LEFT JOIN  Reference.TicketClass e ON e.Name = d.leg_class
    LEFT JOIN  Reference.LocationAlias f ON f.Name = d.leg_origin
    LEFT JOIN  Reference.LocationAlias g ON g.Name = d.leg_destination
	LEFT JOIN  Reference.TOC h ON d.leg_TOC = h.ShortCode
	LEFT JOIN  Staging.STG_JourneyLeg i ON i.JourneyID = a.JourneyID
    WHERE b.IsTrainTicketInd = 1
	AND   a.IsOutboundInd = 0
	AND   (a.IsReturnInd = 1 OR a.IsReturnInferredInd = 1)
	AND   a.IsOutboundInd = 0
	AND   i.JourneyID IS NULL
	
	SELECT @recordcount = @recordcount + @@ROWCOUNT

--/** Need to amend the following once ticket types details are resolved. Reservation vs. inferred journey **/

	UPDATE a
	SET  ECJourneyScore = 50 
	FROM [Staging].[STG_Journey] a,
	     [Staging].[STG_JourneyLeg] b,
		 [Staging].[STG_SalesDetail] c,
		 [Staging].[STG_SalesTransaction] d,
		 #SalesOrderJourney e
    WHERE a.JourneyID = b.JourneyID
	AND   c.SalesDetailID = a.SalesDetailID
	AND   d.SalesTransactionID = c.SalesTransactionID
	AND   CAST(e.[SalesOrderId] AS NVARCHAR(256)) = d.[ExtReference]
	AND   SUBSTRING(b.RSID,1,2) = 'GR'
	AND   e.leg_TOC = 'GR'

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END