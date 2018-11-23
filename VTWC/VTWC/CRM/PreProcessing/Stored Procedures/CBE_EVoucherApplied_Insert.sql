



CREATE PROCEDURE [PreProcessing].[CBE_EVoucherApplied_Insert]
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

    EXEC Operations.DataImportDetail_Update @userid                = @userid,
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

	--It may possible for CBE to multiple records for the same ID to be passed. Use CTE to avoid duplicates in the data from CBE

	;WITH CTE_CBE_EVoucherApplied AS (
                  SELECT TOP 999999999
						 CBE_EvoucherAppliedID
                        ,ID
                        ,TKT_ID
                        ,EV_ID 
                        ,Amount_Applied
                        ,Date_Created
                        ,Date_Modified
                        ,Is_Active
				        ,ROW_NUMBER() OVER (partition by ID
						                                 ORDER BY Date_Modified DESC
														         ,CBE_EvoucherAppliedID DESC) RANKING
                  FROM   PreProcessing.CBE_EvoucherApplied WITH (NOLOCK)
				  WHERE  DataImportDetailID = @dataimportdetailid
	              AND    ProcessedInd = 0)

    SELECT *
	INTO #tmp_CBE_EVoucherApplied
	FROM CTE_CBE_EVoucherApplied
	WHERE RANKING = 1

	--Update records

	UPDATE a
    SET LastModifiedDate = GETDATE()
	   ,ArchivedInd      = CASE WHEN b.Is_Active = 1 THEN 0 ELSE 0 END
	   ,SourceModifiedDate = b.Date_Modified
	   ,AmountApplied      = b.Amount_Applied
    FROM Staging.STG_EVoucherApplied a
	INNER JOIN #tmp_CBE_EVoucherApplied b ON 'ID='      + ISNULL(CAST(b.ID AS NVARCHAR(256)),'NULL') + 
                                             ',EV_ID='  + ISNULL(CAST(b.EV_ID AS NVARCHAR(256)),'NULL') +
		                                     ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') = a.ExtReference

    --Update processed records

	UPDATE a
	SET ProcessedInd = 1
	   ,LastModifiedDateETL = GETDATE()
    FROM PreProcessing.CBE_EvoucherApplied a
	INNER JOIN Staging.STG_EvoucherApplied b ON b.ExtReference = 'ID='      + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
                                                                     ',EV_ID='  + ISNULL(CAST(a.EV_ID AS NVARCHAR(256)),'NULL') +
		                                                             ',TKT_ID=' + ISNULL(CAST(a.TKT_ID AS NVARCHAR(256)),'NULL')
																	 AND b.InformationSourceID = @informationsourceid
                                                     
	WHERE a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0
	 
	 --add new records

	INSERT INTO Staging.STG_EVoucherApplied
           (Name
           ,Description
           ,CreatedDate
           ,CreatedBy
           ,LastModifiedDate
           ,LastModifiedBy
           ,ArchivedInd
           ,SourceCreatedDate
           ,SourceModifiedDate
           ,InformationSourceID
           ,EVoucherID
           ,SalesDetailID
           ,AmountApplied
           ,ExtReference)
	SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,CASE WHEN a.Is_Active = 1 THEN 0 ELSE 0 END
		   ,a.Date_Created
		   ,a.Date_Modified
		   ,@informationsourceid
		   ,b.EVoucherID
		   ,c.SalesDetailID
		   ,a.Amount_Applied
		   ,'ID='      + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
           ',EV_ID='   + ISNULL(CAST(a.EV_ID AS NVARCHAR(256)),'NULL') +
		   ',TKT_ID='  + ISNULL(CAST(a.TKT_ID AS NVARCHAR(256)),'NULL') 
    FROM #tmp_CBE_EVoucherApplied a WITH (NOLOCK)
	INNER JOIN Staging.STG_EVoucher      b WITH (NOLOCK) ON CAST(a.EV_ID AS NVARCHAR(256)) = SUBSTRING(b.ExtReference,LEN('ID=')+1,CHARINDEX(',EVB_ID',b.ExtReference,1)-LEN('ID=')-1)
	                                              AND b.InformationSourceID = @informationsourceid
    INNER JOIN Staging.STG_SalesDetail   c WITH (NOLOCK) ON CAST(a.TKT_ID AS NVARCHAR(256)) = SUBSTRING(c.ExtReference,CHARINDEX('TKT',c.ExtReference,1)+LEN('TKT_ID='),LEN(c.ExtReference))
	                                              AND c.InformationSourceID = @informationsourceid
    LEFT JOIN  Staging.STG_EVoucherApplied d WITH (NOLOCK) ON d.ExtReference = 'ID='       + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
                                                                   ',EV_ID='   + ISNULL(CAST(a.EV_ID AS NVARCHAR(256)),'NULL') +
		                                                           ',TKT_ID='  + ISNULL(CAST(a.TKT_ID AS NVARCHAR(256)),'NULL')
                                              AND d.InformationSourceID = @informationsourceid
    WHERE d.EVoucherAppliedID IS NULL
	AND   a.RANKING = 1  

    --Update process recrds

	UPDATE a
	SET ProcessedInd = 1
	   ,LastModifiedDateETL = GETDATE()
    FROM PreProcessing.CBE_EvoucherApplied a
	INNER JOIN Staging.STG_EvoucherApplied b ON b.ExtReference = 'ID='      + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
                                                                     ',EV_ID='  + ISNULL(CAST(a.EV_ID AS NVARCHAR(256)),'NULL') +
		                                                             ',TKT_ID=' + ISNULL(CAST(a.TKT_ID AS NVARCHAR(256)),'NULL')
																	 AND b.InformationSourceID = @informationsourceid
                                                     
	WHERE a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

    --logging
	
	SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_EvoucherApplied WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_EvoucherApplied WITH (NOLOCK)
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