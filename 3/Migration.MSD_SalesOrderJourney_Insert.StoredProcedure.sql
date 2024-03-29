USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[MSD_SalesOrderJourney_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[MSD_SalesOrderJourney_Insert]
(
	@userid         INTEGER = 0,   
	@return         INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @delimiter           NVARCHAR(5) = ','
	DECLARE @outboundind         BIT         = 1

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    INSERT INTO [Migration].[MSD_SalesOrderJourney]
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
		   ,leg_outboundind)
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
    FROM [Migration].[MSD_SalesOrder] a
	CROSS APPLY [Staging].[SplitStringToTable] (a.[out_outretailserviceids],@delimiter) b
	WHERE a.[out_outTOCorigin] IS NOT NULL
    
	SELECT @recordcount = @recordcount + @@ROWCOUNT

--Link Origin to RSID

    UPDATE a
	SET   leg_origin = RTRIM(LTRIM(b.[Value]))
	FROM  [Migration].[MSD_SalesOrderJourney] a
	CROSS APPLY [Migration].[SplitStringForLocation] (a.[out_outTOCorigin],
	                                                  a.[leg_seqno],
													  a.[MSD_SalesOrderJourneyId],
													  a.[SalesOrderId],
													  @delimiter,
													  a.leg_outboundind) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind


--Link Destination to RSID

    UPDATE a
	SET   leg_destination = RTRIM(LTRIM(b.[Value]))
	FROM  [Migration].[MSD_SalesOrderJourney] a
	CROSS APPLY [Migration].[SplitStringForLocation] (a.[out_outTOCdestination],
	                                                  a.[leg_seqno],
													  a.[MSD_SalesOrderJourneyId],
													  a.[SalesOrderId],
													  @delimiter,
													  a.leg_outboundind) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Class to RSID

    SET @delimiter = '|'

    UPDATE a
	SET   leg_class = RTRIM(LTRIM(SUBSTRING(b.[Value],CHARINDEX(':',b.[Value])+1,999)))
	FROM  [Migration].[MSD_SalesOrderJourney] a
	CROSS APPLY [Migration].[SplitStringForLocation] (a.[out_outlegclass],
	                                                  a.[leg_seqno],
													  a.[MSD_SalesOrderJourneyId],
													  a.[SalesOrderId],
													  @delimiter,
													  a.leg_outboundind) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Class to Reservation

    UPDATE a
	SET   leg_reservation = RTRIM(LTRIM(SUBSTRING(b.[Value],CHARINDEX(':',b.[Value])+1,999)))
	FROM  [Migration].[MSD_SalesOrderJourney] a
	CROSS APPLY [Migration].[SplitStringForLocation] (a.[out_outseatreservations],
	                                                  a.[leg_seqno],
													  a.[MSD_SalesOrderJourneyId],
													  a.[SalesOrderId],
													  @delimiter,
													  a.leg_outboundind) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Return Journeys
    
    SET @outboundind = 0
	SET @delimiter = ','

    INSERT INTO [Migration].[MSD_SalesOrderJourney]
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
    FROM [Migration].[MSD_SalesOrder] a
	CROSS APPLY [Staging].[SplitStringToTable] (a.[out_retretailserviceids],@delimiter) b
	WHERE a.[out_retTOCorigin] IS NOT NULL

	SELECT @recordcount = @recordcount + @@ROWCOUNT

--Link Origin to RSID

    UPDATE a
	SET   leg_origin = RTRIM(LTRIM(b.[Value]))
	FROM  [Migration].[MSD_SalesOrderJourney] a
	CROSS APPLY [Migration].[SplitStringForLocation] (a.[out_retTOCorigin],
	                                                  a.[leg_seqno],
													  a.[MSD_SalesOrderJourneyId],
													  a.[SalesOrderId],
													  @delimiter,
													  a.leg_outboundind) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Destination to RSID

    UPDATE a
	SET   leg_destination = RTRIM(LTRIM(b.[Value]))
	FROM  [Migration].[MSD_SalesOrderJourney] a
	CROSS APPLY [Migration].[SplitStringForLocation] (a.[out_retTOCdestination],
	                                                  a.[leg_seqno],
													  a.[MSD_SalesOrderJourneyId],
													  a.[SalesOrderId],
													  @delimiter,
													  a.leg_outboundind) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Class to RSID

    SET @delimiter = '|'

    UPDATE a
	SET   leg_class = RTRIM(LTRIM(SUBSTRING(b.[Value],CHARINDEX(':',b.[Value])+1,999)))
	FROM  [Migration].[MSD_SalesOrderJourney] a
	CROSS APPLY [Migration].[SplitStringForLocation] (a.[out_retlegclass],
	                                                  a.[leg_seqno],
													  a.[MSD_SalesOrderJourneyId],
													  a.[SalesOrderId],
													  @delimiter,
													  a.leg_outboundind) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind

--Link Class to Reservation

    SET @delimiter = '|'

    UPDATE a
	SET   leg_reservation = RTRIM(LTRIM(SUBSTRING(b.[Value],CHARINDEX(':',b.[Value])+1,999)))
	FROM  [Migration].[MSD_SalesOrderJourney] a
	CROSS APPLY [Migration].[SplitStringForLocation] (a.[out_retseatreservations],
	                                                  a.[leg_seqno],
													  a.[MSD_SalesOrderJourneyId],
													  a.[SalesOrderId],
													  @delimiter,
													  a.leg_outboundind) b
    WHERE a.[leg_TOC] = 'GR'
	AND   a.[leg_outboundind] =  @outboundind
	
	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END












GO
