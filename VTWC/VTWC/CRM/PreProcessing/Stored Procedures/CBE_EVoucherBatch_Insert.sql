
CREATE PROCEDURE [PreProcessing].[CBE_EVoucherBatch_Insert]
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
	FROM PreProcessing.CBE_EVouchersBatch
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

	--Start Processing

    --Use CTE to avoid duplicates in the data from CBE and copy to local table to save on network traffic

	;WITH CTE_CBE_EVoucherBatch AS (
                  SELECT TOP 999999999
						 a.CBE_EVouchersBatchID
                        ,a.ID
                        ,a.Admin_Reference
                        ,a.Type
                        ,a.Description
                        ,a.Status
                        ,a.Request_Voucher_Value
                        ,a.Requestor
                        ,a.Requesting_Org
                        ,a.Recipient
                        ,a.Recipient_Org
                        ,a.Date_Created
                        ,a.Date_Expires
                        ,a.Date_Released
                        ,a.Date_Voided
                        ,a.Voided_Reason
                        ,a.Voided_By
                        ,a.Sales_Transaction_Reference
                        ,a.Usage_Rules_Desc
                        ,a.Date_Modified
                        ,a.Is_Active
	                    ,ROW_NUMBER() OVER (partition by ID ORDER BY a.Date_Modified DESC
						                                             , a.CBE_EVouchersBatchID DESC) RANKING
                 FROM  PreProcessing.CBE_EVouchersBatch a WITH (NOLOCK)
				 WHERE  a.DataImportDetailID = @dataimportdetailid
	             AND    a.ProcessedInd = 0)

    SELECT *
	INTO #tmp_CBE_EVoucherBatch
	FROM CTE_CBE_EVoucherBatch
	WHERE RANKING = 1

    --Update first

	UPDATE a
	SET Description               = b.Description
       ,LastModifiedDate          = GETDATE()
       ,ArchivedInd               = CASE WHEN b.Is_Active = 1 THEN 0 ELSE 1 END
       ,SourceModifiedDate        = b.Date_Modified
       ,AdminReference            = b.Admin_Reference
       ,StatusCd                  = b.Status
       ,Requestor                 = b.Requestor
       ,RequestingOrganisation    = b.Requesting_Org
       ,Receipient                = b.Recipient
       ,ReceipientOrganisation    = b.Recipient_Org
       ,ExpiryDate                = b.Date_Expires
       ,ReleaseDate               = b.Date_Released
       ,VoidedDate                = b.Date_Voided
       ,VoidedReason              = b.Voided_Reason
       ,SalesTransactionReference = b.Sales_Transaction_Reference
       ,UsageRule                 = b.Usage_Rules_Desc
	FROM Staging.STG_EVoucherBatch a
	INNER JOIN #tmp_CBE_EVoucherBatch b ON a.ExtReference = CAST(b.ID AS NVARCHAR(256))
    WHERE a.InformationSourceID = @informationsourceid

	--Update Processed records

	UPDATE a
	SET ProcessedInd = 1
	   ,LastModifiedDateETL = GETDATE()
    FROM PreProcessing.CBE_EVouchersBatch a
	INNER JOIN Staging.STG_EVoucherBatch b ON CAST(a.ID AS NVARCHAR(256)) = b.ExtReference
	WHERE a.DataImportDetailID = @dataimportdetailid
    AND    a.ProcessedInd = 0

	--New records

	INSERT INTO Staging.STG_EVoucherBatch
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
           ,AdminReference
           ,StatusCd
           ,VoucherValue
           ,Requestor
           ,RequestingOrganisation
           ,Receipient
           ,ReceipientOrganisation
           ,ExpiryDate
           ,ReleaseDate
           ,VoidedDate
           ,VoidedReason
           ,SalesTransactionReference
           ,UsageRule
           ,ExtReference)
     SELECT NULL
           ,a.Description
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
           ,Date_Created
           ,Date_Modified
           ,@informationsourceid
           ,a.Admin_Reference
           ,a.Status
           ,a.Request_Voucher_Value
           ,a.Requestor
           ,a.Requesting_Org
           ,a.Recipient
           ,a.Recipient_Org
           ,a.Date_Expires
           ,a.Date_Released
           ,a.Date_Voided
           ,a.Voided_Reason
           ,a.Sales_Transaction_Reference
           ,a.Usage_Rules_Desc
           ,CAST(a.ID AS NVARCHAR(256))
    FROM #tmp_CBE_EVoucherBatch a WITH (NOLOCK)
	LEFT JOIN Staging.STG_EVoucherBatch b WITH (NOLOCK) ON CAST(a.ID AS NVARCHAR(256)) = b.ExtReference
	                                          AND b.InformationSourceID = @informationsourceid
	WHERE b.EVoucherBatchID IS NULL

	--Update Processed records

	UPDATE a
	SET ProcessedInd = 1
	   ,LastModifiedDateETL = GETDATE()
    FROM PreProcessing.CBE_EVouchersBatch a
	INNER JOIN Staging.STG_EVoucherBatch b ON CAST(a.ID AS NVARCHAR(256)) = b.ExtReference
	WHERE a.DataImportDetailID = @dataimportdetailid
    AND    a.ProcessedInd = 0

    --logging
	
	SELECT @now = GETDATE()

    SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_EVouchersBatch WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_EVouchersBatch WITH (NOLOCK)
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid
	
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