CREATE PROCEDURE [Reference].[ResponseCode_Set]
(
	@userid                 INTEGER        = 0,
	@name                   NVARCHAR(256),
	@desc                   NVARCHAR(4000) = NULL,
	@archivedind            BIT            = 0,
	@responsecodetypeid     INTEGER        = NULL,
	@responsecodetype       NVARCHAR(256)  = NULL,
	@extreference           NVARCHAR(256)  = NULL,
	@informationsource      NVARCHAR(256)  = NULL,
	@informationsourceid    INTEGER        = NULL,
	@returnid               INTEGER OUTPUT
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

    IF @responsecodetypeid IS NULL
	BEGIN
	    SELECT @responsecodetypeid = ResponseCodeTypeID
		FROM   [Reference].[ResponseCodeType]
		WHERE  Name = @responsecodetype
    END

	IF @informationsourceid IS NULL
	BEGIN
	    SELECT @informationsourceid = InformationSourceID
		FROM   [Reference].[InformationSource]
		WHERE  Name = @informationsource
    END


    IF EXISTS (SELECT 1
               FROM [Reference].[ResponseCode]
		   	   WHERE Name = @name)
    BEGIN
        UPDATE [Reference].[ResponseCode]
        SET    [Description]         = @desc
              ,[LastModifiedDate]    = GETDATE()
              ,[LastModifiedBy]      = @userid
              ,[ArchivedInd]         = @archivedind
			  ,[ExtReference]        = @extreference
			  ,[ResponseCodeTypeID]  = @responsecodetypeid
			  ,[InformationSourceID] = @informationsourceid
        WHERE Name = @name
	END 
    ELSE
    BEGIN
        INSERT INTO [Reference].[ResponseCode]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[InformationSourceID]
		   ,[ResponseCodeTypeID]
		   ,[ExtReference])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,@archivedind
		   ,@informationsourceid
		   ,@responsecodetypeid
		   ,@extreference)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = ResponseCodeID
	FROM   [Reference].[ResponseCode]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END