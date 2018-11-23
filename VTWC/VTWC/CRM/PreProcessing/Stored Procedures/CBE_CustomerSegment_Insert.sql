CREATE PROCEDURE [PreProcessing].[CBE_CustomerSegment_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid      INTEGER

	DECLARE @now                      DATETIME
	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)
	DECLARE @successcountimport       INTEGER = 0
	DECLARE @errorcountimport         INTEGER = 0

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @now = GETDATE()

	SELECT @recordcount = COUNT(1)
    FROM   PreProcessing.CBE_CustomerSegment
	WHERE  DataImportDetailID = @dataimportdetailid

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

    --Get configuration settings

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'CBE'

	IF @informationsourceid IS NULL
    BEGIN
	    SET @logmessage = 'No or invalid information source: ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') 
	    
	    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	                                          @logsource       = @spname,
			    							  @logmessage      = @logmessage,
				    						  @logmessagelevel = 'ERROR',
						    				  @messagetypecd   = 'Invalid Lookup'
        RETURN
    END	

	--Clear down staging table as data is only valid within new load

    TRUNCATE TABLE [Staging].[STG_AdminUI_CustomerSegment]

	--Insert new records

	INSERT INTO [Staging].[STG_AdminUI_CustomerSegment]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[EmailAddress]
           ,[CustomerReference]
           ,[CSGID]
           ,[CSGIDPrevious]
		   ,[CSLID])
    SELECT  [Name]
           ,[Description]
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,CASE WHEN [Is_Active_CSL] = 1 THEN 0 ELSE 1 END
           ,[Date_Created_CSL]
           ,[Date_Modified_CSL]
           ,[Email_Address]
           ,[Customer_Reference]
           ,[CSG_ID]
           ,[Previous_CSG_ID]
		   ,[CSL_ID]
    FROM  [PreProcessing].[CBE_CustomerSegment]
	WHERE DataImportDetailID = @dataimportdetailid
	AND   ProcessedInd = 0

	UPDATE a
	SET    [LastModifiedDateETL] = GETDATE() 
	      ,[ProcessedInd]        = 1
    FROM   [PreProcessing].[CBE_CustomerSegment] a
	INNER JOIN [Staging].[STG_AdminUI_CustomerSegment] b  ON  a.[CSG_ID]   = b.[CSGID]
	                                                      AND a.[CSL_ID] = b.[CSLID]
    WHERE DataImportDetailID = @dataimportdetailid
	AND   ProcessedInd = 0
	
	--logging
	
	SELECT @now = GETDATE()

	SELECT @recordcount = COUNT(1)
    FROM   PreProcessing.CBE_CustomerSegment
	WHERE  DataImportDetailID = @dataimportdetailid

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_CustomerSegment
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_CustomerSegment
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid
	
	
    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = NULL,
	                                            @endtimeimport         = @now,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = @successcountimport,
	                                            @errorcountimport      = @errorcountimport
 
	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END