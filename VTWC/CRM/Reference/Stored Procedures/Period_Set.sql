CREATE PROCEDURE [Reference].[Period_Set]
(
	@userid                 INTEGER        = 0,
	@name                   NVARCHAR(256),
	@desc                   NVARCHAR(4000) = NULL,
	@archivedind            BIT            = 0,
	@displayname            NVARCHAR(256)  = NULL,
	@periodtypeid           INTEGER        = NULL,
	@periodtype             NVARCHAR(256)  = NULL,
	@datestart              DATETIME,
	@dateend                DATETIME,
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
               FROM [Reference].[Period]
		   	   WHERE Name = @name
			   AND   PeriodTypeID = @periodtypeid)
    BEGIN
        UPDATE [Reference].[Period]
        SET    [Description]      = @desc
              ,[LastModifiedDate] = GETDATE()
              ,[LastModifiedBy]   = @userid
              ,[ArchivedInd]      = @archivedind
			  ,[DisplayName]      = CASE WHEN @displayname IS NULL THEN @name ELSE @displayname END
			  ,[DateStart]        = @datestart
			  ,[DateEnd]          = @dateend
			  ,[ExtReference]     = @extreference
        WHERE Name = @name
		AND   PeriodTypeID = @periodtypeid
	END 
    ELSE
    BEGIN
        INSERT INTO [Reference].[Period]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[DisplayName]
		   ,[PeriodTypeID]
		   ,[DateStart]
		   ,[DateEnd]
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
		   ,@datestart
		   ,@dateend
		   ,@extreference)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = PeriodID
	FROM   [Reference].[Period]
	WHERE  Name = @name
	AND    PeriodTypeID = @periodtypeid

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END