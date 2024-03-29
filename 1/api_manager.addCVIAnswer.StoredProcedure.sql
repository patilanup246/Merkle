USE [CEM]
GO
/****** Object:  StoredProcedure [api_manager].[addCVIAnswer]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_manager].[addCVIAnswer]
	@userid int = NULL,
	@AnswerName varchar(256) = NULL,
	@QuestionId int = NULL,
	@Visible bit = NULL
  AS 
    
    set nocount on;

    DECLARE @RowCount int = 0
	DECLARE @AnswerId int = NULL	
    DECLARE @ErrMsg varchar(max)
	DECLARE @ArchivedInd bit

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

	-- Check if @AnswerName is NULL
	IF @AnswerName IS NULL 
	BEGIN
		SET @ErrMsg = 'Answer name cannot be NULL';
		THROW 90508, @ErrMsg,1
	END
          
	-- Check if @QuestionId is NULL
	IF @QuestionId IS NULL 
	BEGIN
		SET @ErrMsg = 'Question id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	--Check if Answer already exists
	SELECT @AnswerId = CVIAnswerID
	FROM Reference.CVIAnswer WITH (NOLOCK)
	WHERE DisplayName = @AnswerName

	--Insert Answer if it does not exist
	IF @AnswerId IS NOT NULL
	BEGIN
		SELECT @ArchivedInd = ArchivedInd
		FROM Reference.CVIQuestionAnswer WITH (NOLOCK)
		WHERE CVIAnswerID = @AnswerId AND CVIQuestionID = @QuestionId 

		IF @ArchivedInd IS NULL
		BEGIN
			--Insert question and group into CVIQuestionAnswer
			INSERT INTO [Reference].[CVIQuestionAnswer]
			([Name]
			,[Description]
			,[CreatedDate]
			,[CreatedBy]
			,[LastModifiedDate]
			,[LastModifiedBy]
			,[ArchivedInd]
			,[CVIQuestionID]
			,[CVIAnswerID])
			VALUES
			(NULL,
			NULL,
			GETDATE(),
			@userid,
			GETDATE(),
			@userid,
			0,
			@QuestionId,
			@AnswerId)		   			   
		
			Set @RowCount = @@ROWCOUNT

			IF @RowCount = 0
			BEGIN
				SET @ErrMsg = 'Unable to associate answer (' + @AnswerName + ') to question (' + CAST(@QuestionId as varchar) + ')' ;
				THROW 90508, @ErrMsg,1
			END	
		END
		ELSE
		BEGIN
			IF @ArchivedInd = 1
			BEGIN
				UPDATE [Reference].[CVIQuestionAnswer] SET [ArchivedInd] = 0
				WHERE [CVIAnswerID] = @AnswerId AND [CVIQuestionID] = @QuestionId 
			END
		END		
	END		
	ELSE
	BEGIN	
		--Insert question into CVIAnswer
		INSERT INTO [Reference].[CVIAnswer]
		([Name]
		,[Description]
		,[CreatedDate]
		,[CreatedBy]
		,[LastModifiedDate]
		,[LastModifiedBy]
		,[ArchivedInd]
		,[DisplayName]
		,[ExtReference]
		)
		 VALUES
		(NULL,
		NULL,
		GETDATE(),
		@userid,
		GETDATE(),
		@userid,
		0,
		@AnswerName,
		NULL)

		SET @RowCount = @@ROWCOUNT
		
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to add answer' ;
			THROW 90508, @ErrMsg,1
		END

		SET @AnswerId = IDENT_CURRENT('Reference.CVIAnswer')
		
		--Insert question and group into CVIQuestionAnswer
		INSERT INTO [Reference].[CVIQuestionAnswer]
		([Name]
		,[Description]
		,[CreatedDate]
		,[CreatedBy]
		,[LastModifiedDate]
		,[LastModifiedBy]
		,[ArchivedInd]
		,[CVIQuestionID]
		,[CVIAnswerID])
		VALUES
		(NULL,
		NULL,
		GETDATE(),
		@userid,
		GETDATE(),
		@userid,
		0,
		@QuestionId,
		@AnswerId)		   			   
		
		SET @RowCount = @@ROWCOUNT
		
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to associate answer (' + @AnswerName + ') to question (' + CAST(@QuestionId as varchar) + ')' ;
			THROW 90508, @ErrMsg,1
		END
	END
												
    RETURN @RowCount;

GO
