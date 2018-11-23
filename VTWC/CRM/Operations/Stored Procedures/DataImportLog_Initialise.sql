CREATE PROCEDURE [Operations].[DataImportLog_Initialise]
(
	@userid                   INTEGER        = 0,
	@dataimporttypeid         INTEGER        = NULL,
	@dataimporttypename       NVARCHAR(256)  = NULL,
	@returnid                 INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @operationalstatusid        INTEGER

	DECLARE @now                        DATETIME

	DECLARE @spname                     NVARCHAR(256)
	DECLARE @recordcount                INTEGER
	DECLARE @logtimingidnew             INTEGER
	DECLARE @logmessage                 NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @now = GETDATE()

	SELECT @operationalstatusid = OperationalStatusID
	FROM   [Reference].[OperationalStatus]
	WHERE  Name = 'Completed'
	AND    ArchivedInd = 0

    IF @dataimporttypename IS NOT NULL
	BEGIN
	    SELECT @dataimporttypeid = DataImportTypeID
		FROM   [Reference].[DataImportType]
		WHERE  [Name] = @dataimporttypename
    END

	IF NOT EXISTS (SELECT 1
	               FROM [Reference].[DataImportType]
		           WHERE [DataImportTypeID] = @dataimporttypeid)
	BEGIN
	    SET @logmessage = 'No or invalid @dataimporttypeid;' + 
		                  ' @dataimporttypeid   = ' + ISNULL(CAST(@dataimporttypeid AS NVARCHAR(256)),'NULL') +
						  ',@dataimporttypename = ' + ISNULL(@dataimporttypename,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    SET @returnid = -1

		RETURN
	END

    IF EXISTS (SELECT 1
               FROM  [Operations].[DataImportLog]
		   	   WHERE [DataImportTypeID] = @dataimporttypeid)
    BEGIN
	    SET @logmessage = 'Data Import Log has already been initilised' + 
		                  ' @dataimporttypeid   = ' + ISNULL(CAST(@dataimporttypeid AS NVARCHAR(256)),'NULL') +
						  ',@dataimporttypename = ' + ISNULL(@dataimporttypename,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Action'

	    SET @returnid = -2

		RETURN
    END

	
	INSERT INTO [Operations].[DataImportLog]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[DataImportTypeID]
           ,[OperationalStatusID]
		   ,[DateQueryStart]
		   ,[DateQueryEnd])
    SELECT Name
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
           ,DataImportTypeID
           ,@operationalstatusid
		   ,GETDATE()
		   ,GETDATE()
    FROM [Reference].[DataImportType]
	WHERE [DataImportTypeID] = @dataimporttypeid

	SELECT @returnid = SCOPE_IDENTITY()

	IF @returnid IS NULL
	BEGIN
	    SET @logmessage = 'Invalid @dataimportlogid;' + 
		                  ' @dataimportlogid   = ' + ISNULL(CAST(@returnid AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Result'

	    SET @returnid = -3

		RETURN
	END

--Log end time

    SET @recordcount = 1

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

    RETURN
END