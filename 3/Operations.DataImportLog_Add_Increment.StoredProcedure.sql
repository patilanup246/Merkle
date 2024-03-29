USE [CEM]
GO
/****** Object:  StoredProcedure [Operations].[DataImportLog_Add_Increment]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Operations].[DataImportLog_Add_Increment]
(
	@userid                   INTEGER = 0,
	@dataimporttypeid         INTEGER,
	 @dateparttype	INT,
	 @dateinc	INT

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

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

--	SELECT @now = GETDATE() make query end date instead, see below

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
	PRINT @logmessage
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -2
	END

	
--Get previous entry for required DataImport Type to get the previous run date

    SELECT @datequerystart = MAX(a.DateQueryEnd)
	FROM   [Operations].[DataImportLog] a,
	       [Reference].[OperationalStatus] b
	WHERE  a.OperationalStatusID = b.OperationalStatusID
	AND    a.DataImportTypeID = @dataimporttypeid
	AND    b.Name IN ('Retrieved','Imported','Processing','Completed')

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
        SET @logmessage = 'No @datequerystart available;' + 
		                  ' @dataimporttypeid   = ' + ISNULL(CAST(@dataimporttypeid AS NVARCHAR(256)),'NULL')
	PRINT @logmessage
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -3
	END


IF @dateparttype = 1 SET @datequeryend = DATEADD(hour,@dateinc,@datequerystart)
IF @dateparttype = 2 SET @datequeryend = DATEADD(day,@dateinc,@datequerystart)

SET  @now = @datequeryend

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
		   ,@datequeryend
    FROM [Reference].[DataImportType]
	WHERE [DataImportTypeID] = @dataimporttypeid

	SELECT @dataimportlogid = SCOPE_IDENTITY()

	IF @dataimportlogid IS NULL
	BEGIN
	    SET @logmessage = 'Invalid @dataimportlogid;' + 
		                  ' @dataimportlogid   = ' + ISNULL(CAST(@dataimportlogid AS NVARCHAR(256)),'NULL')
	PRINT    @logmessage 

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
	PRINT @logmessage	    

		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

	    RETURN -5
	END

  IF @dataimporttypeid  != 2
   BEGIN
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
	       ,[QueryDefinition])
    SELECT  Name
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
           ,@dataimportlogid
           ,[DataImportDefinitionID]
           ,@operationalstatusid
           ,@outputfilepath + '\' + @baseimportfilename + REPLICATE('0', 4 - LEN([ProcessingOrder])) + CAST([ProcessingOrder] AS NVARCHAR(4)) + '_' + Name + '.csv'
           ,[ProcessingOrder]
		   ,[DestinationTable]
		   ,@queryfilepath + '\' + @baseimportfilename + REPLICATE('0', 4 - LEN([ProcessingOrder])) + CAST([ProcessingOrder] AS NVARCHAR(4)) + '_' + Name + '.xml'
	       ,REPLACE(REPLACE([QueryDefinition],'{DateQueryStart}',@datequerystart),'{DateQueryEnd}',@datequeryend)
    FROM   [Reference].[DataImportDefinition]
	WHERE  [DataImportTypeID] = @dataimporttypeid
	AND    ArchivedInd = 0
	
	SELECT @recordcount = @@ROWCOUNT
   END

    RETURN @dataimportlogid
END



GO
