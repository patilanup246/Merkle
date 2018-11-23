CREATE PROCEDURE [PreProcessing].[CBE_CVISalesTransaction_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid      INTEGER

	DECLARE @now						DATETIME
	DECLARE @spname						NVARCHAR(256)
	DECLARE @recordcount				INTEGER
	DECLARE @logtimingidnew				INTEGER
	DECLARE @logmessage					NVARCHAR(MAX)
	DECLARE @successcountimport			INTEGER = 0
	DECLARE @errorcountimport			INTEGER = 0

	DECLARE @CVISalesTransactionID		INTEGER
	DECLARE @Name						NVARCHAR(256) 
	DECLARE @Description				NVARCHAR(4000)
	DECLARE @CreatedDate				DATETIME 
	DECLARE @CreatedBy					INTEGER 
	DECLARE @LastModifiedDate			DATETIME
	DECLARE @LastModifiedBy				INTEGER 
	DECLARE @ArchivedInd				BIT 
	DECLARE @SalesTransactionID			INTEGER
	DECLARE @CVIQuestionID				INTEGER
	DECLARE @SourceCreatedDate			DATETIME
	DECLARE @SourceModifiedDate			DATETIME
	DECLARE @CVIAnswerID				INTEGER
	DECLARE @Answer						NVARCHAR(256)
	DECLARE @AnswerSupplemental			NVARCHAR(256)
	DECLARE @ExtReference				NVARCHAR(256)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @now = GETDATE()
	
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

	;WITH CTE_CBE_CVISalesTransactions AS (
                  select 
					j.SalesTransactionID,
					g.id,
					d.CVIQuestionID,
					e.CVIAnswerID,
					e.DisplayName,
					CAST(g.ID AS NVARCHAR(256)) AS 'ExtReference',
					j.CustomerID,
					i.CreatedDate,
					g.Transaction_Date_Time,
					i.LastModifiedDate,
					i.CVIResponseCustomerID,
					ROW_NUMBER() OVER (partition by i.CVIResponseCustomerID ORDER BY g.ID, ABS(DATEDIFF(ss,g.Transaction_Date_Time,i.CreatedDate)), g.CreatedDateETL DESC) RANKING
					FROM PreProcessing.CBE_SalesTransaction g
					INNER JOIN Staging.STG_SalesTransaction j ON j.ExtReference = CAST(g.ID AS NVARCHAR(256))
														AND j.InformationSourceID = @informationsourceid 
					INNER JOIN Staging.STG_CVIResponseCustomer i ON i.CustomerID = j.CustomerID
					LEFT JOIN Staging.STG_CVISalesTransaction h ON j.SalesTransactionID = h.SalesTransactionID
					inner join Reference.CVIQuestionGroup b ON i.CVIQuestionGroupID = b.CVIQuestionGroupID
					inner join Reference.CVIQuestionAnswer c ON c.CVIQuestionAnswerID = i.CVIQuestionAnswerID
					inner join Reference.CVIQuestion d ON d.CVIQuestionID  = b.CVIQuestionID
					inner join Reference.CVIAnswer e on e.CVIAnswerID = c.CVIAnswerID
					inner join Reference.CVIGroup f on f.CVIGroupID = b.CVIGroupID
					WHERE f.DisplayName = 'ReasonForTravel'
					--AND i.ArchivedInd = 0 /* need to include previous RFT */
					AND g.Transaction_Date_Time BETWEEN DATEADD(mi,-3,i.CreatedDate) AND DATEADD(mi,3,i.CreatedDate)
					AND h.CVISalesTransactionID IS NULL
					AND g.DataImportDetailID = @dataimportdetailid
					AND i.CreatedDate = i.LastModifiedDate
					AND g.ProcessedInd = 1
					)
					         
	INSERT INTO [Staging].[STG_CVISalesTransaction]
           (
		   Name	
		   ,Description	
		   ,CreatedDate	
		   ,CreatedBy	
		   ,LastModifiedDate	
		   ,LastModifiedBy	
		   ,ArchivedInd	
		   ,SalesTransactionID	
		   ,CVIQuestionID	
		   ,SourceCreatedDate	
		   ,SourceModifiedDate	
		   ,CVIAnswerID	
		   ,Answer	
		   ,AnswerSupplemental	
		   ,ExtReference	
		   ,InformationSourceID
			)
    SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,SalesTransactionID
           ,CVIQuestionID
		   ,CreatedDate
		   ,LastModifiedDate
		   ,CVIAnswerID
		   ,DisplayName
		   ,NULL
		   ,CAST(a.ID AS NVARCHAR(256))
           ,@informationsourceid
	FROM   CTE_CBE_CVISalesTransactions a
	WHERE  a.RANKING = 1
	
	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END