CREATE PROCEDURE [PreProcessing].[CBE_Journey_Insert]
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

    --It is possible for CBE to send duplicate rows due to changes to other attributes not transferred to CBE within the same batch
	--window. Use CTE to avoid duplicates in the data from CBE

	;WITH CTE_CBE_JourneyDirections AS (
	              SELECT TOP 999999999
						 [CBE_JourneyDirectionID]
                        ,[ID]
                        ,[TKT_ID]
                        ,[Origin_NLC]
                        ,[Destination_NLC]
                        ,[Origin_CRS]
                        ,[Destination_CRS]
                        ,[Departure_Datetime]
                        ,[Arrival_Datetime]
                        ,[Primary_TOC_Code]
                        ,[Date_Created]
                        ,[Date_Modified]
                        ,[IsOutboundInd]
                        ,[IsReturnInd]
						,ROW_NUMBER() OVER (partition by [ID]
						                                ,[TKT_ID]
														 ORDER BY [Date_Modified] DESC
														         ,[CBE_JourneyDirectionID] DESC) RANKING
                  FROM   [PreProcessing].[CBE_JourneyDirection] WITH (NOLOCK)
				  WHERE  DataImportDetailID = @dataimportdetailid
	              AND    ProcessedInd = 0)


    --Start Processing

    INSERT INTO [Staging].[STG_Journey]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SalesDetailID]
           ,[LocationIDOrigin]
           ,[LocationIDDestination]
           ,[ECJourneyScore]
           ,[DepartureDateTime]
           ,[InferredDepartureInd]
           ,[ArrivalDateTime]
           ,[InferredArrivalInd]
		   ,[TOCIDPrimary]
		   ,[IsOutboundInd]
		   ,[IsReturnInd]
		   ,[InformationSourceID]
		   ,[ExtReference]
		   ,[SourceCreatedDate]
		   ,[SourceModifiedDate]
		   ,[CustomerID])
    SELECT  GETDATE()
           ,@userid
		   ,GETDATE()
		   ,@userid
		   ,0
		   ,a.SalesDetailID
		   ,c.LocationID
		   ,d.LocationID
		   ,0
		   ,b.Departure_Datetime
		   ,0
		   ,b.Arrival_Datetime
		   ,0
		   ,e.TOCID
		   ,b.IsOutboundInd
		   ,b.IsReturnInd
		   ,@informationsourceid
		   ,CAST(b.ID AS NVARCHAR(256))
		   ,b.Date_Created
		   ,b.Date_Modified
		   ,a.CustomerID
    FROM [Staging].[STG_SalesDetail] a WITH (NOLOCK)
	INNER JOIN CTE_CBE_JourneyDirections         b WITH (NOLOCK) ON SUBSTRING(a.ExtReference,CHARINDEX('TKT',a.ExtReference,1)+7,LEN(a.ExtReference)) = CAST(b.TKT_ID AS NVARCHAR(256))
	LEFT JOIN  #tmp_NLCCode_LU                   c WITH (NOLOCK) ON c.NLCCode = b.Origin_NLC
	LEFT JOIN  #tmp_NLCCode_LU                   d WITH (NOLOCK) ON d.NLCCode = b.Destination_NLC
	LEFT JOIN  [Reference].[TOC]                 e WITH (NOLOCK) ON e.ShortCode = b.Primary_TOC_Code
	LEFT JOIN  [Staging].[STG_Journey]           f WITH (NOLOCK) ON f.ExtReference = CAST(b.ID AS NVARCHAR(256))
	                                               AND f.InformationSourceID = @informationsourceid
	WHERE f.SalesDetailID IS NULL
	AND	  a.InformationSourceID = @informationsourceid
	AND   b.RANKING = 1
	AND	  a.IsTrainTicketInd = 1	

	--Update process recrds

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_Journey] a
	INNER JOIN [PreProcessing].[CBE_JourneyDirection] b ON a.ExtReference = CAST(b.ID AS NVARCHAR(256))
	                                                    AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0


	SET @logmessage = 'Update Staging Complete'

	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'DEBUG'

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_JourneyDirection WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_JourneyDirection WITH (NOLOCK)
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