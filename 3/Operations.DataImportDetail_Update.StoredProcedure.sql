USE [CEM]
GO
/****** Object:  StoredProcedure [Operations].[DataImportDetail_Update]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Operations].[DataImportDetail_Update]
(
	@userid                   INTEGER = 0,
	@dataimportdetailid       INTEGER,
	@operationalstatusname    NVARCHAR(256),
	@starttimeextract         DATETIME = NULL,
	@endtimeextract           DATETIME = NULL,
	@starttimeimport          DATETIME = NULL,
	@endtimeimport            DATETIME = NULL,
	@totalcountimport         INTEGER  = NULL,
	@successcountimport       INTEGER  = NULL,
	@errorcountimport         INTEGER  = NULL
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

    IF @starttimeextract IS NULL
	    AND @endtimeextract IS NULL
		AND @starttimeimport IS NULL
		AND @endtimeimport IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid times;' + 
		                  ' @starttimeextract   = ' + ISNULL(CAST(@starttimeextract AS NVARCHAR(256)),'NULL') +
						  ' @endtimeextract     = ' + ISNULL(CAST(@endtimeextract AS NVARCHAR(256)),'NULL') +
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
    SET [LastModifiedDate]     = GETDATE()
       ,[LastModifiedBy]       = @userid
       ,[OperationalStatusID]  = @operationalstatusid
       ,[StartTimeExtract]     = CASE WHEN @starttimeextract IS NULL THEN [StartTimeExtract] ELSE @starttimeextract END
       ,[EndTimeExtract]       = CASE WHEN @endtimeextract IS NULL THEN [EndTimeExtract] ELSE @endtimeextract  END
       ,[StartTimeImport]      = CASE WHEN @starttimeimport IS NULL THEN [StartTimeImport]  ELSE @starttimeimport END
       ,[EndTimeImport]        = CASE WHEN @endtimeimport IS NULL THEN [EndTimeImport] ELSE @endtimeimport END
       ,[TotalCountImport]     = @totalcountimport
       ,[SuccessCountImport]   = @successcountimport
       ,[ErrorCountImport]     = @errorcountimport
    WHERE [DataImportDetailID] = @dataimportdetailid

	SELECT @recordcount = @@ROWCOUNT

    RETURN @recordcount
END





GO
