CREATE PROCEDURE [Reference].[DataImportType_Set]
(
	@userid                   INTEGER        = 0,
	@name                     NVARCHAR(256),
	@desc                     NVARCHAR(4000) = NULL,
	@archivedind              BIT            = 0,
	@informationsourceid      INTEGER        = NULL,
	@informationsourcename    NVARCHAR(256)  = NULL,
	@returnid                 INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER
	DECLARE @logmessage          NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT


    IF @informationsourcename IS NOT NULL
	BEGIN
	    SELECT @informationsourceid = InformationSourceID
		FROM   [Reference].[InformationSource]
		WHERE  Name = @informationsourcename
    END

	IF NOT EXISTS (SELECT 1
	               FROM [Reference].[InformationSource]
		           WHERE  InformationSourceID = @informationsourceid)
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid;' + 
		                  ' @informationsourceid   = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
						  ',@informationsourcename = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN 0
	END

    IF EXISTS (SELECT 1
               FROM [Reference].[DataImportType]
		   	   WHERE Name = @name)
    BEGIN
        UPDATE [Reference].[DataImportType]
        SET    [Description]         = @desc
              ,[LastModifiedDate]    = GETDATE()
              ,[LastModifiedBy]      = @userid
              ,[ArchivedInd]         = @archivedind
			  ,[InformationSourceID] = @informationsourceid
        WHERE Name = @name
	END 
    ELSE
    BEGIN
        INSERT INTO [Reference].[DataImportType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[InformationSourceID])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,@archivedind
		   ,@informationsourceid)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = DataImportTypeID
	FROM   [Reference].[DataImportType]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END