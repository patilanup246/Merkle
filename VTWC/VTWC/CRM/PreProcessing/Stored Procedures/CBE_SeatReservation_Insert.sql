CREATE PROCEDURE [PreProcessing].[CBE_SeatReservation_Insert]
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

    --Start Processing

    UPDATE a
	SET    SeatReservation = CASE WHEN ISNULL(b.Coach_Identifier,'') + ' ' + ISNULL(Seat_Berth_Number,'') = ''
	                              THEN NULL
								  ELSE 'COACH ' + ISNULL(b.Coach_Identifier,'') + ' ' + 'SEAT ' + ISNULL(Seat_Berth_Number,'')
							 END
          ,LastModifiedDate = GETDATE()
		  ,LastModifiedBy   = 0
	FROM Staging.STG_SalesDetail sd
	INNER JOIN Staging.STG_Journey j ON sd.SalesDetailID = j.SalesDetailID
	INNER JOIN Staging.STG_JourneyLeg a ON j.JourneyID = a.JourneyID
	INNER JOIN PreProcessing.CBE_SeatReservation b ON  a.ExtReference                     = CAST(b.JL_ID AS NVARCHAR(256))
	                                                   AND a.InformationSourceID          = @informationsourceid
													   AND CAST(b.PF_ID AS nvarchar(256)) = CAST(SUBSTRING(sd.ExtReference,
                                                                                                CHARINDEX('PF_ID=',sd.ExtReference,1)+LEN('PF_ID='),
					                                                                            CHARINDEX(',',SUBSTRING(sd.ExtReference,CHARINDEX('PF_ID=',sd.ExtReference,1)+LEN('PF_ID='),LEN(sd.ExtReference)),1)-1) AS NVARCHAR(256))
    WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   sd.InformationSourceID = @informationsourceid
	AND   b.[ProcessedInd] = 0
	AND   b.[Unit_Type_Code] = 'SEAT'
	AND  sd.IsTrainTicketInd = 1

    --Update process records

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_JourneyLeg] a
	INNER JOIN [PreProcessing].[CBE_SeatReservation] b ON a.ExtReference = CAST(b.JL_ID AS NVARCHAR(256))
	                                                    AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[CBE_SeatReservation] WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[CBE_SeatReservation] WITH (NOLOCK)
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