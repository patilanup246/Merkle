CREATE PROCEDURE [Reference].[ModelSegment_Set]
(
	@userid                  INTEGER        = 0,
	@name                    NVARCHAR(256),
	@desc                    NVARCHAR(4000) = NULL,
	@archivedind             BIT            = 0,
	@modeldefinitionid       INTEGER,
	@segmentcode             NVARCHAR(256),
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

    IF EXISTS (SELECT 1
               FROM [Reference].[ModelSegment]
	           WHERE Name = @name
			   AND   ModelDefinitionID = @modeldefinitionid)
    BEGIN
        UPDATE [Reference].[ModelSegment]
	    SET    Description           = @desc,
		       ArchivedInd           = @archivedind,
	           LastModifiedBy        = @userid,
		       LastModifiedDate      = GETDATE(),
			   SegmentCode           = @segmentcode
	    WHERE  Name = @name
		AND    ModelDefinitionID = @modeldefinitionid
    END
	ELSE
    BEGIN
        INSERT INTO [Reference].[ModelSegment]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[ModelDefinitionID]
           ,[SegmentCode])
     VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,@archivedind
		   ,@modeldefinitionid
		   ,@segmentcode)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = ModelSegmentID
	FROM   [Reference].[ModelSegment]
	WHERE  Name = @name
	AND    ModelDefinitionID = @modeldefinitionid

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END