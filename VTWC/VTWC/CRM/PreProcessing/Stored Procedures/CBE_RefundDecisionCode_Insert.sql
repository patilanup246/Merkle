﻿CREATE PROCEDURE [PreProcessing].[CBE_RefundDecisionCode_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	DECLARE @maxvalidityend         DATETIME

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

	SELECT @maxvalidityend = CAST([Reference].[Configuration_GetSetting] ('Operations','Maximum Validity End Date') AS DATETIME)

	IF @informationsourceid IS NULL OR @maxvalidityend IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid or @maxvalidityend; ' +
		                  '@informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') + 
						  '@maxvalidityend = '      + ISNULL(CAST(@maxvalidityend AS NVARCHAR(256)),'NULL') 
		
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END


    --It is possible for CBE to mutiple changes during a batch window. Only require the latest information. Create temporary table to avoid multiple
	--CTE being created for each step

	;WITH CTE_RefundDecisionCode AS (
	              SELECT 	[CBE_RefundDecisionCodeID],
							[ID],
							[Code],
							[Description],
							[Is_Rejection],
							[Date_Created],
							[Date_Modified],
							[Is_Active],
							ROW_NUMBER() OVER (partition by [Code] ORDER BY [Date_Modified] DESC
						                                                   ,[CBE_RefundDecisionCodeID] DESC) RANKING
                  FROM   [PreProcessing].[CBE_RefundDecisionCode]
				  WHERE  DataImportDetailID = @dataimportdetailid
	              AND    ProcessedInd = 0)

    SELECT *
	INTO #tmp_RefundDecisionCode
	FROM CTE_RefundDecisionCode
	WHERE Ranking = 1

	--Refund Reason Codes in [Reference].[RefundDecisionCode] but not in #tmp_RefundDecisionCode are to be treated as expired references

	UPDATE a
	SET  ValidityEndDate        = GETDATE()
	    ,ArchivedInd            = 1
		,LastModifiedDate       = GETDATE()
		,LastModifiedBy         = @userid
    FROM [Reference].[RefundDecisionCode] a
	LEFT JOIN #tmp_RefundDecisionCode     b ON a.Code = b.Code
	WHERE a.InformationSourceID = @informationsourceid
	AND   a.ArchivedInd = 0
	AND   b.Code IS NULL

	--Updates

	UPDATE a 
	SET Name               = b.Description,
		Description        = b.Description,
		LastModifiedDate   = GETDATE(),
		LastModifiedBy     = @userid,
		ArchivedInd        = CASE WHEN b.Is_Active = 1 THEN 0 ELSE 1 END,
		SourceCreatedDate  = b.Date_Created,
		SourceModifiedDate = b.Date_Modified,
		IsRejectionInd     = b.Is_Rejection,
		ValidityEndDate    = CASE WHEN b.Is_Active = 1 THEN @maxvalidityend ELSE b.Date_Modified END
	FROM #tmp_RefundDecisionCode b
	INNER JOIN [Reference].[RefundDecisionCode] a ON  a.Code                = b.Code
	                                              AND a.InformationSourceID = @informationsourceid
                                                  AND a.ArchivedInd = 0

	--Update processed records

    UPDATE b
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM [Reference].[RefundDecisionCode] a
	INNER JOIN PreProcessing.CBE_RefundDecisionCode b ON a.ExtReference         = b.code 
	                                                  AND a.InformationSourceID = @informationsourceid
    WHERE b.DataImportDetailID = @dataimportdetailid
	AND   b.ProcessedInd = 0

	--Now for new records

    INSERT INTO [Reference].[RefundDecisionCode]
        (Name,
		Description,
		CreatedDate,
		CreatedBy,
		LastModifiedDate,
		LastModifiedBy,
		ArchivedInd,
		SourceCreatedDate,
		SourceModifiedDate,
		InformationSourceId,
		Code,
		IsRejectionInd,
		ExtReference,
		ValidityStartDate,
		ValidityEndDate)
    SELECT  a.Description,
			a.Description,	
			GETDATE(),
			@userid,
			GETDATE(),
			@userid,
			CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END,
			a.Date_Created,
			a.Date_Modified,
			@informationsourceid,
			a.code,
			a.Is_Rejection,
			a.code,
			a.Date_Created,
			@maxvalidityend
    FROM #tmp_RefundDecisionCode a
	LEFT JOIN Reference.RefundDecisionCode b ON   b.Code = a.Code
	                                          AND b.InformationSourceID = @informationsourceid
											  AND b.ArchivedInd = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	WHERE b.code IS NULL 
    AND   a.Is_Active = 1
	
	--Update process records

    UPDATE b
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM [Reference].[RefundDecisionCode] a
	INNER JOIN PreProcessing.CBE_RefundDecisionCode b ON a.ExtReference         = b.code 
	                                                  AND a.InformationSourceID = @informationsourceid
    WHERE b.DataImportDetailID = @dataimportdetailid
	AND   b.ProcessedInd = 0

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_RefundDecisionCode
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_RefundDecisionCode
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