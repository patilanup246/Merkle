CREATE PROCEDURE [Reference].[LocationAlias_Set]
(
	@userid         INTEGER = 0,
	@name           NVARCHAR(256),
	@desc           NVARCHAR(4000) = NULL,
	@locationid     INTEGER,
	@infosourceid   INTEGER,
	@prospectind    BIT            = NULL,
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
                   FROM [Reference].[LocationAlias]
		    	   WHERE Name = @name)
    BEGIN
        INSERT INTO [Reference].[LocationAlias]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[InformationSourceID]
           ,[LocationID])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
		   ,@userid
           ,0
           ,@infosourceid
           ,@locationid)
    END
    ELSE
    BEGIN
        UPDATE [Reference].[LocationAlias]
	    SET    Description           = @desc,
		       InformationSourceID   = @infosourceid,
			   LocationID			 = @locationid,
	           LastModifiedBy        = @userid,
		       LastModifiedDate      = GETDATE()
	    WHERE  Name = @name and InformationSourceID   = @infosourceid
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = LocationAliasID
	FROM   [Reference].[LocationAlias]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END