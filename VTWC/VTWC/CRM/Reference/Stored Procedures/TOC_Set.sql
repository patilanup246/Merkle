CREATE PROCEDURE [Reference].[TOC_Set]
(
	@userid                INTEGER = 0,
	@name                  NVARCHAR(256),
	@desc                  NVARCHAR(4000) = NULL,
    @shortcode             NVARCHAR(16),
	@informataionsource    NVARCHAR(256) = NULL,
	@extreference          NVARCHAR(256) = NULL,
    @urlinformation        NVARCHAR(256) = NULL,
	@returnid              INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    IF @informataionsource IS NOT NULL
	BEGIN
	    SELECT @informationsourceid = InformationSourceID
		FROM   [Reference].[InformationSource]
		WHERE  Name = @informataionsource
 
        IF @informationsourceid IS NULL
		BEGIN
		    SELECT @returnid = -1

			RETURN
        END
    END

    IF EXISTS (SELECT 1
               FROM [Reference].[TOC]
		       WHERE ShortCode = @shortcode)
    BEGIN
        UPDATE [Reference].[TOC]
	    SET    Description         = @desc,
		       Name                = @name,
			   InformationSourceID = @informationsourceid,
			   ExtReference        = @extreference,
			   URLInformation      = @urlinformation,
	           LastModifiedBy      = @userid,
		       LastModifiedDate    = GETDATE()
	    WHERE  ShortCode = @shortcode
    END

    ELSE
    BEGIN
        INSERT INTO [Reference].[TOC]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[InformationSourceID]
		   ,[ExtReference]
		   ,[ShortCode]
		   ,[URLInformation])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
		   ,@userid
           ,0
		   ,@informationsourceid
		   ,@extreference
		   ,@shortcode
		   ,@urlinformation)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = TOCID
	FROM   [Reference].[TOC]
	WHERE  ShortCode = @shortcode

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END