CREATE PROCEDURE [Reference].[TransactionStatus_Set]
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
                   FROM [Reference].[TransactionStatus]
		    	   WHERE Name = @name)
    BEGIN
        INSERT INTO [Reference].[TransactionStatus]
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
        UPDATE [Reference].[TransactionStatus]
	    SET    Description         = @desc,
	           LastModifiedBy      = @userid,
		       LastModifiedDate    = GETDATE(),
			   InformationSourceID = @informationsourceid,
			   ExtReference        = @extreference,
			   ArchivedInd         = @archivedind
	    WHERE  Name = @name
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = TransactionStatusID
	FROM   [Reference].[TransactionStatus]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END