CREATE PROCEDURE [Operations].[LogTiming_Record]
(
    @userid          INTEGER = 0,
	@logsource       NVARCHAR(256),     --name where this stored procedure is called from
	@logtimingid     INTEGER = NULL,    --This will be null for start otherwise it will be ID for the record to be updated with the end time
	@recordcount     INTEGER = NULL,    --Number of records processed
	@logtimingidnew  INTEGER OUTPUT     --Returns the ID of the new record created
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @logtimingid IS NULL
	BEGIN
	    INSERT INTO [Operations].[LogTiming]
           ([LogSource]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[StartDate])
		VALUES 
		   (@logsource
		   ,GETDATE()
		   ,@userid
		   ,GETDATE()
		   ,@userid
		   ,GETDATE())

	    SELECT @logtimingidnew = SCOPE_IDENTITY()
    END
	ELSE
	BEGIN
	    UPDATE [Operations].[LogTiming]
		SET    [LastModifiedDate] = GETDATE(),
		       [LastModifiedBy]   = @userid,
			   [EndDate]          = GETDATE(),
			   [RecordCount]      = @recordcount
        WHERE  LogTimingID        = @logtimingid
    END
    
	RETURN
END