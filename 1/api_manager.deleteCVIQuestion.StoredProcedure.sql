USE [CEM]
GO
/****** Object:  StoredProcedure [api_manager].[deleteCVIQuestion]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_manager].[deleteCVIQuestion]
	@userid int = NULL,
	@QuestionId int = NULL,
	@GroupName varchar(256) = NULL 
  AS 
    
    DECLARE @RowCount int = 0	
    DECLARE @QuestionName varchar(256) = NULL
	DECLARE @ErrMsg varchar(max)
	DECLARE @GroupId int = NULL
	
	-- Check if @userid is NULL
	IF @userid IS NULL 
	BEGIN
		SET @ErrMsg = 'User Id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @QuestionId is NULL
	IF @QuestionId IS NULL 
	BEGIN
		SET @ErrMsg = 'Question id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END          

	-- Check if @GroupName is NULL
	IF @GroupName IS NULL 
	BEGIN
		SET @ErrMsg = 'Group name cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	--Get GroupID
    SELECT @GroupId = CVIGroupID
    FROM Reference.CVIGroup
    WHERE DisplayName = @GroupName

	IF @GroupId IS NULL
	BEGIN
		SET @ErrMsg = 'Group (' + @GroupName + ') does not exist' ;
		THROW 90508, @ErrMsg,1
	END

	SELECT @QuestionName = DisplayName
	FROM Reference.CVIQuestion
	WHERE CVIQuestionID = @QuestionId

	--Delete Answer if it exists
	IF @QuestionName IS NULL
	BEGIN
		SET @ErrMsg = 'Question (' + CAST(@QuestionId as varchar) + ') does not exist';
		THROW 90508, @ErrMsg,1
	END		
		
	IF EXISTS (SELECT 1 FROM [Reference].[CVIQuestionGroup]
				WHERE CVIQuestionID = @QuestionId AND CVIGroupID = @GroupId AND ArchivedInd = 0)
	BEGIN
		--Delete Question Groups data
		UPDATE [Reference].[CVIQuestionGroup] SET ArchivedInd = 1
		WHERE CVIQuestionID = @QuestionId AND CVIGroupID = @GroupId
	END
	ELSE
	BEGIN
		SET @ErrMsg = 'All records for the question (' + @QuestionName + ') in the group (' + @GroupName + ') were already marked as deleted' ;
		THROW 90508, @ErrMsg,1
	END
		   									
	SET @RowCount = @@ROWCOUNT
		
	IF @RowCount = 0
	BEGIN
		SET @ErrMsg = 'Error deleting question data' ;
		THROW 90508, @ErrMsg,1
	END

    RETURN @RowCount;


GO
