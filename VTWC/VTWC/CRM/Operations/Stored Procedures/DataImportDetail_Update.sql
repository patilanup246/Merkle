CREATE PROCEDURE [Operations].[DataImportDetail_Update]
(
	@userid						INTEGER = 0,
	@dataimportdetailid			INTEGER,
	@operationalstatusname		NVARCHAR(256),
	@importfilename				NVARCHAR(256) = null,
	@starttimepreprocessing		DATETIME = NULL,
	@endtimepreprocessing		DATETIME = NULL,
	@starttimeimport			DATETIME = NULL,
	@endtimeimport				DATETIME = NULL,
	@totalCountPreprocessing	INTEGER = NULL,
	@successCountPreprocessing	INTEGER = NULL,
	@errorCountPreprocessing	INTEGER = NULL,
	@totalcountimport			INTEGER = NULL,
	@successcountimport			INTEGER = NULL,
	@errorcountimport			INTEGER = NULL
)

AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @operationalstatusid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	SELECT @operationalstatusid = OperationalStatusID
	FROM   [Reference].[OperationalStatus]
	WHERE  Name = @operationalstatusname
	AND    ArchivedInd = 0

	IF @operationalstatusid IS NULL
	BEGIN
	    SET @logmessage = 'Invalid @operationalstatusid;' + 
		                  ' @operationalstatusid   = ' + ISNULL(CAST(@operationalstatusid AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -1
	END

	IF NOT EXISTS (SELECT 1
	               FROM  [Operations].[DataImportDetail]
		           WHERE [DataImportDetailID] = @dataimportdetailid
				   AND   [ArchivedInd] = 0)
	BEGIN
	    SET @logmessage = 'No or invalid @dataimporttypeid;' + 
		                  ' @dataimporttypeid   = ' + ISNULL(CAST(@dataimportdetailid AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -2
	END

    IF @starttimepreprocessing IS NULL
	    AND @endtimepreprocessing IS NULL
		AND @starttimeimport IS NULL
		AND @endtimeimport IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid times;' + 
		                  ' @starttimepreprocessing   = ' + ISNULL(CAST(@starttimepreprocessing AS NVARCHAR(256)),'NULL') +
						  ' @endtimepreprocessing     = ' + ISNULL(CAST(@endtimepreprocessing AS NVARCHAR(256)),'NULL') +
						  ' @starttimeimport    = ' + ISNULL(CAST(@starttimeimport AS NVARCHAR(256)),'NULL') +
						  ' @endtimeimport      = ' + ISNULL(CAST(@endtimeimport AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -3
	END

	UPDATE [Operations].[DataImportDetail]
    SET	[LastModifiedDate]				= GETDATE()
		,[LastModifiedBy]				= @userid
		,[OperationalStatusID]			= @operationalstatusid
		,[ImportFileName]				= @importfilename
	   	,[starttimepreprocessing]		= CASE WHEN @starttimepreprocessing IS NULL THEN [starttimepreprocessing] ELSE @starttimepreprocessing END
		,[endtimepreprocessing]			= CASE WHEN @endtimepreprocessing IS NULL THEN [endtimepreprocessing] ELSE @endtimepreprocessing END
		,[StartTimeImport]				= CASE WHEN @starttimeimport IS NULL THEN [StartTimeImport]  ELSE @starttimeimport END
		,[EndTimeImport]				= CASE WHEN @endtimeimport IS NULL THEN [EndTimeImport] ELSE @endtimeimport END
		,[TotalCountPreprocessing]		= CASE WHEN @TotalCountPreprocessing IS NULL THEN [TotalCountPreprocessing] ELSE @TotalCountPreprocessing END 
		,[SuccessCountPreprocessing]	= CASE WHEN @SuccessCountPreprocessing IS NULL THEN [SuccessCountPreprocessing] ELSE @SuccessCountPreprocessing END  
		,[ErrorCountPreprocessing]		= CASE WHEN @ErrorCountPreprocessing IS NULL THEN [ErrorCountPreprocessing] ELSE @ErrorCountPreprocessing END   
		,[TotalCountImport]				= CASE WHEN @totalcountimport IS NULL THEN [TotalCountImport] ELSE @totalcountimport END    
		,[SuccessCountImport]			= CASE WHEN @successcountimport IS NULL THEN [SuccessCountImport] ELSE @successcountimport END   
		,[ErrorCountImport]				= CASE WHEN @errorcountimport IS NULL THEN [ErrorCountImport] ELSE @errorcountimport END    
    WHERE [DataImportDetailID]			= @dataimportdetailid

	SELECT @recordcount = @@ROWCOUNT

    RETURN @recordcount
END
GO

