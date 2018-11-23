CREATE PROCEDURE [Reference].[OperationalStatus_Set]
(
	@userid               INTEGER        = 0,
	@name                 NVARCHAR(256),
	@desc                 NVARCHAR(4000) = NULL,
	@archivedind          BIT            = 0,
	@returnid             INTEGER OUTPUT
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


    IF EXISTS (SELECT 1
               FROM [Reference].[OperationalStatus]
		   	   WHERE Name = @name)
    BEGIN
        UPDATE [Reference].[OperationalStatus]
        SET    [Description]      = @desc
              ,[LastModifiedDate] = GETDATE()
              ,[LastModifiedBy]   = @userid
              ,[ArchivedInd]      = @archivedind
        WHERE Name = @name
	END 
    ELSE
    BEGIN
        INSERT INTO [Reference].[OperationalStatus]
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

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = OperationalStatusID
	FROM   [Reference].[OperationalStatus]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END