USE [CEM]
GO
/****** Object:  StoredProcedure [api_manager].[updateCVIAnswer]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_manager].[updateCVIAnswer]
	@userid int = NULL,
	@AnswerName varchar(256) = NULL,
	@AnswerId int = NULL,
	@Visible bit = NULL
	
  AS 
    
    set nocount on;

    DECLARE @RowCount int = 0
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
	
	-- Check if @AnswerName is NULL
	IF @AnswerName IS NULL 
	BEGIN
		SET @ErrMsg = 'Answer name cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @AnswerId is NULL
	IF @AnswerId IS NULL 
	BEGIN
		SET @ErrMsg = 'Answer id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END
	      
	--Update Answer if it exists
	IF EXISTS (SELECT 1
			   FROM Reference.CVIAnswer
			   WHERE CVIAnswerID = @AnswerId)
	BEGIN
		--Insert question answers into CEM_ARCHIVE
		INSERT INTO [CEM_ARCHIVE].[Reference].[CVIAnswer]
        (CVIAnswerID
		,[Name]
        ,[Description]
        ,[CreatedDate]
        ,[CreatedBy]
        ,[LastModifiedDate]
        ,[LastModifiedBy]
        ,[ArchivedInd]
        ,[DisplayName]
		,[ExtReference])
		SELECT CVIAnswerID,Name,Description,CreatedDate,CreatedBy,LastModifiedDate,LastModifiedBy,ArchivedInd,DisplayName,ExtReference
		FROM [Reference].[CVIAnswer]
		WHERE CVIAnswerID = @Answerid

		SET @RowCount = @@ROWCOUNT
		
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to archive answer data' ;
			THROW 90508, @ErrMsg,1
		END

		--Update Answer
		UPDATE [Reference].[CVIAnswer]
		SET Name = @AnswerName,
			ArchivedInd = @Visible,
			DisplayName = @AnswerName,
			LastModifiedDate = GETDATE(),
			LastModifiedBy = @userid
		WHERE CVIAnswerID = @Answerid
	END		
	ELSE
	BEGIN
		SET @ErrMsg = 'Answer does not exists (' + @AnswerName + ')';
		THROW 90508, @ErrMsg,1
	END

	SET @RowCount = @@ROWCOUNT
		
	IF @RowCount = 0
	BEGIN
		SET @ErrMsg = 'Unable to update answer' ;
		THROW 90508, @ErrMsg,1
	END
	   		
    RETURN @RowCount;

GO
