CREATE PROCEDURE [Reference].[Configuration_Set]
(
	@userid         INTEGER = 0,
	@name           NVARCHAR(256),
	@desc           NVARCHAR(4000) = NULL,
	@typeid         INTEGER        = NULL,
	@typename       NVARCHAR(256)  = NULL,
	@setting        NVARCHAR(MAX),
	@archivedind    BIT            = 0,
	@returnid       INTEGER OUTPUT
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

    IF @typeid IS NULL
	BEGIN
	    SELECT @typeid = ConfigurationTypeID
		FROM   [Reference].[ConfigurationType]
		WHERE  Name = @typename
		AND    ArchivedInd = 0
    END

	
	IF NOT EXISTS (SELECT 1
	               FROM [Reference].[ConfigurationType]
				   WHERE  Name = @typename
		           AND    ArchivedInd = 0)
    BEGIN

	    SET @logmessage = 'No or invalid @typid; @typename = ' + ISNULL(@typename,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END  

    IF NOT EXISTS (SELECT 1
                   FROM [Reference].[Configuration]
		    	   WHERE Name = @name
				   AND   ConfigurationTypeID = @typeid)
    BEGIN
        INSERT INTO [Reference].[Configuration]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[ConfigurationTypeID]
		   ,[Setting])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
		   ,@userid
           ,@archivedind
		   ,@typeid
		   ,@setting)
    END
    ELSE
    BEGIN
        UPDATE [Reference].[Configuration]
	    SET    Description         = @desc,
		       ArchivedInd         = @archivedind,
			   Setting             = @setting,
	           LastModifiedBy      = @userid,
		       LastModifiedDate    = GETDATE()
	    WHERE  Name                = @name
		AND    ConfigurationTypeID = @typeid
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = ConfigurationTypeID
	FROM   [Reference].[ConfigurationType]
	WHERE  Name                = @name
	AND    ConfigurationTypeID = @typeid

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END