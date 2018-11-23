CREATE PROCEDURE [Reference].[InformationSource_Set]
(
	@userid         INTEGER = 0,
	@name           NVARCHAR(256),
	@desc           NVARCHAR(4000) = NULL,
	@displayname    NVARCHAR(256)  = NULL,
	@typecode       NVARCHAR(256),
	@prospectind    BIT            = NULL,
	@addinfo        NVARCHAR(4000) = NULL,
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
                   FROM [Reference].[InformationSource]
		    	   WHERE Name = @name)
    BEGIN
        INSERT INTO [Reference].[InformationSource]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[DisplayName]
           ,[TypeCode]
           ,[ProspectInd]
           ,[AdditionalInformation])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
		   ,@userid
           ,0
           ,@displayname
           ,@typecode
           ,@prospectind
           ,@addinfo)
    END
    ELSE
    BEGIN
        UPDATE [Reference].[InformationSource]
	    SET    Description           = @desc,
		       DisplayName           = @displayname,
			   TypeCode              = @typecode,
			   ProspectInd           = @prospectind,
			   AdditionalInformation = @addinfo,
	           LastModifiedBy        = @userid,
		       LastModifiedDate      = GETDATE()
	    WHERE  Name = @name
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = InformationSourceID
	FROM   [Reference].[InformationSource]
	WHERE  Name = @name

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END