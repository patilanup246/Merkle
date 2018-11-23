CREATE PROCEDURE [Reference].[FulfilmentMethod_Set]
(
	@userid                 INTEGER = 0,
	@name                   NVARCHAR(256),
	@desc                   NVARCHAR(4000) = NULL,
	@extreference           NVARCHAR(256)  = NULL,
	@informationsource      NVARCHAR(256)  = NULL,
	@informationsourceid    INTEGER        = NULL,
	@archivedind            BIT            = 0,
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
		AND    ArchivedInd = 0
    END

    IF NOT EXISTS (SELECT 1
                   FROM [Reference].[FulfilmentMethod]
		    	   WHERE Name = @name)
    BEGIN
        INSERT INTO [Reference].[FulfilmentMethod]
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
           ,0
		   ,@informationsourceid
		   ,@extreference)
    END
	ELSE
    BEGIN
        UPDATE [Reference].[FulfilmentMethod]
	    SET    Description         = @desc,
		       ArchivedInd         = @archivedind,
	           LastModifiedBy      = @userid,
		       LastModifiedDate    = GETDATE(),
			   InformationSourceID = @informationsourceid,
			   ExtReference        = @extreference
	    WHERE  Name = @name
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = FulfilmentMethodID
	FROM   [Reference].[FulfilmentMethod]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END