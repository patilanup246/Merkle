CREATE PROCEDURE [Operations].[DataImportLog_Update]
(
	@userid                   INTEGER = 0,
	@dataimportlogid          INTEGER,
	@operationalstatusname    NVARCHAR(256),
    @starttimeimport          DATETIME = NULL,
	@endtimeimport            DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @operationalstatusid        INTEGER

	DECLARE @spname                     NVARCHAR(256)
	DECLARE @logmessage                 NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	SELECT @operationalstatusid = OperationalStatusID
	FROM   [Reference].[OperationalStatus]
	WHERE  Name = @operationalstatusname
	AND    ArchivedInd = 0

	IF @operationalstatusid IS NULL
	BEGIN
	    SET @logmessage = 'Invalid look up values. ' + 
		                  ' @operationalstatusid = ' + ISNULL(CAST(@operationalstatusid AS NVARCHAR(256)),'NULL')

	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -1
	END


	IF NOT EXISTS (SELECT 1
	               FROM  [Operations].[DataImportLog]
		           WHERE [DataImportLogID] = @dataimportlogid)
	BEGIN
	    SET @logmessage = 'No or invalid @dataimportlogid. ' + 
		                  ' @dataimportlogid   = ' + ISNULL(CAST(@dataimportlogid AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR'

	    RETURN -2
	END

    UPDATE [Operations].[DataImportLog]
	SET    LastModifiedDate = GETDATE()
	      ,OperationalStatusID = @operationalstatusid
		  ,ImportStartTime = CASE WHEN @starttimeimport IS NULL THEN ImportStartTime ELSE @starttimeimport END
		  ,ImportEndTime   = CASE WHEN @endtimeimport IS NULL THEN ImportEndTime ELSE @endtimeimport END
	WHERE  DataImportLogID = @dataimportlogid

    RETURN
END