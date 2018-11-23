  
	CREATE PROCEDURE [Operations].[CheckTableAndRestoreOnFailure]
  
		@table_name			VARCHAR(256),
		@userid				INT = 0
		
		AS

		BEGIN
			SET NOCOUNT ON
		
			DECLARE @temp_name		VARCHAR(256)
			DECLARE @spname				VARCHAR(256)
			DECLARE @logmessage			VARCHAR(MAX)
			DECLARE @logmessagelevel	VARCHAR(16)
			DECLARE @messagetypecd		VARCHAR(128)
			DECLARE @query				NVARCHAR(256)
			DECLARE @newcount			INT
			DECLARE @oldcount			INT
			DECLARE @assertsuccess		BIT = 1

			SET @spname				= OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			SET @temp_name			= OBJECT_SCHEMA_NAME(OBJECT_ID(@table_name)) + '.TEMP_' + OBJECT_NAME(OBJECT_ID(@table_name))

			--assign @newcount
			SET @query = N'SELECT @newcountOUT = COUNT(1) FROM ' + @table_name
			EXECUTE SP_EXECUTESQL 
				@query, 
				N'@newcountOUT INT OUTPUT',
				@newcountOUT = @newcount OUTPUT
				
			--assign @oldcount
			SET @query = N'SELECT @oldcountOUT = COUNT(1) FROM ' + @temp_name
			EXECUTE SP_EXECUTESQL 
				@query, 
				N'@oldcountOUT INT OUTPUT',
				@oldcountOUT = @oldcount OUTPUT
			
			IF (@newcount = 0) --meaning that a refresh process has failed
				BEGIN
					SET @logmessage			= 'Number of records in: "' + @table_name + '" = ' + CAST(@newcount AS VARCHAR(256)) + '" - Table restore needed!!';
					SET @logmessagelevel		= 'WARNING';
					SET @messagetypecd		= 'Failed operation';

					--restore data in the original table
					EXEC ('INSERT INTO ' + @table_name + ' SELECT * FROM ' + @temp_name)
					
					--reassign @newcount
					SET @query = N'SELECT @newcountOUT = COUNT(1) FROM ' + @table_name
					EXECUTE SP_EXECUTESQL 
						@query, 
						N'@newcountOUT INT OUTPUT',
						@newcountOUT = @newcount OUTPUT

					--assert restore was successful
					SET @query = CONCAT(N'SELECT @assertsuccessOUT = CASE WHEN (', CAST(@newcount AS NVARCHAR(50)), ' = ', CAST(@oldcount AS NVARCHAR(50)), ') THEN 1 ELSE 0 END')
					EXECUTE SP_EXECUTESQL 
						@query, 
						N'@assertsuccessOUT BIT OUTPUT',
						@assertsuccessOUT = @assertsuccess OUTPUT
					
				END
			ELSE
				BEGIN					
					SET @logmessage			= 'Number of records in: "' + @table_name + '" = ' + CAST(@newcount AS VARCHAR(256)) + '" - No restore needed';
					SET @logmessagelevel		= 'DEBUG';
					SET @messagetypecd		= 'Information';
				END
			
			--drop the temporary backup table
			EXEC ('DROP TABLE ' + @temp_name)
				
			--update log table
			EXEC [Operations].[LogMessage_Record]	@userid				= @userid,
													@logsource			= @spname,
													@logmessage			= @logmessage,
													@logmessagelevel	= @logmessagelevel,
													@messagetypecd		= @messagetypecd

			--check if table restore was successful
			IF (
				OBJECT_NAME(OBJECT_ID(@temp_name)) IS NULL AND @assertsuccess = 1
			)
				BEGIN
						SET @logmessage			= '"' + @table_name + '" - Table restore/clean up successful';
						SET @logmessagelevel		= 'DEBUG';
						SET @messagetypecd		= 'Information';
				END
			ELSE
				BEGIN
						SET @logmessage			= 'Restore of "' + @table_name + '" failed!';
						SET @logmessagelevel		= 'ERROR';
						SET @messagetypecd		= 'Failed operation';
				END

			--update log table
			EXEC [Operations].[LogMessage_Record]	@userid				= @userid,
													@logsource			= @spname,
													@logmessage			= @logmessage,
													@logmessagelevel	= @logmessagelevel,
													@messagetypecd		= @messagetypecd										 
		
		END

		RETURN @assertsuccess