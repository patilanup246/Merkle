CREATE PROCEDURE [PreProcessing].[CBE_Delta_AdminUI_Updates]
(
    @userid                INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname              NVARCHAR(256)	
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER
	DECLARE @logmessage          NVARCHAR(MAX)
	DECLARE @now                 DATETIME

	DECLARE @dataimportlogid                  INTEGER
	DECLARE @dataimportdetailid               INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @dataimportlogid = DataImportLogID
	FROM   [Operations].[DataImportLog] a
	INNER JOIN [Reference].[OperationalStatus] b ON a.OperationalStatusID = b.OperationalStatusID
	INNER JOIN [Reference].[DataImportType] c ON c.DataImportTypeID = a.DataImportTypeID
	WHERE (b.Name = 'Processing' OR b.Name = 'Retrieving')
	AND   c.Name = 'CBE Admin UI Import'

    IF @dataimportlogid IS NULL OR @dataimportlogid !> 0
    BEGIN
	    SET @logmessage = 'No or invalid data import log reference.' + ISNULL(CAST(@dataimportdetailid AS NVARCHAR(256)),'NULL') 

	    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	                                          @logsource       = @spname,
			    							  @logmessage      = @logmessage,
				    						  @logmessagelevel = 'ERROR',
						    				  @messagetypecd   = NULL
        RETURN
    END	

	/**Customer Segment**/

	SELECT @dataimportdetailid = a.dataimportdetailid
	FROM  PreProcessing.CBE_CustomerSegment a
    INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
	INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
    WHERE c.DataImportLogID = @dataimportlogid
	AND   a.ProcessedInd = 0
	GROUP BY a.dataimportdetailid

    IF @dataimportdetailid IS NOT NULL AND @dataimportdetailid > 0
	BEGIN
	    EXEC [PreProcessing].[CBE_CustomerSegment_Insert] @userid             = @userid,
	                                                      @dataimportdetailid = @dataimportdetailid
    END

	SET @dataimportdetailid = NULL

	--Log end time

	SELECT @now = GETDATE()

    EXEC [Operations].[DataImportLog_Update] @userid                = @userid,
                                             @dataimportlogid       = @dataimportlogid,
                                             @operationalstatusname = 'Completed',
                                             @endtimeimport         = @now



	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN
END