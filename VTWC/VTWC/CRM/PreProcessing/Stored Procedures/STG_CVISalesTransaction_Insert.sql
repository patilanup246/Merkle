
CREATE PROCEDURE [PreProcessing].[STG_CVISalesTransaction_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT


    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Delta - MSD'

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END

    SELECT @now = GETDATE()

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL


    INSERT INTO [Staging].[STG_CVISalesTransaction]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[CVIQuestionID]
		   ,[SalesTransactionID]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[Answer]
           ,[AnswerSupplemental]
           ,[ExtReference]
           ,[InformationSourceID])
     SELECT GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,c.CVIQuestionID
		   ,b.SalesTransactionID
		   ,Staging.SetUKTime(a.CreatedOn)
		   ,Staging.SetUKTime(a.ModifiedOn)
           ,a.out_answer
           ,a.out_quicksearch2
           ,CAST(a.out_additionalcustomerdetailId AS NVARCHAR(256))
           ,@informationsourceid
    FROM  [PreProcessing].[MSD_AdditionalCustomerDetail] a
	INNER JOIN [Staging].[STG_SalesTransaction] b ON CAST(a.out_bookingaddcustomerdetailsId AS NVARCHAR(256)) = b.ExtReference
	INNER JOIN [Reference].[CVIQuestion] c ON a.out_question = c.ExtReference
	LEFT JOIN  [Staging].[STG_CVISalesTransaction] d ON b.SalesTransactionID = d.SalesTransactionID AND c.CVIQuestionID = d.CVIQuestionID
	WHERE d.SalesTransactionID IS NULL
	AND   a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

	UPDATE a
	SET  ProcessedInd = 1
	FROM [PreProcessing].[MSD_AdditionalCustomerDetail] a 
	INNER JOIN  [Staging].[STG_CVISalesTransaction] b ON b.ExtReference = CAST(a.out_additionalcustomerdetailId AS NVARCHAR(256))
	AND   a.DataImportDetailID = @dataimportdetailid
		
	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[MSD_AdditionalCustomerDetail]
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[MSD_AdditionalCustomerDetail]
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport


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