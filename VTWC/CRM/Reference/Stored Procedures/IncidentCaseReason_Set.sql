CREATE PROCEDURE [Reference].[IncidentCaseReason_Set]
(
	@userid                 INTEGER        = 0,
	@name                   NVARCHAR(256),
	@desc                   NVARCHAR(4000) = NULL,
	@archivedind            BIT            = 0,
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

	IF @informationsourceid IS NULL
	BEGIN
	    SELECT @informationsourceid = InformationSourceID
		FROM   [Reference].[InformationSource]
		WHERE  Name = @informationsource
    END


    IF EXISTS (SELECT 1
               FROM [Reference].[IncidentCaseReason]
		   	   WHERE Name = @name)
    BEGIN
        UPDATE [Reference].[IncidentCaseReason]
        SET    [Description]         = @desc
              ,[LastModifiedDate]    = GETDATE()
              ,[LastModifiedBy]      = @userid
              ,[ArchivedInd]         = @archivedind
			  ,[ExtReference]        = @extreference
			  ,[InformationSourceID] = @informationsourceid
        WHERE Name = @name
	END 
    ELSE
    BEGIN
        INSERT INTO [Reference].[IncidentCaseReason]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[InformationSourceID]
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
		   ,@extreference)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = IncidentCaseReasonID
	FROM   [Reference].[IncidentCaseReason]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END