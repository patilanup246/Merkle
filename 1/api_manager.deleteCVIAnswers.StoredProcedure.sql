USE [CEM]
GO
/****** Object:  StoredProcedure [api_manager].[deleteCVIAnswers]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_manager].[deleteCVIAnswers]
	@userid int = NULL,
	@QuestionId int = NULL
  AS 
    
    set nocount on;

    DECLARE @RowCount int = 0
    DECLARE @AnswerId int = NULL
	DECLARE @ErrMsg varchar(max)
	
	-- Check if @userid is NULL
	IF @userid IS NULL 
	BEGIN
		SET @ErrMsg = 'User Id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @AnswerId is NULL
	IF @QuestionId IS NULL 
	BEGIN
		SET @ErrMsg = 'Question id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END          

	DECLARE answers_cursor CURSOR FOR   
	SELECT CVIAnswerID
	FROM Reference.CVIQuestionAnswer  
	WHERE CVIQuestionID = @QuestionId 
  
    OPEN answers_cursor  
    FETCH NEXT FROM answers_cursor INTO @AnswerId 
 
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
  
        IF EXISTS (SELECT 1  
				   FROM Reference.CVIQuestionAnswer  
				   WHERE CVIAnswerID = @AnswerId AND CVIQuestionID <> @QuestionId)
		BEGIN
			PRINT 'Answer (' + CAST(@AnswerId as varchar) + ') is associated with more than one question and cannot be deleted';			
		END  
        ELSE
		BEGIN
			--Update ArchivedInd field to 1 to mark deleted Answers data
			UPDATE [Reference].[CVIAnswer] SET ArchivedInd = 1
			WHERE CVIAnswerID = @AnswerId

			SET @RowCount = @@ROWCOUNT
		
			IF @RowCount = 0
			BEGIN
				SET @ErrMsg = 'Error deleting answer data (' + CAST(@AnswerId as varchar) + ')';
				THROW 90508, @ErrMsg,1
			END
		END
	FETCH NEXT FROM answers_cursor INTO @AnswerId  
    END  
  
    CLOSE answers_cursor  
    DEALLOCATE answers_cursor  
	   									
    RETURN @RowCount;

GO
