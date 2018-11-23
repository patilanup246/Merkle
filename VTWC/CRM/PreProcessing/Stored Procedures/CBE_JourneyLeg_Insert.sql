
CREATE PROCEDURE [PreProcessing].[CBE_JourneyLeg_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER

	DECLARE @now                    DATETIME
	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)
	DECLARE @successcountimport    INTEGER       = 0
	DECLARE @errorcountimport      INTEGER       = 0

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @now = GETDATE()

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

    --Get configuration settings

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'CBE'

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL')
		
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

	--Create temporary table with location information to aid performance

	SELECT [LocationID]
          ,[LocationIDParent]
          ,[Name]
          ,[Description]
          ,[TIPLOC]
          ,[NLCCode]
          ,[CRSCode]
          ,[CATEType]
          ,[3AlphaCode]
          ,[3AlphaCodeSub]
          ,[Longitude]
          ,[Latitude]
          ,[Northing]
          ,[Easting]
          ,[ChangeTime]
          ,[DescriptionATOC]
          ,[DescriptionATOC_ATB]
          ,[NLCPlusbus]
          ,[PTECode]
          ,[IsPlusbusInd]
          ,[IsGroupStationInd]
          ,[LondonZoneNumber]
          ,[PartOfAllZones]
          ,[IDMSDisplayName]
          ,[IDMSPrintingName]
          ,[IsIDMSAttendedTISInd]
          ,[IsIDMSUnattendedTISInd]
          ,[IDMSAdviceMessage]
          ,[ExtReference]
          ,[SourceCreatedDate]
          ,[SourceModifiedDate]
          ,[CreatedDate]
          ,[LastModifiedDate]
    INTO #tmp_NLCCode_LU
    FROM [Reference].[Location_NLCCode_VW]

	--Get latest journey leg information

	;WITH CTE_JourneyLegs AS (
	        SELECT TOP 999999999
				   [CBE_JourneyLegID]
                  ,[ID]
                  ,[JRND_ID]
                  ,[LEG_ID]
                  ,[TOC_Code]
                  ,[RSID]
                  ,[Origin_NLC]
                  ,[Destination_NLC]
                  ,[Origin_CRS]
                  ,[Destination_CRS]
                  ,[Origin_Departure_Time]
                  ,[Destination_Arrive_Time]
                  ,[Day_Plus_One]
                  ,[Recommended_Transfer_Time]
                  ,[TrainUID]
                  ,[Train_Category]
                  ,[Train_Origin_NLC]
                  ,[Train_Destination_NLC]
                  ,[Train_Origin_CRS]
                  ,[Train_Destination_CRS]
                  ,[Catering_Codes]
                  ,[Date_Created]
                  ,[Date_Modified]
				  ,ROW_NUMBER() OVER (partition by [ID]
						                          ,[JRND_ID]
												  ,[LEG_ID]
										  ORDER BY [Date_Modified] DESC
											      ,[CBE_JourneyLegID] DESC) RANKING
            FROM [PreProcessing].[CBE_JourneyLeg] a WITH (NOLOCK)
			WHERE a.ProcessedInd = 0
		    AND   a.DataImportDetailID = @dataimportdetailid)
	
    SELECT *
	INTO #tmp_JourneyLegs
	FROM CTE_JourneyLegs
	WHERE RANKING = 1
	
	--First add any new train journeys

	;WITH TrainJourneys AS
		(
	     SELECT TOP 999999999
				CAST(a.Origin_Departure_Time AS DATE) AS DepartureDate
	           ,a.TrainUID                            AS TrainUID
		       ,a.Train_Category                      AS TrainCategory
	           ,b.LocationID                          AS LocationIDOrigin
		       ,c.LocationID                          AS LocationIDDestination
		       ,a.Date_Created                        AS SourceCreatedDate
			   ,a.Date_Modified                       AS SourceModifiedDate
		       ,ROW_NUMBER() OVER(Partition BY CAST(a.Origin_Departure_Time AS DATE)
	                                          ,a.TrainUID
		                                      ,a.Train_Category
	                                          ,b.LocationID
		                                      ,c.LocationID
			                                  ORDER BY a.Date_Created) AS Ranking
        FROM #tmp_JourneyLegs                   a WITH (NOLOCK)
	    INNER JOIN #tmp_NLCCode_LU              b WITH (NOLOCK) ON a.Train_Origin_NLC      = b.NLCCode
	    INNER JOIN #tmp_NLCCode_LU              c WITH (NOLOCK) ON a.Train_Destination_NLC = c.NLCCode
	    LEFT JOIN  [Staging].[STG_JourneyTrain] d WITH (NOLOCK) ON CAST(a.Origin_Departure_Time AS DATE) = d.DepartureDate
	                                                 AND a.TrainUID = d.TrainUID
			    							         AND a.Train_Category = d.TrainCategory
				    						         AND d.LocationIDOrigin = b.LocationID
					    					         AND d.LocationIDDestination = c.LocationID
        WHERE a.TrainUID IS NOT NULL
	    AND   d.TrainUID IS NULL
	)

	INSERT INTO [Staging].[STG_JourneyTrain]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[InformationSourceID]
           ,[DepartureDate]
           ,[TrainUID]
           ,[TrainCategory]
           ,[LocationIDOrigin]
           ,[LocationIDDestination])
    SELECT  GETDATE()
	       ,@userid
		   ,GETDATE()
		   ,@userid
		   ,0
		   ,SourceCreatedDate
		   ,SourceModifiedDate
		   ,@informationsourceid
		   ,DepartureDate
		   ,TrainUID
		   ,TrainCategory
		   ,LocationIDOrigin
		   ,LocationIDDestination
	FROM TrainJourneys WITH (NOLOCK)
    WHERE Ranking = 1

   INSERT INTO [Staging].[STG_JourneyLeg]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[JourneyID]
           ,[LegNumber]
           ,[RSID]
		   ,[TicketClassID]
           ,[LocationIDOrigin]
           ,[LocationIDDestination]
           ,[DepartureDateTime]
           ,[InferredDepartureInd]
           ,[ArrivalDateTime]
           ,[InferredArrivalInd]
           ,[TOCID]
		   ,[DirectionCd]
		   ,[DayPlusOne]
		   ,[RecommendedXferTime]
		   ,[CateringCode]
		   ,[JourneyTrainID]
		   ,[ExtReference]
		   ,[InformationSourceID]
		   ,[SourceCreatedDate]
		   ,[SourceModifiedDate])
    SELECT GETDATE()
	       ,@userid
		   ,GETDATE()
		   ,@userid
		   ,0
	       ,a.JourneyID
		   ,b.Leg_ID
           ,b.RSID
		   ,j.TicketClassID
	       ,c.LocationID
	       ,d.LocationID
		   ,b.Origin_Departure_Time
		   ,0
		   ,Destination_Arrive_Time
		   ,0
		   ,h.TOCID
		   ,CASE WHEN SUBSTRING(b.RSID,1,2) = 'GR' AND SUBSTRING(b.RSID,3,1)%2 <> 0 THEN 'South' 
	             WHEN SUBSTRING(b.RSID,1,2) = 'GR' AND SUBSTRING(b.RSID,3,1)%2  = 0 THEN 'North' END
		   ,b.Day_Plus_One
		   ,b.Recommended_Transfer_Time
		   ,b.Catering_Codes
		   ,g.JourneyTrainID
		   ,CAST(b.ID AS NVARCHAR(256))
		   ,@informationsourceid
		   ,b.Date_Created
		   ,b.Date_Modified
    FROM [Staging].[STG_SalesDetail] sd WITH (NOLOCK)
	INNER JOIN [Staging].[STG_Journey]           a WITH (NOLOCK) ON sd.SalesDetailID = a.SalesDetailID
    INNER JOIN #tmp_JourneyLegs                  b WITH (NOLOCK) ON b.JRND_ID = CAST(a.ExtReference AS INTEGER)
	                                               AND a.InformationSourceID = @informationsourceid
    LEFT JOIN  #tmp_NLCCode_LU                   c WITH (NOLOCK) ON  b.Origin_NLC = c.NLCCode
    LEFT JOIN  #tmp_NLCCode_LU                   d WITH (NOLOCK) ON  b.Destination_NLC =  d.NLCCode
    LEFT JOIN  #tmp_NLCCode_LU                   e WITH (NOLOCK) ON  b.Train_Origin_NLC = e.NLCCode
    LEFT JOIN  #tmp_NLCCode_LU                   f WITH (NOLOCK) ON  b.Train_Destination_NLC =  f.NLCCode
    LEFT JOIN  [Staging].[STG_JourneyTrain]      g WITH (NOLOCK) ON  b.TrainUID = g.TrainUID
	                                               AND CAST(b.Origin_Departure_Time AS DATE) = g.DepartureDate
											       AND e.LocationID = g.LocationIDOrigin
											       AND f.LocationID = g.LocationIDDestination
	LEFT JOIN  [Reference].[TOC]                 h WITH (NOLOCK) ON  b.TOC_Code = h.ShortCode
	LEFT JOIN  [Staging].[STG_JourneyLeg]        i WITH (NOLOCK) ON  CAST(i.ExtReference AS INTEGER) = b.ID
	                                               AND i.InformationSourceID = @informationsourceid
    LEFT JOIN  [Reference].[Product]             j WITH (NOLOCK) ON  sd.ProductID = j.ProductID
    WHERE i.JourneyLegID IS NULL

	--Update process recrds

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_JourneyLeg] a
	INNER JOIN [PreProcessing].[CBE_JourneyLeg] b ON CAST(a.ExtReference AS INTEGER) = b.ID
	                                              AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_JourneyLeg WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_JourneyLeg WITH (NOLOCK)
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid
	
	SELECT @recordcount = @successcountimport + @errorcountimport

	
    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = NULL,
	                                            @endtimeimport         = @now,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = @successcountimport,
	                                            @errorcountimport      = @errorcountimport


    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END