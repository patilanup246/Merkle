USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_CVISalesTransaction_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_CVISalesTransaction_Insert]
(
    @userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid      INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    --Get Reference Information

	SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = [Reference].[Configuration_GetSetting] ('Migration','MSD Source')

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END

	--Process the data

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
		   ,a.CreatedOn
		   ,a.ModifiedOn
           ,a.out_answer
           ,a.out_quicksearch2
           ,CAST(a.out_additionalcustomerdetailId AS NVARCHAR(256))
           ,@informationsourceid
    FROM  [Migration].[MSD_AdditionalCustomerDetail] a
	INNER JOIN [Staging].[STG_SalesTransaction] b ON CAST(a.out_bookingaddcustomerdetailsId AS NVARCHAR(256)) = b.ExtReference
	INNER JOIN [Reference].[CVIQuestion] c ON a.out_question = c.ExtReference
	LEFT JOIN  [Staging].[STG_CVISalesTransaction] d ON b.SalesTransactionID = d.SalesTransactionID AND c.CVIQuestionID = d.CVIQuestionID
	WHERE d.SalesTransactionID IS NULL

	SELECT @recordcount = @@ROWCOUNT

	UPDATE a
	SET ProcessedInd = 1
	FROM [Migration].[MSD_AdditionalCustomerDetail] a,
	     [Staging].[STG_CVISalesTransaction] b,
		 [Reference].[CVIQuestion] c
    WHERE CAST(a.out_bookingaddcustomerdetailsId AS NVARCHAR(256)) = b.ExtReference
	AND   a.out_question = c.ExtReference


	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT    
	RETURN
END










GO
