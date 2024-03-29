USE [CEM]
GO
/****** Object:  StoredProcedure [api_manager].[updateCVIQuestion]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_manager].[updateCVIQuestion]
	@userid int = NULL,
	@QuestionId int,
	@QuestionName varchar(256) = NULL,
	@GroupName varchar(256) = NULL,
	@DataType varchar(256) = NULL,
	@Visible bit = NULL
	 
  AS 
    
    set nocount on;

    DECLARE @RowCount int = 0
	DECLARE @DisplayOrder int = 0
	DECLARE @GroupId int = NULL
	DECLARE @DataTypeId int = NULL
    DECLARE @ErrMsg varchar(max)

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
	          
	-- Check if @QuestionName is NULL
	IF @QuestionName IS NULL 
	BEGIN
		SET @ErrMsg = 'Question name cannot be NULL';
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

	-- Check if @DataType is NULL
	IF @DataType IS NULL 
	BEGIN
		SET @ErrMsg = 'Data type cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	--Get DataTypeID
    SELECT @DataTypeId = DataTypeID
    FROM Reference.DataType
    WHERE Name = @DataType

	-- Check if DataTypeId is NULL
	IF @DataTypeId IS NULL 
	BEGIN
		SET @ErrMsg = 'Data type does not exist (' + @DataType + ')';
		THROW 90508, @ErrMsg,1
	END		

	--Get @GroupId
	SELECT @GroupId = CVIGroupID
	FROM Reference.CVIGroup
	WHERE Name = @GroupName

	IF @GroupId IS NULL
	BEGIN
		SET @ErrMsg = 'Group does not exist (' + @GroupName + ')';
		THROW 90508, @ErrMsg,1
	END

	--Check if QuestionGroup exists
	IF NOT EXISTS (SELECT 1
				   FROM Reference.CVIQuestionGroup
				   WHERE CVIQuestionID = @QuestionId and CVIGroupID = @GroupId)
	BEGIN
		SET @ErrMsg = 'Associate a question to a different group is not supported (' + CAST(@GroupId as varchar) + ',' + CAST(@QuestionId as varchar) + ')';
		THROW 90508, @ErrMsg,1	
	END

	--Check if data type is different than the original an throwing an error in that case
	IF NOT EXISTS (SELECT 1
				   FROM Reference.CVIQuestion
				   WHERE CVIQuestionID = @QuestionId AND ResponseTypeID = @DataTypeId)
	BEGIN
		SET @ErrMsg = 'Response type is different from the original one. Changing the response type is not supported.';
		THROW 90508, @ErrMsg,1	
	END

	--Update Question if it exists
	IF EXISTS (SELECT 1
			   FROM Reference.CVIQuestionGroup
			   WHERE CVIQuestionID = @QuestionId)
	BEGIN
		--Insert question data into CEM_ARCHIVE
		INSERT INTO [CEM_ARCHIVE].[Reference].[CVIQuestion]
		([CVIQuestionID]
		,[Name]
		,[Description]
		,[CreatedDate]
		,[CreatedBy]
		,[LastModifiedDate]
		,[LastModifiedBy]
		,[ArchivedInd]		
		,[DisplayName]
		,[ExtReference]
        ,[ResponseTypeID]
        ,[LookupReference]
        ,[CVITypeID]
        ,[InformationSourceID])		
		SELECT CVIQuestionID,Name,Description,CreatedDate,CreatedBy,LastModifiedDate,LastModifiedBy,ArchivedInd,DisplayName,ExtReference,
			   ResponseTypeID,LookupReference,CVITypeID,InformationSourceID
		FROM [Reference].[CVIQuestion]
		WHERE CVIQuestionID = @QuestionId

		SET @RowCount = @@ROWCOUNT
		
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to archive question data' ;
			THROW 90508, @ErrMsg,1
		END

		--Update Question
		UPDATE Reference.CVIQuestion
		SET Name = @QuestionName,
			ArchivedInd = @Visible,
			LastModifiedDate = GETDATE(),
			LastModifiedBy = @userid,	
			DisplayName = @QuestionName	
		WHERE CVIQuestionID = @QuestionId
	END		
	ELSE
	BEGIN
		SET @ErrMsg = 'Question does not exist (' + CAST(@QuestionId as varchar) + ')';
		THROW 90508, @ErrMsg,1
	END
		
	SET @RowCount = @@ROWCOUNT
		
	IF @RowCount = 0
	BEGIN
		SET @ErrMsg = 'Unable to update question' ;
		THROW 90508, @ErrMsg,1
	END
					
    RETURN @RowCount;

GO
