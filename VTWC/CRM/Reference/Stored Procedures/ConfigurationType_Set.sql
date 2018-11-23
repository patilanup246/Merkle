CREATE PROCEDURE [Reference].[ConfigurationType_Set]
(
	@userid         INTEGER = 0,
	@name           NVARCHAR(256),
	@desc           NVARCHAR(4000) = NULL,
	@archivedind    BIT            = 0,
	@returnid       INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT


    IF NOT EXISTS (SELECT 1
                   FROM [Reference].[ConfigurationType]
		    	   WHERE Name = @name)
    BEGIN
        INSERT INTO [Reference].[ConfigurationType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
		   ,@userid
           ,@archivedind)
    END
    ELSE
    BEGIN
        UPDATE [Reference].[ConfigurationType]
	    SET    Description           = @desc,
		       ArchivedInd           = @archivedind,
	           LastModifiedBy        = @userid,
		       LastModifiedDate      = GETDATE()
	    WHERE  Name = @name
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = ConfigurationTypeID
	FROM   [Reference].[ConfigurationType]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END