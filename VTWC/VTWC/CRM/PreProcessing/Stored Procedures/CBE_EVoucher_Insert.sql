

CREATE PROCEDURE [PreProcessing].[CBE_EVoucher_Insert]
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
	FROM   PreProcessing.CBE_EVoucher
    WHERE  DataImportDetailID = @dataimportdetailid
	

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

	--It may possible for CBE to multiple records for the same ID to be passed. Use CTE to avoid duplicates in the data from CBE

	;WITH CTE_CBE_EVouchers AS (
                  SELECT TOP 999999999 
						 CBE_EvoucherID
                        ,ID
                        ,Serial_Number
                        ,Code
                        ,EVB_ID
                        ,Type
                        ,Value
                        ,Remaining_Balance
                        ,Date_Purchased
                        ,Date_Claimed
                        ,Date_Voided
                        ,Voided_By
                        ,Date_Created
                        ,Date_Modified
                        ,Is_Active
                        ,Status
                        ,Is_Voided
                        ,Claimed_Cd_ID
                        ,Evoucher_Event
                        ,Voided_Reason
				        ,ROW_NUMBER() OVER (partition by ID
						                                 ORDER BY Date_Modified DESC
														         ,CBE_EvoucherID DESC) RANKING
                  FROM   PreProcessing.CBE_EVoucher WITH (NOLOCK)
				  WHERE  DataImportDetailID = @dataimportdetailid
	              AND    ProcessedInd = 0)

    SELECT *
	INTO #tmp_CBE_EVouchers
	FROM CTE_CBE_EVouchers
	WHERE RANKING = 1

	--Start Processing

	--Update existing voucher information

	UPDATE a
	SET SourceModifiedDate = b.Date_Modified
	   ,ArchivedInd        = CASE WHEN b.Is_Active = 1 THEN 0 ELSE 0 END
	   ,StatusCd           = b.Status
	   ,VoucherValue       = b.Value
	   ,RemainingValue     = b.Remaining_Balance
	   ,PurchaseDate       = b.Date_Purchased
	   ,ClaimDate          = b.Date_Claimed
	   ,VoidedDate         = b.Date_Voided
	   ,VoidedReason       = b.Voided_Reason
	   ,CustomerIDClaimed  = c.CustomerID
	   ,EvoucherEvent      = b.Evoucher_Event
    FROM Staging.STG_EVoucher    a
	INNER JOIN #tmp_CBE_EVouchers    b ON 'ID='      + ISNULL(CAST(b.ID AS NVARCHAR(256)),'NULL') + 
                                          ',EVB_ID=' + ISNULL(CAST(b.EVB_ID AS NVARCHAR(256)),'NULL') = a.ExtReference
    LEFT JOIN Staging.STG_KeyMapping c ON ISNULL(CAST(b.Claimed_Cd_ID AS NVARCHAR(256)),0) = c.CBECustomerID
	WHERE a.InformationSourceID = @informationsourceid

	--Update processed records

	UPDATE b
	SET ProcessedInd        = 1
	   ,LastModifiedDateETL = GETDATE()
    FROM Staging.STG_EVoucher a
	INNER JOIN PreProcessing.CBE_EVoucher b ON a.ExtReference = 'ID='     + ISNULL(CAST(b.ID AS NVARCHAR(256)),'NULL') + 
                                                                   ',EVB_ID=' + ISNULL(CAST(b.EVB_ID AS NVARCHAR(256)),'NULL')
	WHERE b.DataImportDetailID = @dataimportdetailid
	AND   b.ProcessedInd = 0
	AND   a.InformationSourceID = @informationsourceid

    --Add new records

	INSERT INTO Staging.STG_EVoucher
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
           ,StatusCd
           ,SerialNumber
           ,Code
           ,EVoucherTypeID
		   ,EVoucherBatchID
           ,VoucherValue
           ,RemainingValue
           ,PurchaseDate
           ,ClaimDate
           ,VoidedDate
           ,VoidedReason
           ,CustomerIDClaimed
           ,EvoucherEvent
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
           ,a.Status
		   ,a.Serial_Number
		   ,a.Code
		   ,b.EVoucherTypeID
		   ,d.EVoucherBatchID
		   ,a.Value
		   ,a.Remaining_Balance
           ,a.Date_Purchased
		   ,a.Date_Claimed
		   ,a.Date_Voided
		   ,a.Voided_Reason
		   ,c.CustomerID
		   ,a.Evoucher_Event
		   ,'ID='   + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
           ',EVB_ID='   + ISNULL(CAST(a.EVB_ID AS NVARCHAR(256)),'NULL')
    FROM #tmp_CBE_EVouchers a WITH (NOLOCK)
	LEFT JOIN Reference.EVoucherType		b WITH (NOLOCK) ON a.Type = b.ExtReference
	                                         AND a.Date_Created BETWEEN b.ValidityStartDate AND b.ValidityEndDate
	LEFT JOIN  Staging.STG_KeyMapping		c WITH (NOLOCK) ON a.Claimed_Cd_ID = c.CBECustomerID
	INNER JOIN  Staging.STG_EVoucherBatch	d WITH (NOLOCK) ON d.ExtReference = CAST(a.EVB_ID AS NVARCHAR(256))
                                              AND d.InformationSourceID = @informationsourceid
    LEFT JOIN  Staging.STG_EVoucher			e WITH (NOLOCK) ON e.ExtReference = 'ID='   + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
                                                                   ',EVB_ID='   + ISNULL(CAST(a.EVB_ID AS NVARCHAR(256)),'NULL')
	                                          AND e.InformationSourceID = @informationsourceid
    WHERE e.ExtReference IS NULL
	AND   a.RANKING = 1  

    --Update process records

	UPDATE b
	SET ProcessedInd = 1
	   ,LastModifiedDateETL = GETDATE()
    FROM Staging.STG_EVoucher a
	INNER JOIN PreProcessing.CBE_EVoucher b ON a.ExtReference = 'ID='   + ISNULL(CAST(b.ID AS NVARCHAR(256)),'NULL') + 
                                                                   ',EVB_ID='   + ISNULL(CAST(b.EVB_ID AS NVARCHAR(256)),'NULL')
                                               AND a.InformationSourceID = @informationsourceid
	WHERE b.DataImportDetailID = @dataimportdetailid
	AND   b.ProcessedInd = 0

    --logging
	
	SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_EVoucher WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_EVoucher WITH (NOLOCK)
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