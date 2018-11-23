CREATE PROCEDURE [Staging].[STG_CVIResponseCustomer_Update]
(
	@userid                       INTEGER       = 0,   
	@informationsourceid          INTEGER,
	@customerid                   INTEGER,
	@sourcechangedate             DATETIME,
    @cviquestionid                INTEGER,
	@cviquestiongroupid           INTEGER,
	@cviquestionanswerid          INTEGER       = NULL,
	@response                     VARCHAR(4000) = NULL,
	@recordcount                  INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname                        NVARCHAR(256)
	DECLARE @logtimingidnew                INTEGER
	DECLARE @logmessage                    NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    SET @logmessage = '@userid = '                       +  ISNULL(CAST(@userid AS NVARCHAR(256)),'NULL') +
	                  ', @informationsourceid = '        +  ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
					  ', @customerid = '                 +  ISNULL(CAST(@customerid AS NVARCHAR(256)),'NULL') +
					  ', @sourcechangedate = '           +  ISNULL(CAST(@sourcechangedate AS NVARCHAR(256)),'NULL') +
					  ', @cviquestionid = '              +  ISNULL(CAST(@cviquestionid AS NVARCHAR(256)),'NULL') +
					  ', @cviquestiongroupid = '         +  ISNULL(CAST(@cviquestiongroupid AS NVARCHAR(256)),'NULL') + 
					  ', @cviquestionanswerid = '        +  ISNULL(CAST(@cviquestionanswerid AS NVARCHAR(256)),'NULL') + 
					  ', @response = '                   +  ISNULL(@response,'NULL')
	    
    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                  @logsource       = @spname,
									      @logmessage      = @logmessage,
										  @logmessagelevel = 'DEBUG',
									      @messagetypecd   = NULL

	--Is this the lastest change? If not return

	IF EXISTS (SELECT 1
	           FROM [Staging].[STG_CVIResponseCustomer] WITH (NOLOCK)
			   WHERE CustomerID          = @customerid
	           AND   CVIQuestionAnswerID = @cviquestionanswerid
			   AND   CVIQuestionGroupID  = @cviquestiongroupid
			   AND   ArchivedInd         = 0
			   AND   CreatedDate         >= @sourcechangedate)
	BEGIN
	    SET @recordcount = 0

		RETURN
	END

    --Has the same question been answered before for the same Question Group, if so archive previous answer before adding new one

	IF EXISTS (SELECT 1
	           FROM [Staging].[STG_CVIResponseCustomer] WITH (NOLOCK)
			   WHERE CustomerID          = @customerid
	           AND   CVIQuestionAnswerID = @cviquestionanswerid
			   AND   CVIQuestionGroupID  = @cviquestiongroupid
			   AND   ArchivedInd         = 0)
	BEGIN
	    UPDATE [Staging].[STG_CVIResponseCustomer]
		SET    LastModifiedDate = GETDATE()
		      ,LastModifiedBy   = @userid
		      ,ArchivedInd      = 1
		WHERE CustomerID          = @customerid
	    AND   CVIQuestionAnswerID = @cviquestionanswerid
		AND   CVIQuestionGroupID  = @cviquestiongroupid
		AND   ArchivedInd         = 0
	END

	--Add the new response

	INSERT INTO [Staging].[STG_CVIResponseCustomer]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[CustomerID]
           ,[CVIQuestionGroupID]
           ,[CVIQuestionAnswerID]
           ,[Response]
           ,[InformationSourceID])
     VALUES
           (NULL
           ,NULL
           ,@sourcechangedate
           ,@userid
           ,@sourcechangedate
           ,@userid
           ,0
           ,@customerid
           ,@cviquestiongroupid
           ,@cviquestionanswerid
           ,@response
           ,@informationsourceid)

    SELECT @recordcount = @@ROWCOUNT

	RETURN 
END