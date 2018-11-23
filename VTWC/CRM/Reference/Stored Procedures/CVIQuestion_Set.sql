CREATE PROCEDURE [Reference].[CVIQuestion_Set]
(
	@userid                INTEGER = 0,
	@name                  NVARCHAR(256),
	@desc                  NVARCHAR(4000) = NULL,
    @type				   VARCHAR(20) = 'STANDARD',
	@returnid              INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    IF EXISTS (SELECT 1
               FROM [Reference].[CVIQuestion]
		       WHERE [Name] = @name)
    BEGIN
        UPDATE [Reference].[CVIQuestion]
	    SET    [Description]       = @desc,
			   [Type]			   = @type,
	           [LastModifiedBy]    = @userid,
		       [LastModifiedDate]  = GETDATE()
	    WHERE  [Name] = @name
    END

    ELSE
    BEGIN
        INSERT INTO [Reference].[CVIQuestion]
            ([Name]
            ,[Description]
			,[Type]
            ,[CreatedDate]
            ,[CreatedBy]
            ,[LastModifiedDate]
            ,[LastModifiedBy]
			)
     VALUES
           (@name
           ,@desc
		   ,@type
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
		   )
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = [CVIQuestionID]
	FROM   [Reference].[CVIQuestion]
	WHERE  [Name] = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END