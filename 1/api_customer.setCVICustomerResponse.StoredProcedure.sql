USE [CEM]
GO
/****** Object:  StoredProcedure [api_customer].[setCVICustomerResponse]    Script Date: 24/07/2018 14:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [api_customer].[setCVICustomerResponse]
	@userid int = NULL,
	@Responses api_manager.CVIResponseType READONLY,
	@EncryptedEmail varchar(max)	
  AS 
    
    set nocount on;

    DECLARE @RowCount int = 0
    DECLARE @ErrMsg varchar(max)
	DECLARE @GroupId int = NULL
	DECLARE @AnswerId int = NULL
	DECLARE @QuestionName varchar(256) = NULL
	DECLARE @QuestionGroupId int = NULL
	DECLARE @QuestionAnswerId int = NULL
	DECLARE @CustomerXEmail int = 0
	DECLARE @CustomerId int = NULL
	DECLARE @InformationSource int = 1
	DECLARE @CVIResponseCustomerId int = NULL
	DECLARE	@QuestionId int = NULL
	DECLARE @GroupName varchar(256) = NULL
	DECLARE @AnswerName varchar(256) = NULL
	DECLARE @Response varchar(4000) = NULL


	-- Check if @userid is NULL
	IF @userid IS NULL 
	BEGIN
		SET @ErrMsg = 'User Id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @EncryptedEmail is NULL
	IF @EncryptedEmail IS NULL 
	BEGIN
		SET @ErrMsg = 'Encrypted email cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	--Get Customer Id
	SELECT @CustomerXEmail = COUNT(1) 
    FROM api_customer.ContactInformation ci WITH (NOLOCK) 
    WHERE ci.EncryptedEmail = @EncryptedEmail

	IF @CustomerXEmail > 1
    BEGIN
        SET @ErrMsg = 'Unable to modify the specified email. Multiple Customers per email.';
        THROW 51403, @ErrMsg,1
    END   
           
    SELECT @CustomerId = CustomerID
    FROM Staging.STG_ElectronicAddress ea WITH (NOLOCK)
    WHERE ea.EncrytpedAddress = @encryptedEmail AND 
	      ea.ArchivedInd = 0 AND 
	      ea.PrimaryInd = 1 AND
		  ea.AddressTypeID = 3 AND
		  ea.CustomerID IS NOT NULL

	Set @RowCount = @@ROWCOUNT

    IF @RowCount = 0
    BEGIN
		IF EXISTS ( SELECT 1
					  FROM CEM.PreProcessing.API_CustomerRegistration ea WITH (NOLOCK) 
					 WHERE ea.[EncryptedEmail] = @encryptedEmail 
					   AND ea.ProcessedInd = 0)
			BEGIN
				SET @ErrMsg = '('+@encryptedEmail+') is not recognised by CEM';
				THROW 51403, @ErrMsg,1
			END
		ELSE
			BEGIN
				SET @ErrMsg = 'Unable to find a Customer for the specified encrypted Email ('+@encryptedEmail+')';
				THROW 51403, @ErrMsg,1
			END
    END 
	
	--Get InformationSourceId
	SELECT @InformationSource = InformationSourceID
	FROM Reference.InformationSource WITH (NOLOCK)
	WHERE Name = 'CEM API'

	DECLARE answers_cursor CURSOR FOR   
	SELECT QuestionId,GroupName,AnswerName,Response
	FROM @Responses  	
  
    OPEN answers_cursor  
    FETCH NEXT FROM answers_cursor INTO @QuestionId,@GroupName,@AnswerName,@Response
 
    WHILE @@FETCH_STATUS = 0  
    BEGIN  	
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

		--Get Group Id
		SELECT @GroupId = CVIGroupID
		FROM Reference.CVIGroup WITH (NOLOCK)
		WHERE DisplayName = @GroupName

		-- Check if @GroupId is NULL
		IF @GroupId IS NULL 
		BEGIN
			SET @ErrMsg = 'Group (' + @GroupName + ') does not exist' ;
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
		WHERE CVIQuestionID = @QuestionId AND CVIGroupID = @GroupId	AND ArchivedInd = 0   

		-- Check if @QuestionGroupId is NULL
		IF @QuestionGroupId IS NULL 
		BEGIN
			SET @ErrMsg = 'Question (' + @QuestionName + ') is not associated with Group (' + @GroupName + ') or it has been deleted';
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

		SELECT @CVIResponseCustomerId = CVIResponseCustomerID
		FROM Staging.STG_CVIResponseCustomer WITH (NOLOCK)
		WHERE CVIQuestionAnswerID = @QuestionAnswerId and CustomerID = @CustomerId AND ArchivedInd = 0

		--Archives response data and updates it in case it exists for the specific customer, otherwise inserts a new one
		IF @CVIResponseCustomerId IS NOT NULL
		BEGIN
			--Create new Customer Response with new data
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
			SELECT Name,Description,CreatedDate,CreatedBy,GETDATE(),@userid,0,CustomerID,CVIQuestionGroupID,CVIQuestionAnswerID,@Response,InformationSourceID
			FROM [Staging].[STG_CVIResponseCustomer]
			WHERE CVIResponseCustomerID = @CVIResponseCustomerID

			SET @RowCount = @@ROWCOUNT
		
			IF @RowCount = 0
			BEGIN
				SET @ErrMsg = 'Unable to archive customer response data' ;
				THROW 90508, @ErrMsg,1
			END

			--Update ArchivedInd to 1 in old Answer
			UPDATE [Staging].[STG_CVIResponseCustomer]
			SET ArchivedInd = 1
			WHERE CVIResponseCustomerID = @CVIResponseCustomerID

			SET @RowCount = @@ROWCOUNT
		
			IF @RowCount = 0
			BEGIN
				SET @ErrMsg = 'Unable to update customer response data' ;
				THROW 90508, @ErrMsg,1
			END
		END		
		ELSE
		BEGIN
			--Insert Customer Response
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
			(NULL,
			 NULL,
			 GETDATE(),
			 @userid,
			 GETDATE(),
			 @userid,
			 0,
			 @CustomerId,
			 @QuestionGroupId,
			 @QuestionAnswerId,
			 @Response,
			 @InformationSource)

			SET @RowCount = @@ROWCOUNT
		
			IF @RowCount = 0
			BEGIN
				SET @ErrMsg = 'Unable to insert customer response data' ;
				THROW 90508, @ErrMsg,1
			END
		END

	FETCH NEXT FROM answers_cursor INTO @QuestionId,@GroupName,@AnswerName,@Response  
    END  
  
    CLOSE answers_cursor  
    DEALLOCATE answers_cursor  

    RETURN @RowCount;



GO
