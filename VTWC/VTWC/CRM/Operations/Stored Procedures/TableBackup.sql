
	CREATE PROCEDURE [Operations].[TableBackup]
  
		@table_name			VARCHAR(256),
		@userid				INT = 0

		AS

		BEGIN

			SET NOCOUNT ON
		
			DECLARE @spname				VARCHAR(256)
			DECLARE @logmessage			VARCHAR(MAX)
			DECLARE @logmessagelevel	VARCHAR(16)
			DECLARE @messagetypecd		VARCHAR(128)
			DECLARE @temp_name			VARCHAR(256);
			DECLARE @assertsuccess		BIT;
			
			SET @spname				= OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			SET @temp_name			= OBJECT_SCHEMA_NAME(OBJECT_ID(@table_name)) + '.TEMP_' + OBJECT_NAME(OBJECT_ID(@table_name))
					
			--Create a full clone (with data) of the table
			EXEC('SELECT * INTO ' + @temp_name + ' FROM ' + @table_name);

			--check if backup was successful
			IF (
					OBJECT_NAME(OBJECT_ID(@table_name)) IS NOT NULL
				AND OBJECT_NAME(OBJECT_ID(@temp_name)) IS NOT NULL
				)
				BEGIN
						SELECT @logmessage			= '"' + @table_name + '" - Table backup successful';
						SELECT @logmessagelevel		= 'DEBUG';
						SELECT @messagetypecd		= 'Information';
						SELECT @assertsuccess		= 1;
				END
			ELSE
				BEGIN
						SELECT @logmessage			= 'Unable to perform table backup of "' + @table_name + '". Operation not successful!';
						SELECT @logmessagelevel		= 'ERROR';
						SELECT @messagetypecd		= 'Failed operation';
						SELECT @assertsuccess		= 0;
				END

			--update log table
			EXEC [Operations].[LogMessage_Record]	@userid				= @userid,
													@logsource			= @spname,
													@logmessage			= @logmessage,
													@logmessagelevel	= @logmessagelevel,
													@messagetypecd		= @messagetypecd					

		END

		RETURN @assertsuccess