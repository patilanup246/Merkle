
CREATE PROCEDURE [PreProcessing].[CBE_EVoucherTicket_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid      INTEGER

	DECLARE @now                      DATETIME
	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)
	DECLARE @successcountimport       INTEGER = 0
	DECLARE @errorcountimport         INTEGER = 0

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC Operations.LogTiming_Record @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @now = GETDATE()

	SELECT @recordcount = COUNT(1)
	FROM  PreProcessing.CBE_EVoucherTicket
	WHERE DataImportDetailID = @dataimportdetailid
	AND   ProcessedInd = 0

    EXEC Operations.DataImportDetail_Update @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

    --Get configuration settings

    SELECT @informationsourceid = InformationSourceID
    FROM Reference.InformationSource
    WHERE Name = 'CBE'

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL')
		
		EXEC Operations.LogMessage_Record @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

	;WITH CTE_CBE_EVoucherTickets AS (
                  SELECT TOP 999999999 
						 CBE_EVoucherTicketID
                        ,ID
                        ,FF_ID
                        ,EV_ID
                        ,Ticket_Number
                        ,Fare_Amount
                        ,Date_Created
                        ,Date_Modified
                        ,Is_Active
				        ,ROW_NUMBER() OVER (partition by ID
						                                ,FF_ID
														,EV_ID
						                                 ORDER BY Date_Modified DESC
														         ,CBE_EVoucherTicketID DESC) RANKING
                  FROM   PreProcessing.CBE_EVoucherTicket WITH (NOLOCK)
				  WHERE  DataImportDetailID = @dataimportdetailid
	              AND    ProcessedInd = 0)

    SELECT *
	INTO #tmp_CBE_EVoucherTickets
	FROM CTE_CBE_EVoucherTickets
	WHERE RANKING = 1

	--update existing records

	UPDATE a
	SET LastModifiedDate = b.Date_Modified
	   ,TicketNumber     = b.Ticket_Number
	   ,SalesAmount      = b.Fare_Amount
	FROM Staging.STG_EVoucherTicket a
	INNER JOIN #tmp_CBE_EVoucherTickets b ON a.ExtReference = 'ID='     + ISNULL(CAST(b.ID AS NVARCHAR(256)),'NULL') + 
                                                              ',FF_ID=' + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
		                                                      ',EV_ID=' + ISNULL(CAST(b.EV_ID AS NVARCHAR(256)),'NULL')

    --Update processed records
	
	UPDATE a
	SET ProcessedInd = 1
	   ,LastModifiedDateETL = GETDATE()
    FROM PreProcessing.CBE_EVoucherTicket a
	INNER JOIN Staging.STG_EVoucherTicket b ON b.ExtReference = 'ID='     + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
                                                                ',FF_ID=' + ISNULL(CAST(a.FF_ID AS NVARCHAR(256)),'NULL') + 
		                                                        ',EV_ID=' + ISNULL(CAST(a.EV_ID AS NVARCHAR(256)),'NULL')
                                                       AND b.InformationSourceID = @informationsourceid
	WHERE a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

	--new records

	INSERT INTO Staging.STG_EVoucherTicket
           (CreatedDate
           ,CreatedBy
           ,LastModifiedDate
           ,LastModifiedBy
           ,ArchivedInd
           ,SourceCreatedDate
           ,SourceModifiedDate
           ,InformationSourceID
		   ,EVoucherID
           ,TicketNumber
           ,SalesAmount
           ,ExtReference)
	SELECT  GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,CASE WHEN a.Is_Active = 1 THEN 0 ELSE 0 END
		   ,a.Date_Created
		   ,a.Date_Modified
		   ,@informationsourceid
		   ,b.EVoucherID
		   ,a.Ticket_Number
		   ,a.Fare_Amount
           ,'ID='        + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
           ',FF_ID='     + ISNULL(CAST(a.FF_ID AS NVARCHAR(256)),'NULL') + 
		   ',EV_ID='     + ISNULL(CAST(a.EV_ID AS NVARCHAR(256)),'NULL')
    FROM #tmp_CBE_EVoucherTickets a WITH (NOLOCK)
    INNER JOIN Staging.STG_EVoucher      b WITH (NOLOCK) ON SUBSTRING(b.ExtReference,LEN('ID=')+1,CHARINDEX(',EVB_ID',b.ExtReference,1)-LEN('ID=')-1)
	                                         = CAST(a.EV_ID AS nvarchar(256))
										       AND b.InformationSourceID = @informationsourceid
	LEFT JOIN Staging.STG_EVoucherTicket c WITH (NOLOCK) ON c.ExtReference = 'ID='        + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
                                                                  ',FF_ID='     + ISNULL(CAST(a.FF_ID AS NVARCHAR(256)),'NULL') + 
		                                                          ',EV_ID='     + ISNULL(CAST(a.EV_ID AS NVARCHAR(256)),'NULL')
                                               AND b.InformationSourceID = @informationsourceid
    WHERE c.EVoucherTicketID IS NULL
	AND   a.RANKING = 1  

    --Update process records

	UPDATE a
	SET ProcessedInd = 1
	   ,LastModifiedDateETL = GETDATE()
    FROM PreProcessing.CBE_EVoucherTicket a
	INNER JOIN Staging.STG_EVoucherTicket b ON b.ExtReference = 'ID='     + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
                                                                ',FF_ID=' + ISNULL(CAST(a.FF_ID AS NVARCHAR(256)),'NULL') + 
		                                                        ',EV_ID=' + ISNULL(CAST(a.EV_ID AS NVARCHAR(256)),'NULL')
                                                       AND b.InformationSourceID = @informationsourceid
	WHERE a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

    --logging
	
	SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_EVoucherTicket WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_EVoucherTicket WITH (NOLOCK)
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid
	
	SELECT @recordcount = @successcountimport + @errorcountimport

	
    EXEC Operations.DataImportDetail_Update @userid                = @userid,
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

	EXEC Operations.LogTiming_Record @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END