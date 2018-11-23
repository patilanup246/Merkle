CREATE PROCEDURE [Operations].[LogMessage_Record]
(
    @userid              INTEGER = 0,
	@logsource           NVARCHAR(256),           --name where this stored procedure is called from
	@logmessage          NVARCHAR(MAX),           --message to be recorded
	@logmessagelevel     NVARCHAR(16),            --Logging level of the message - Error, Warning, Debug
	@messagetypecd       NVARCHAR(16) = NULL      --Type of message to support reporting
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @messagelevel   INTEGER
	DECLARE @systemlevel    INTEGER

	SELECT @messagelevel = CASE UPPER(@logmessagelevel) WHEN 'ERROR'   THEN 1
	                                                    WHEN 'WARNING' THEN 2
						                                WHEN 'DEBUG'   THEN 3
							                            ELSE 0
						   END

    SELECT @systemlevel = CASE [Reference].[Configuration_GetSetting] ('Operations','LogMessageLevel') WHEN 'ERROR'   THEN 1
	                                                                                                   WHEN 'WARNING' THEN 2
				                                                                                       WHEN 'DEBUG'   THEN 3
						                                                                               ELSE 0
                          END
    
	IF (@messagelevel = 0 OR @systemlevel = 0)
	BEGIN
	    SET @logmessage = 'Error with logging level for either the message or system setting. @messagetype = ' + @logmessagelevel + 
		                   ', @systemlevel = ' + CAST(@systemlevel AS NVARCHAR(1))

        SET @logmessagelevel = 'ERROR'
    END
	ELSE
	BEGIN
	    IF (@messagelevel > @systemlevel)
		BEGIN
		    RETURN --message is below current system setting
		END
	END

	INSERT INTO [Operations].[LogMessage]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[MessageSource]
           ,[Message]
           ,[MessageLevel]
           ,[MessageTypeCd])
     VALUES
           (GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,@logsource
           ,@logmessage
           ,@logmessagelevel
           ,@messagetypecd)

	RETURN
END