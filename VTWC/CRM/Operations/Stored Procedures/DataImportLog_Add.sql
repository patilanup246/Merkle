


CREATE PROCEDURE [Operations].[DataImportLog_Add]
(
	@userid                   INTEGER = 0,
	@dataimporttypeid         INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @operationalstatusid        INTEGER
	DECLARE @dataimportlogid            INTEGER

	DECLARE @dataimportlogpreviousid    INTEGER

	DECLARE @datequerystart             DATETIME = GETDATE()
	DECLARE @datequeryend               DATETIME
	
	DECLARE @defintionname              NVARCHAR(256)
	DECLARE @querydefinition            NVARCHAR(MAX)
	DECLARE @subquerydefinition         NVARCHAR(MAX)
	DECLARE @sql                        NVARCHAR(MAX)
	DECLARE @parmlist                   NVARCHAR(MAX) = '@querylist NVARCHAR(MAX) OUTPUT'
	DECLARE @querylist                  NVARCHAR(MAX)

	DECLARE @baseimportfilename         NVARCHAR(256)
	DECLARE @outputfilepath             NVARCHAR(256)
	DECLARE @fileoutputpath             NVARCHAR(256)
	DECLARE @queryfilepath              NVARCHAR(256)
	DECLARE @filequerypath              NVARCHAR(256)
	DECLARE @processingorder            NVARCHAR(256)

	DECLARE @dataimportdefinitionid      INTEGER
	DECLARE @destinationtable            NVARCHAR(256)
	DECLARE @typecode                    NVARCHAR(256)

	DECLARE @now                        DATETIME

	DECLARE @spname                     NVARCHAR(256)
	DECLARE @recordcount                INTEGER
	DECLARE @logtimingidnew             INTEGER
	DECLARE @logmessage                 NVARCHAR(MAX)
	DECLARE @previousdataimportlogid	INTEGER
	DECLARE @datequerystartoverride		DATETIME

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	SELECT @now = GETDATE()

	SELECT @operationalstatusid = OperationalStatusID
	FROM   [Reference].[OperationalStatus]
	WHERE  Name = 'Retrieving'
	AND    ArchivedInd = 0
	
	IF @operationalstatusid IS NULL 
	BEGIN
	    SET @logmessage = 'Invalid look up values;' + 
		                  ' @operationalstatusid = ' + ISNULL(CAST(@operationalstatusid AS NVARCHAR(256)),'NULL') 

	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -1
	END
	
	IF NOT EXISTS (SELECT 1
	               FROM  [Reference].[DataImportType]
		           WHERE [DataImportTypeID] = @dataimporttypeid
				   AND   [ArchivedInd] = 0)
	BEGIN
	    SET @logmessage = 'No or invalid @dataimporttypeid;' + 
		                  ' @dataimporttypeid   = ' + ISNULL(CAST(@dataimporttypeid AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -2
	END

	
--Get previous entry for required DataImport Type to get the previous run date

-- Capture dataimportlogid of last MSD_Regular_Extract

   SELECT @previousdataimportlogid = max(a.DataImportLogID)
	FROM   [Operations].[DataImportLog] a,
	       [Reference].[OperationalStatus] b
	WHERE  a.OperationalStatusID = b.OperationalStatusID
	AND    a.DataImportTypeID = @dataimporttypeid
	AND    b.Name IN ('Retrieved','Imported','Processing','Completed')
	AND	   a.DateQueryEnd = @datequerystart

-- Check that we don't already have an process running 

	IF EXISTS (SELECT 1
	           FROM [Operations].[DataImportLog] a,
	                [Reference].[OperationalStatus] b
	           WHERE  a.OperationalStatusID = b.OperationalStatusID
	           AND    a.DataImportTypeID = @dataimporttypeid
	           AND    b.Name IN ('Pending','Retrieving'))
    BEGIN
	    SET @datequerystart = NULL
	END

	IF @datequerystart IS NULL
	BEGIN
        SET @logmessage = 'No @datequerystart available; Previous process still running' + 
		                  ' @dataimporttypeid   = ' + ISNULL(CAST(@dataimporttypeid AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -3
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
		   ,@datequerystart
		   ,GETDATE()
    FROM [Reference].[DataImportType]
	WHERE [DataImportTypeID] = @dataimporttypeid

	SELECT @dataimportlogid = SCOPE_IDENTITY()

	IF @dataimportlogid IS NULL
	BEGIN
	    SET @logmessage = 'Invalid @dataimportlogid;' + 
		                  ' @dataimportlogid   = ' + ISNULL(CAST(@dataimportlogid AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -4
	END

--Now add each definition to be processed

	SELECT @operationalstatusid = OperationalStatusID
	FROM   [Reference].[OperationalStatus]
	WHERE  Name = 'Pending'
	AND    ArchivedInd = 0

	SELECT @datequerystart = [DateQueryStart],
	       @datequeryend   = [DateQueryEnd]
    FROM   [Operations].[DataImportLog]
	WHERE  DataImportLogID = @dataimportlogid

	SELECT @baseimportfilename = CAST(YEAR(@now) AS NVARCHAR(256)) + 
	                             REPLICATE('0', 2 - LEN(DATEPART(MONTH,@now)))  + CAST(DATEPART(MONTH,@now)AS NVARCHAR(2)) + 
								 CAST(DAY(@now) AS NVARCHAR(8)) + '_' +
								 REPLICATE('0', 2 - LEN(DATEPART(HOUR,@now)))   + CAST(DATEPART(HOUR,@now)  AS NVARCHAR(2)) + 
                                 REPLICATE('0', 2 - LEN(DATEPART(MINUTE,@now))) + CAST(DATEPART(MINUTE,@now) AS NVARCHAR(2)) +
                                 REPLICATE('0', 2 - LEN(DATEPART(SECOND,@now))) + CAST(DATEPART(SECOND,@now) AS NVARCHAR(2)) + '_'

    
	IF @operationalstatusid IS NULL OR
	   @datequerystart IS NULL OR
	   @datequeryend IS NULL OR
	   @baseimportfilename IS NULL
	BEGIN
	    SET @logmessage = 'Invalid parameters, all should be not null;' + 
		                  ' @operationalstatusid = ' + ISNULL(CAST(@operationalstatusid AS NVARCHAR(256)),'NULL') +
						  ', @datequerystart = '     + ISNULL(CAST(@datequerystart AS NVARCHAR(256)),'NULL') + 
						  ', @datequeryend = '       + ISNULL(CAST(@datequeryend AS NVARCHAR(256)),'NULL') + 
						  ', @baseimportfilename = ' + ISNULL(@baseimportfilename,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -5
	END

	DECLARE DataImportDefinitions CURSOR READ_ONLY
    FOR
        SELECT [Name]
		      ,[DataImportDefinitionID]
		      ,@outputfilepath + '\' + @baseimportfilename + REPLICATE('0', 4 - LEN([ProcessingOrder])) + CAST([ProcessingOrder] AS NVARCHAR(4)) + '_' + Name + '.csv'
			  ,[ProcessingOrder]
		      ,[DestinationTable]
		      ,@queryfilepath + '\' + @baseimportfilename + REPLICATE('0', 4 - LEN([ProcessingOrder])) + CAST([ProcessingOrder] AS NVARCHAR(4)) + '_' + Name + '.xml'
			  ,[TypeCode]
			  ,'SELECT @querylist = ' + [SubQueryDefinition]
			  ,[QueryDefinition]
	    FROM   [Reference].[DataImportDefinition]
	    WHERE  [DataImportTypeID] = @dataimporttypeid
	    AND    ArchivedInd = 0

		OPEN DataImportDefinitions

	    FETCH NEXT FROM DataImportDefinitions
		    INTO @defintionname
			    ,@dataimportdefinitionid
			    ,@fileoutputpath
			    ,@processingorder
				,@destinationtable
				,@filequerypath
				,@typecode
				,@subquerydefinition
				,@querydefinition

	    WHILE @@FETCH_STATUS = 0
        BEGIN

		    IF @typecode = 'Simple XML'
			BEGIN
			    SELECT @querydefinition	= REPLACE(REPLACE(@querydefinition,'{DateQueryStart}',@datequerystartoverride),'{DateQueryEnd}',@datequeryend)
			END
			ELSE IF @typecode = 'Complex XML'
			BEGIN
			    EXEC sp_Executesql @sql       = @subquerydefinition,
                                   @params    = @parmlist,
				                   @querylist = @querylist OUTPUT

                SELECT @querydefinition	= REPLACE(@querydefinition,'{querylist}',@querylist)

            END
			ELSE IF @typecode = 'File'
			BEGIN
			    SET @querydefinition = NULL
            END
			
	INSERT INTO [Operations].[DataImportDetail]
           ([Name]
          ,[CreatedDate]
          ,[CreatedBy]
          ,[LastModifiedDate]
          ,[LastModifiedBy]
          ,[ArchivedInd]
          ,[DataImportLogID]
          ,[DataImportDefinitionID]
          ,[OperationalStatusID]
          ,[ImportFileName]
          ,[ProcessingOrder]
		  ,[DestinationTable]
	      ,[QueryFileName]
	      ,[QueryDefinition]
		  ,[StartTimePreprocessing])
	VALUES (
			@defintionname
				,GETDATE()
				,@userid
				,GETDATE()
				,@userid
				,0
				,@dataimportlogid
				,@dataimportdefinitionid
				,@operationalstatusid
				,' '
				,@processingorder
				,@destinationtable
				,@filequerypath
				,@querydefinition
				,@datequerystart)

				FETCH NEXT FROM DataImportDefinitions
		        INTO @defintionname
			        ,@dataimportdefinitionid
			        ,@fileoutputpath
			        ,@processingorder
				    ,@destinationtable
			    	,@filequerypath
		    		,@typecode
		    		,@subquerydefinition
		    		,@querydefinition
	
	END
	
	CLOSE DataImportDefinitions
	
 DEALLOCATE DataImportDefinitions
 
	SELECT @recordcount = @@ROWCOUNT
    RETURN @dataimportlogid
END