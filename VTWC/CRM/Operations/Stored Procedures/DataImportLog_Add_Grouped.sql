
CREATE PROCEDURE [Operations].[DataImportLog_Add_Grouped]
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

	DECLARE @datequerystart             DATETIME
	DECLARE @datequeryend               DATETIME
	

	DECLARE @baseimportfilename         NVARCHAR(256)
	DECLARE @outputfilepath             NVARCHAR(256)
	DECLARE @queryfilepath              NVARCHAR(256)
	DECLARE @now                        DATETIME

	DECLARE @spname                     NVARCHAR(256)
	DECLARE @recordcount                INTEGER
	DECLARE @logtimingidnew             INTEGER
	DECLARE @logmessage                 NVARCHAR(MAX)
	DECLARE @previousdataimportlogid	INTEGER
	DECLARE @previousdataimportdetailid	INTEGER
	DECLARE @previousdataimportcount	INTEGER
	DECLARE @previousdataimportdate		DATETIME
	DECLARE @parentdataimportlogid		INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	SELECT @now = GETDATE()

	SELECT @operationalstatusid = OperationalStatusID
	FROM   [Reference].[OperationalStatus]
	WHERE  Name = 'Retrieving'
	AND    ArchivedInd = 0

	SELECT @outputfilepath = [Reference].Configuration_GetSetting ('MSD Delta','Output File Path')
	SELECT @queryfilepath  = [Reference].Configuration_GetSetting ('MSD Delta','Query File Path')
	
	IF @operationalstatusid IS NULL OR
	   @outputfilepath      IS NULL OR
	   @queryfilepath       IS NULL
	BEGIN
	    SET @logmessage = 'Invalid look up values;' + 
		                  ' @operationalstatusid = ' + ISNULL(CAST(@operationalstatusid AS NVARCHAR(256)),'NULL') +
						  ', @outputfilepath = '     + ISNULL(@outputfilepath,'NULL') +
						  ', @queryfilepath = '      + ISNULL(@queryfilepath,'NULL')

	    
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


    SELECT @datequerystart = a.DateQuerystart,  @datequeryend = a.DateQueryend, @parentdataimportlogid = a.DataImportLogID
	FROM   [Operations].[DataImportLog] a,
	       [Reference].[OperationalStatus] b
	WHERE  a.OperationalStatusID = b.OperationalStatusID
	AND    a.DataImportTypeID = 1
	AND    b.Name = 'Retrieving'
		
   /* IF EXISTS (SELECT 1
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
        SET @logmessage = 'No @datequerystart available;' + 
		                  ' @dataimporttypeid   = ' + ISNULL(CAST(@dataimporttypeid AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -3
	END */ 
	
	/* INSERT INTO [Operations].[DataImportLog]
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
	END */ 

--Now add each definition to be processed

	SELECT @operationalstatusid = OperationalStatusID
	FROM   [Reference].[OperationalStatus]
	WHERE  Name = 'Pending'
	AND    ArchivedInd = 0

	SELECT @datequerystart = [DateQueryStart],
	       @datequeryend = [DateQueryEnd]
    FROM   [Operations].[DataImportLog]
	WHERE  DataImportLogID = @parentdataimportlogid   /* @dataimportlogid */

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

 
	
	SELECT @previousdataimportdetailid = a.dataimportdetailid, 
			@previousdataimportcount = a.TotalCountImport,
			@previousdataimportdate = a.StartTimePreprocessing
	FROM [Operations].dataimportdetail a
	WHERE a.DataImportLogID = ( SELECT DataImportLogID
							 FROM operations.dataimportlog b
							 WHERE b.DateQueryEnd = (SELECT MAX(a.DateQueryEnd)
								FROM [Operations].[DataImportLog] a,
									 [Reference].[OperationalStatus] b
								WHERE  a.OperationalStatusID = b.OperationalStatusID
								AND    a.DataImportTypeID = 1
								AND    b.Name IN ('Retrieved','Imported','Processing','Completed')))
	AND a.DataImportDefinitionID = (SELECT Dataimportdefinitionid
									FROM Reference.dataimportdefinition
									WHERE dataimporttypeid = @dataimporttypeid)

IF @previousdataimportcount = 0 
 OR @previousdataimportcount IS NULL
  BEGIN
	SET @datequerystart = @previousdataimportdate
  END

  IF EXISTS (SELECT 1 
			 FROM Operations.DataImportDetail
			 WHERE DataImportLogid = @parentdataimportlogid
			 AND NAME = (SELECT NAME
					    FROM   [Reference].[DataImportDefinition]
						WHERE  [DataImportTypeID] = @dataimporttypeid
						AND    ArchivedInd = 0))
	BEGIN
	    SET @logmessage = 'Invalid entry - Existing feed for MSD Regular Extract exists;' + 
		                  ' @dataimportlogid = ' + ISNULL(CAST(@dataimportlogid AS NVARCHAR(256)),'NULL') +
						  ', @dataimporttypeid = '     + ISNULL(CAST(@dataimporttypeid AS NVARCHAR(256)),'NULL')  
						  	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Existing Feed'

	    RETURN -6
	END



	INSERT INTO [Operations].[DataImportDetail]
           ([Name]
           ,[Description]
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
		   ,[StartTimePreprocessing]
		   ,[EndTimePreprocessing])
    SELECT  Name
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
           ,@parentdataimportlogid
           ,[DataImportDefinitionID]
           ,@operationalstatusid
           ,@outputfilepath + '\' + @baseimportfilename + REPLICATE('0', 4 - LEN([ProcessingOrder])) + CAST([ProcessingOrder] AS NVARCHAR(4)) + '_' + Name + '.csv'
           ,[ProcessingOrder]
		   ,[DestinationTable]
		   ,@queryfilepath + '\' + @baseimportfilename + REPLICATE('0', 4 - LEN([ProcessingOrder])) + CAST([ProcessingOrder] AS NVARCHAR(4)) + '_' + Name + '.xml'
	       ,REPLACE(REPLACE([QueryDefinition],'{DateQueryStart}',@datequerystart),'{DateQueryEnd}',@datequeryend)
		   ,@datequerystart
		   ,@datequeryend
    FROM   [Reference].[DataImportDefinition]
	WHERE  [DataImportTypeID] = @dataimporttypeid
	AND    ArchivedInd = 0
	
	SELECT @recordcount = @@ROWCOUNT

    RETURN @parentdataimportlogid
END