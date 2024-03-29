USE [CEM]
GO
/****** Object:  StoredProcedure [api_customer].[setCVIIndividualResponse]    Script Date: 24/07/2018 14:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_customer].[setCVIIndividualResponse]
	@userid int = NULL,
	@GroupName varchar(256) = NULL,
	@QuestionId int = NULL,
	@AnswerName varchar(256) = NULL,
	@Response varchar(4000) = NULL,
	@EncryptedEmail varchar(max),
	@Visible bit = NULL
  AS 
    
    set nocount on;

    DECLARE @RowCount int = 0	
    DECLARE @ErrMsg varchar(max)
	DECLARE @QuestionName varchar(256) = NULL
	DECLARE @GroupId int = NULL
	DECLARE @AnswerId int = NULL
	DECLARE @QuestionGroupId int = NULL
	DECLARE @QuestionAnswerId int = NULL
	DECLARE @CustomerXEmail int = 0
	DECLARE @IndividualId int = NULL
	DECLARE @InformationSource int = 1
	DECLARE @CVIResponseIndividualId int = NULL

	-- Check if @userid is NULL
	IF @userid IS NULL 
	BEGIN
		SET @ErrMsg = 'User Id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @Visible is NULL
	IF @Visible IS NULL 
	BEGIN
		SET @ErrMsg = 'Visible cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @GroupName is NULL
	IF @GroupName IS NULL 
	BEGIN
		SET @ErrMsg = 'Group name cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @QuestionId is NULL
	IF @QuestionId IS NULL 
	BEGIN
		SET @ErrMsg = 'Question id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @AnswerName is NULL
	IF @AnswerName IS NULL 
	BEGIN
		SET @ErrMsg = 'Answer name cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @EncryptedEmail is NULL
	IF @EncryptedEmail IS NULL 
	BEGIN
		SET @ErrMsg = 'Encrypted email cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	--Get Individual Id
	SELECT @CustomerXEmail = COUNT(1) 
    FROM api_customer.ContactInformation ci WITH (NOLOCK) 
    WHERE ci.EncryptedEmail = @EncryptedEmail

	IF @CustomerXEmail > 1
    BEGIN
        SET @ErrMsg = 'Unable to modify the specified email. Multiple Customers per email.';
        THROW 51403, @ErrMsg,1
    END   
           
    SELECT @IndividualId = IndividualID
    FROM Staging.STG_ElectronicAddress ea WITH (NOLOCK)
    WHERE ea.EncrytpedAddress = @encryptedEmail AND 
	      ea.ArchivedInd = 0 AND 
	      ea.PrimaryInd = 1 

    IF @@ROWCOUNT = 0
    BEGIN
		SET @ErrMsg = 'Unable to find an Individual for the specified encrypted Email ('+@encryptedEmail+')';
        THROW 51403, @ErrMsg,1
    END 
	
	--Get Group Id
	SELECT @GroupId = CVIGroupID
	FROM Reference.CVIGroup WITH (NOLOCK)
	WHERE DisplayName = @GroupName	          

	-- Check if @GroupId is NULL
	IF @GroupId IS NULL 
	BEGIN
		SET @ErrMsg = 'Group (' + @GroupName + ') does not exist';
		THROW 90508, @ErrMsg,1
	END

	--Get @QuestionName
	SELECT @QuestionName = DisplayName
	FROM Reference.CVIQuestion WITH (NOLOCK)
	WHERE CVIQuestionID = @QuestionId

	--Check Question existance
	IF @QuestionName IS NULL
	BEGIN
		SET @ErrMsg = 'Question (' + CAST(@QuestionID as varchar) + ') does not exist';
		THROW 90508, @ErrMsg,1
	END
	
	--Get Answer Id			
	SELECT @AnswerId = CVIAnswerID
	FROM Reference.CVIAnswer WITH (NOLOCK)
	WHERE DisplayName = @AnswerName	          

	-- Check if @AnswerId is NULL
	IF @AnswerId IS NULL 
	BEGIN
		SET @ErrMsg = 'Answer (' + @AnswerName + ') does not exist';
		THROW 90508, @ErrMsg,1
	END

	--Get QuestionGroup Id
	SELECT @QuestionGroupId = CVIQuestionGroupID
	FROM Reference.CVIQuestionGroup WITH (NOLOCK)
	WHERE CVIQuestionID = @QuestionId AND CVIGroupID = @GroupId	   

	-- Check if @QuestionAnswerId is NULL
	IF @QuestionGroupId IS NULL 
	BEGIN
		SET @ErrMsg = 'Question (' + @QuestionName + ') is not associated with Group (' + @GroupName + ')';
		THROW 90508, @ErrMsg,1
	END

	--Get QuestionAnswer Id
	SELECT @QuestionAnswerId = CVIQuestionAnswerID
	FROM Reference.CVIQuestionAnswer WITH (NOLOCK)
	WHERE CVIQuestionID = @QuestionId AND CVIAnswerID = @AnswerId	   

	-- Check if @QuestionAnswerId is NULL
	IF @QuestionAnswerId IS NULL 
	BEGIN
		SET @ErrMsg = 'Answer (' + @AnswerName + ') is not associated with Question (' + @QuestionName + ')';
		THROW 90508, @ErrMsg,1
	END

	--Get InformationSourceId
	SELECT @InformationSource = InformationSourceID
	FROM Reference.InformationSource WITH (NOLOCK)
	WHERE Name = 'CEM API'

	SELECT @CVIResponseIndividualId = CVIResponseIndividualID
	FROM Staging.STG_CVIResponseIndividual WITH (NOLOCK)
	WHERE CVIQuestionAnswerID = @QuestionAnswerId and IndividualID = @IndividualId AND ArchivedInd = 0

	--Archives response data and updates it in case it exists for the specific individual, otherwise inserts a new one
	IF @CVIResponseIndividualId IS NOT NULL
	BEGIN
		--Insert Individual Response with new data
		INSERT INTO [CEM_ARCHIVE].[Staging].[STG_CVIResponseIndividual]
        ([Name]
        ,[Description]
        ,[CreatedDate]
        ,[CreatedBy]
        ,[LastModifiedDate]
        ,[LastModifiedBy]
		,[ArchivedInd]
        ,[IndividualID]		
        ,[CVIQuestionGroupID]
        ,[CVIQuestionAnswerID]
        ,[Response]
        ,[InformationSourceID])
		SELECT Name,Description,CreatedDate,CreatedBy,GETDATE(),@userid,0,IndividualID,CVIQuestionGroupID,CVIQuestionAnswerID,@Response,InformationSourceID
		FROM [Staging].[STG_CVIResponseIndividual]
		WHERE CVIResponseIndividualID = @CVIResponseIndividualId

		SET @RowCount = @@ROWCOUNT
		
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to archive individual response data' ;
			THROW 90508, @ErrMsg,1
		END
		
		--Update ArchivedInd to 1
		UPDATE [Staging].[STG_CVIResponseIndividual]
		SET ArchivedInd = 1
		WHERE CVIResponseIndividualID = @CVIResponseIndividualId

		SET @RowCount = @@ROWCOUNT
		
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to update individual response data' ;
			THROW 90508, @ErrMsg,1
		END
	END		
	ELSE
	BEGIN
		--Insert Customer Response
		INSERT INTO [Staging].[STG_CVIResponseIndividual]
        ([Name]
        ,[Description]
        ,[CreatedDate]
        ,[CreatedBy]
        ,[LastModifiedDate]
        ,[LastModifiedBy]
		,[ArchivedInd]
        ,[IndividualID]
        ,[CVIQuestionGroupID]
        ,[CVIQuestionAnswerID]
        ,[Response]
        ,[InformationSourceID])
		VALUES
		(NULL,
		 NULL,
		 GETDATE(),
		 @userid,
		 GETDATE(),
		 @userid,
		 0,
		 @IndividualId,
		 @QuestionGroupId,
		 @QuestionAnswerId,
		 @Response,
		 @InformationSource)

		SET @RowCount = @@ROWCOUNT
		
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to insert individual response data' ;
			THROW 90508, @ErrMsg,1
		END
	END
			
    RETURN @RowCount;

GO
