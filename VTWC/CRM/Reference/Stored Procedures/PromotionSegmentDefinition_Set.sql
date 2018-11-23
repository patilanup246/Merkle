
CREATE PROCEDURE [Reference].[PromotionSegmentDefinition_Set]
(
	@userid                  INTEGER        = 0,
	@name                    NVARCHAR(256),
	@desc                    NVARCHAR(4000) = NULL,
	@archivedind             BIT            = 0,
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
               FROM [Reference].[PromotionSegmentDefinition]
	           WHERE Name = @name)
    BEGIN
        UPDATE [Reference].[PromotionSegmentDefinition]
	    SET    Description           = @desc,
		       ArchivedInd           = @archivedind,
	           LastModifiedBy        = @userid,
		       LastModifiedDate      = GETDATE()
	    WHERE  Name = @name
    END
	ELSE
    BEGIN
        INSERT INTO [Reference].[PromotionSegmentDefinition]
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
           ,@archivedind)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = PromotionSegmentDefinitionID
	FROM   [Reference].[PromotionSegmentDefinition]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END