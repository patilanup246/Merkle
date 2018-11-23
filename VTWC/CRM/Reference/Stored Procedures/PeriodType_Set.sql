CREATE PROCEDURE [Reference].[PeriodType_Set]
(
	@userid                 INTEGER = 0,
	@name                   NVARCHAR(256),
	@displayname            NVARCHAR(256)  = NULL,
	@periodtypeid           INTEGER        = NULL,
	@periodtype             NVARCHAR(256)  = NULL,
	@desc                   NVARCHAR(4000) = NULL,
	@archivedind            BIT            = 0,
	@extreference           NVARCHAR(256)  = NULL,
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

    IF @periodtypeid IS NULL
	BEGIN
	    SELECT @periodtypeid = PeriodTypeID
		FROM   [Reference].[PeriodType]
		WHERE  Name = @periodtype
    END

    IF EXISTS (SELECT 1
               FROM [Reference].[PeriodType]
		    	WHERE Name = @name
				AND   (PeriodTypeIDParent = @periodtypeid
				       OR PeriodTypeIDParent IS NULL))
    BEGIN
        UPDATE [Reference].[PeriodType]
	    SET    Description      = @desc,
		       ArchivedInd      = @archivedind,
	           LastModifiedBy   = @userid,
		       LastModifiedDate = GETDATE(),
			   DisplayName      = CASE WHEN @displayname IS NULL THEN @name ELSE @displayname END,
			   ExtReference     = @extreference
	    WHERE  Name = @name
		AND    PeriodTypeIDParent = @periodtypeid
    END
    ELSE
    BEGIN
        INSERT INTO [Reference].[PeriodType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[DisplayName]
		   ,[PeriodTypeIDParent]
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
		   ,@periodtypeid
		   ,@extreference)

    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = PeriodTypeID
	FROM   [Reference].[PeriodType]
	WHERE  Name = @name
	AND    PeriodTypeIDParent = @periodtypeid

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END