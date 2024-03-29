USE [CEM]
GO
/****** Object:  StoredProcedure [api_manager].[addCVIQuestion]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [api_manager].[addCVIQuestion]
	@userid int = NULL,
	@GroupName varchar(256) = NULL,
	@QuestionName varchar(256) = NULL,
	@DataType varchar(256) = NULL,
	@Visible bit = NULL,
	@QuestionId int output,
	@QuestionExisting bit output
  AS 
    
    set nocount on;

	DECLARE @DisplayOrder int = 0
	DECLARE @GroupId int = NULL
	DECLARE @DataTypeId int = NULL
	DECLARE @TypeId int = 1
	DECLARE @InformationSource int = 1
    DECLARE @ErrMsg varchar(max)
	DECLARE @QGArchive bit
	DECLARE @ArchivedInd bit
	DECLARE @CurrentDataTypeID int
	DECLARE @RowCount int

	IF @Visible = 1 
	BEGIN
		SET @QGArchive = 0
	END
	ELSE
	BEGIN
		SET @QGArchive = 1
	END

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
          
	-- Check if @QuestionName is NULL
	IF @QuestionName IS NULL 
	BEGIN
		SET @ErrMsg = 'Question name cannot be NULL';
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
    FROM Reference.DataType WITH (NOLOCK)
    WHERE Name = @DataType

	-- Check if DataTypeId is NULL
	IF @DataTypeId IS NULL 
	BEGIN
		SET @ErrMsg = 'Data type does not exist (' + @DataType + ')';
		THROW 90508, @ErrMsg,1
	END		
	
	--Get GroupID
    SELECT @GroupId = CVIGroupID
    FROM Reference.CVIGroup WITH (NOLOCK)
    WHERE DisplayName = @GroupName

	-- Check if GroupId is NULL, if it is we insert it
	IF @GroupID IS NULL 
	BEGIN
		INSERT INTO [Reference].[CVIGroup]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[DisplayName]
           ,[ExtReference])
		VALUES
			(NULL
			,NULL
			,GETDATE()
			,@userid
			,GETDATE()
			,@userid
			,0
			,@GroupName
			,NULL)

		Set @RowCount = @@ROWCOUNT

		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to add group' ;
			THROW 90508, @ErrMsg,1
		END
		
		SET @GroupId = IDENT_CURRENT('Reference.CVIGroup')
	END		
	
	--Get TypeId
	SELECT @TypeId = CVITypeID
	FROM Reference.CVIType WITH (NOLOCK)
	WHERE DisplayName = 'General'

	--Get InformationSourceId
	SELECT @InformationSource = InformationSourceID
	FROM Reference.InformationSource WITH (NOLOCK)
	WHERE Name = 'CEM API'

	--Select display order
	SELECT @DisplayOrder = COUNT(1)
	FROM Reference.CVIQuestionGroup WITH (NOLOCK)
	WHERE CVIGroupID = @GroupId

	SET @DisplayOrder = @DisplayOrder + 1

	--Get QuestionID
	SELECT @QuestionId = CVIQuestionID
	FROM Reference.CVIQuestion WITH (NOLOCK)
	WHERE DisplayName = @QuestionName

	--Insert Question if it does not exist
	IF @QuestionId IS NOT NULL
	BEGIN
		SET @ArchivedInd = NULL
		SET @QuestionExisting = 1

		--Check if provided data type is different from the current one
		SELECT @CurrentDataTypeID = ResponseTypeID
		FROM Reference.CVIQuestion WITH (NOLOCK)
		WHERE CVIQuestionID = @QuestionId

		IF @DataTypeId <> @CurrentDataTypeID
		BEGIN
			SET @ErrMsg = 'Response type is different from the original one. Changing the response type is not supported.' ;
			THROW 90508, @ErrMsg,1
		END

		SELECT @ArchivedInd = ArchivedInd 
		FROM Reference.CVIQuestionGroup WITH (NOLOCK)
	    WHERE CVIQuestionID = @QuestionId AND CVIGroupID = @GroupId

		IF @ArchivedInd IS NULL
		BEGIN
			--Insert question and group into CVIQuestionGroup
			INSERT INTO [Reference].[CVIQuestionGroup]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[CVIQuestionID]
           ,[CVIGroupID]
           ,[DisplayOrder])
		   VALUES
		   (NULL,
			NULL,
			GETDATE(),
			@userid,
			GETDATE(),
			@userid,
			@QGArchive,
			@QuestionId,
			@GroupId,
			@DisplayOrder)	
			
			Set @RowCount = @@ROWCOUNT

			IF @RowCount = 0
			BEGIN
				SET @ErrMsg = 'Unable to add question group' ;
				THROW 90508, @ErrMsg,1
			END	
		END
		ELSE
		BEGIN
			IF @ArchivedInd = 1
			BEGIN
				UPDATE Reference.CVIQuestionGroup SET ArchivedInd = 0
				WHERE CVIQuestionID = @QuestionId AND CVIGroupID = @GroupId

				Set @RowCount = @@ROWCOUNT

				IF @RowCount = 0
				BEGIN
					SET @ErrMsg = 'Unable to update ArchivedInd in QuestionGroup' ;
					THROW 90508, @ErrMsg,1
				END	
			END
			ELSE
			BEGIN
				SET @ErrMsg = 'Question already exists (' + @QuestionName + ') for group (' + @GroupName + ')';
				THROW 90508, @ErrMsg,1
			END
		END
	END		
	ELSE
	BEGIN
		--Insert question into CVIQuestion
		INSERT INTO [Reference].[CVIQuestion]
		([Name]
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
		,[InformationSourceID]
		)
		 VALUES
		(NULL,
		NULL,
		GETDATE(),
		@userid,
		GETDATE(),
		@userid,
		0,
		@QuestionName,
		NULL,
		@DataTypeId,
		NULL,
		@TypeId,
		@InformationSource)
		
		Set @RowCount = @@ROWCOUNT

		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to add question' ;
			THROW 90508, @ErrMsg,1
		END

		SET @QuestionId = IDENT_CURRENT('Reference.CVIQuestion')
		SET @QuestionExisting = 0							
			
		--Insert question and group into CVIQuestionGroup
		INSERT INTO [Reference].[CVIQuestionGroup]
        ([Name]
        ,[Description]
        ,[CreatedDate]
        ,[CreatedBy]
        ,[LastModifiedDate]
        ,[LastModifiedBy]
        ,[ArchivedInd]
        ,[CVIQuestionID]
        ,[CVIGroupID]
        ,[DisplayOrder])
		VALUES
		(NULL,
		NULL,
		GETDATE(),
		@userid,
		GETDATE(),
		@userid,
		@QGArchive,
		@QuestionId,
		@GroupId,
		@DisplayOrder)		   			   
		
		Set @RowCount = @@ROWCOUNT

		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to add question group' ;
			THROW 90508, @ErrMsg,1
		END
		
	END
				
    RETURN @RowCount;

GO
