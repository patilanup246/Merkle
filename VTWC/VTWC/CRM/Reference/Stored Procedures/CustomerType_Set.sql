CREATE PROCEDURE [Reference].[CustomerType_Set]
(
	@userid                  INTEGER        = 0,
	@name                    NVARCHAR(256),
	@desc                    NVARCHAR(4000) = NULL,
	@archivedind             BIT            = 0,
	@customertypeparent      NVARCHAR(256)  = NULL,
	@customertypeparentid    INTEGER        = NULL,
	@typeorder               INTEGER        = NULL,
	@returnid                INTEGER OUTPUT
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

    IF @customertypeparent IS NOT NULL
    BEGIN
        SELECT @customertypeparentid = CustomerTypeID
	    FROM   [Reference].[CustomerType]
	    WHERE  Name = @customertypeparent

        IF @typeorder IS NULL
        BEGIN
            SELECT @typeorder = ISNULL(MAX(TypeOrder),0) + 1
	        FROM   [Reference].[CustomerType]
	        WHERE  CustomerTypeIDParent = @customertypeparentid
        END
    END

    IF NOT EXISTS (SELECT 1
                   FROM [Reference].[CustomerType]
	               WHERE Name = @name
		           AND   CustomerTypeIDParent = @customertypeparentid)
    BEGIN
        INSERT INTO [Reference].[CustomerType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[CustomerTypeIDParent]
		   ,[TypeOrder])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
		   ,@userid
           ,@archivedind
		   ,@customertypeparentid
		   ,@typeorder)
    END
    ELSE
    BEGIN
        UPDATE [Reference].[CustomerType]
	    SET    Description           = @desc,
		       ArchivedInd           = @archivedind,
	           LastModifiedBy        = @userid,
		       LastModifiedDate      = GETDATE(),
			   CustomerTypeIDParent  = @customertypeparentid,
			   TypeOrder             = @typeorder
	    WHERE  Name = @name
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = CustomerTypeID
	FROM   [Reference].[CustomerType]
	WHERE  Name = @name
	AND    (CustomerTypeIDParent IS NULL
	        OR CustomerTypeIDParent = @customertypeparentid)

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END