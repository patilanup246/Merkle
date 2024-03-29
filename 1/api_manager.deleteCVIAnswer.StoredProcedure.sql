USE [CEM]
GO
/****** Object:  StoredProcedure [api_manager].[deleteCVIAnswer]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_manager].[deleteCVIAnswer]
	@userid int = NULL,
	@AnswerId int = NULL,
	@QuestionId int = NULL
  AS 
    
    set nocount on;

    DECLARE @RowCount int = 0
    DECLARE @AnswerName varchar(256) = NULL
	DECLARE @ErrMsg varchar(max)
	
	-- Check if @userid is NULL
	IF @userid IS NULL 
	BEGIN
		SET @ErrMsg = 'User Id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @AnswerId is NULL
	IF @AnswerId IS NULL 
	BEGIN
		SET @ErrMsg = 'Answer id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END          

	-- Check if @QuestionId is NULL
	IF @QuestionId IS NULL 
	BEGIN
		SET @ErrMsg = 'Question id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END  

	SELECT @AnswerName = DisplayName
	FROM Reference.CVIAnswer
	WHERE CVIAnswerID = @AnswerId AND ArchivedInd = 0

	--Delete Answer if it exists
	IF @AnswerName IS NOT NULL
	BEGIN
		SET @ErrMsg = 'Answer does not exist (' + @AnswerName + ')';
		THROW 90508, @ErrMsg,1
	END		

	IF EXISTS (SELECT 1
			   FROM Reference.CVIQuestionAnswer
			   WHERE CVIAnswerID = @AnswerId AND CVIQuestionID <> @QuestionId AND ArchivedInd = 0)
	BEGIN
		SET @ErrMsg = 'Answer (' + @AnswerName + ') is associated to more than one question and cannot be deleted';
		THROW 90508, @ErrMsg,1
	END		
	ELSE
	BEGIN				
		--Delete Question Answers data
		UPDATE [Reference].[CVIQuestionAnswer] SET ArchivedInd = 1
		WHERE CVIQuestionID = @QuestionId AND CVIAnswerID = @AnswerId AND ArchivedInd = 0

		SET @RowCount = @@ROWCOUNT
		
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Error deleting answer data' ;
			THROW 90508, @ErrMsg,1
		END								
	END

    RETURN @RowCount;

GO
