CREATE PROCEDURE [Reference].[DataImporDefinition_Set]
(
	@userid                   INTEGER        = 0,
	@name                     NVARCHAR(256),
	@desc                     NVARCHAR(4000) = NULL,
	@archivedind              BIT            = 0,
	@dataimporttypeid         INTEGER        = NULL,
	@dataimporttypename       NVARCHAR(256)  = NULL,
	@querytemplate            NVARCHAR(256)  = NULL,
	@processingorder          INTEGER        = NULL,
	@maxbatchsize             INTEGER        = NULL,
	@destinationtable         NVARCHAR(256),
	@querydefinition          NVARCHAR(MAX)  = NULL,
	@typecode                 NVARCHAR(256)  = NULL,
	@subquerydefinition       NVARCHAR(MAX)  = NULL,
	@localcopyind             BIT            = 0,
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

	    RETURN 0
	END

	IF @querytemplate IS NULL AND @querydefinition IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid queryy supplied;' + 
		                  ' @querytemplate   = ' + ISNULL(@querytemplate,'NULL') +
						  ',@querydefinition = ' + ISNULL(@querydefinition,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -1
	END

    IF EXISTS (SELECT 1
               FROM [Reference].[DataImportDefinition]
		   	   WHERE [Name] = @name
			   AND   [DataImportTypeID] = @dataimporttypeid)
    BEGIN
        UPDATE [Reference].[DataImportDefinition]
        SET    [Description]        = @desc
              ,[LastModifiedDate]   = GETDATE()
              ,[LastModifiedBy]     = @userid
              ,[ArchivedInd]        = @archivedind
			  ,[QueryTemplate]      = @querytemplate
			  ,[ProcessingOrder]    = @processingorder
			  ,[MaxBatchSize]       = @maxbatchsize
			  ,[QueryDefinition]    = @querydefinition
			  ,[TypeCode]           = @typecode
			  ,[SubQueryDefinition] = @subquerydefinition
			  ,[LocalCopyInd]       = @localcopyind
        WHERE Name = @name
	END 
    ELSE
    BEGIN
        INSERT INTO [Reference].[DataImportDefinition]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[DataImportTypeID]
		   ,[QueryTemplate]
		   ,[ProcessingOrder]
		   ,[MaxBatchSize]
		   ,[DestinationTable]
		   ,[QueryDefinition]
		   ,[TypeCode]
		   ,[SubQueryDefinition]
		   ,[LocalCopyInd])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,@archivedind
		   ,@dataimporttypeid
		   ,@querytemplate
		   ,@processingorder
		   ,@maxbatchsize
		   ,@destinationtable
		   ,@querydefinition
		   ,@typecode
		   ,@subquerydefinition
		   ,@localcopyind)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = [DataImportDefinitionID]
	FROM   [Reference].[DataImportDefinition]
	WHERE  [Name] = @name
	AND    [DataImportTypeID] = @dataimporttypeid

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END