CREATE PROCEDURE [Reference].[SubscriptionType_Set]
(
	@userid               INTEGER        = 0,
	@name                 NVARCHAR(256),
	@desc                 NVARCHAR(4000) = NULL,
	@archivedind          BIT            = 0,
	@allowmultipleind     BIT            = 0,
	@capturetimeind       BIT            = 0,
	@optindefaultind      BIT            = 0,
	@displayname          NVARCHAR(256)  = NULL,
	@displaydesc          NVARCHAR(2000) = NULL,
	@messagetypecd        NVARCHAR(256),
	@optinmandatoryind    BIT            = 0,
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

    IF @displayname IS NULL
	BEGIN
	    SET @displayname = @name
	END

    IF EXISTS (SELECT 1
               FROM [Reference].[SubscriptionType]
		       WHERE Name = @name)
    BEGIN
        UPDATE [Reference].[SubscriptionType]
        SET [Description]        = @desc
           ,[LastModifiedDate]   = GETDATE()
           ,[LastModifiedBy]     = @userid
           ,[ArchivedInd]        = @archivedind
           ,[AllowMultipleInd]   = @allowmultipleind
           ,[CaptureTimeInd]     = @capturetimeind
           ,[OptInDefault]       = @optindefaultind
           ,[DisplayName]        = @displayname
           ,[DisplayDescription] = @displaydesc
           ,[MessageTypeCd]      = @messagetypecd
           ,[OptInMandatoryInd]  = @optinmandatoryind
        WHERE Name = @name
	END 
    ELSE
    BEGIN
        INSERT INTO [Reference].[SubscriptionType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[AllowMultipleInd]
           ,[CaptureTimeInd]
           ,[OptInDefault]
           ,[DisplayName]
           ,[DisplayDescription]
           ,[MessageTypeCd]
           ,[OptInMandatoryInd])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,@archivedind
           ,@allowmultipleind
           ,@capturetimeind
           ,@optindefaultind
           ,@displayname
           ,@displaydesc
           ,@messagetypecd
           ,@optinmandatoryind)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = SubscriptionTypeID
	FROM   [Reference].[SubscriptionType]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END