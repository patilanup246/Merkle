CREATE PROCEDURE [Reference].[LoyaltyProgrammeType_Set]
(
	@userid         INTEGER = 0,
	@name           NVARCHAR(256),
	@desc           NVARCHAR(4000) = NULL,
	@archivedind    BIT            = 0,
	@displayname    NVARCHAR(256)  = NULL,
	@extreference   NVARCHAR(256),
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


    IF EXISTS (SELECT 1
               FROM [Reference].[LoyaltyProgrammeType]
		  	   WHERE Name = @name)
    BEGIN
        UPDATE [Reference].[LoyaltyProgrammeType]
	    SET    Description      = @desc,
		       ArchivedInd      = @archivedind,
	           LastModifiedBy   = @userid,
		       LastModifiedDate = GETDATE(),
			   DisplayName      = CASE WHEN @displayname IS NULL THEN @name ELSE @displayname END,
			   ExtReference     = @extreference
	    WHERE  Name = @name
    END
    ELSE
    BEGIN
	    INSERT INTO [Reference].[LoyaltyProgrammeType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[DisplayName]
		   ,[ExtReference])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
		   ,@userid
           ,@archivedind
		   ,CASE WHEN @displayname IS NULL THEN @name ELSE @displayname END
		   ,@extreference)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = LoyaltyProgrammeTypeID
	FROM   [Reference].[LoyaltyProgrammeType]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END