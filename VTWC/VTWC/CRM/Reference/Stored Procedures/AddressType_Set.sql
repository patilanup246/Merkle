CREATE PROCEDURE [Reference].[AddressType_Set]
(
	@userid         INTEGER = 0,
	@name           NVARCHAR(256),
	@desc           NVARCHAR(4000) = NULL,   
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
                   FROM [Reference].[AddressType]
		    	   WHERE Name = @name)
    BEGIN
        INSERT INTO [Reference].[AddressType]
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
           ,0)
    END
    ELSE
    BEGIN
        UPDATE [Reference].[AddressType]
	    SET    Description      = @desc,
	           LastModifiedBy   = @userid,
		       LastModifiedDate = GETDATE()
	    WHERE  Name = @name
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = AddressTypeID
	FROM   [Reference].[AddressType]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END