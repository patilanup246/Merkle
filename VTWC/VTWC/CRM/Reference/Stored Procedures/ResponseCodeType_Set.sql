CREATE PROCEDURE [Reference].[ResponseCodeType_Set]
(
	@userid                 INTEGER = 0,
	@name                   NVARCHAR(256),
	@desc                   NVARCHAR(4000) = NULL,
	@archivedind            BIT            = 0,
	@extreference           NVARCHAR(256)  = NULL,
	@informationsource      NVARCHAR(256)  = NULL,
	@informationsourceid    INTEGER        = NULL,
	@ishardbounceind        BIT            = NULL,
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


    IF NOT EXISTS (SELECT 1
                   FROM [Reference].[ResponseCodeType]
		    	   WHERE Name = @name)
    BEGIN
        INSERT INTO [Reference].[ResponseCodeType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[InformationSourceID]
		   ,[ExtReference]
		   ,[IsHardBounceInd])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
		   ,@userid
           ,@archivedind
		   ,@informationsourceid
		   ,@extreference
		   ,@ishardbounceind)
    END
    ELSE
    BEGIN
        UPDATE [Reference].[ResponseCodeType]
	    SET    Description           = @desc,
		       ArchivedInd           = @archivedind,
	           LastModifiedBy        = @userid,
		       LastModifiedDate      = GETDATE(),
			   InformationSourceID   = @informationsourceid,
			   ExtReference          = @extreference,
			   IsHardBounceInd       = @ishardbounceind
	    WHERE  Name = @name
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = ResponseCodeTypeID
	FROM   [Reference].[ResponseCodeType]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END