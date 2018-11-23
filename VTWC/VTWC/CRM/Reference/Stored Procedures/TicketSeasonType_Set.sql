CREATE PROCEDURE [Reference].[TicketSeasonType_Set]
(
	@userid               INTEGER = 0,
	@name                 NVARCHAR(256),
	@desc                 NVARCHAR(4000) = NULL,
	@archivedind          BIT            = 0,
	@informationsource    NVARCHAR(256) = NULL,
	@extreference         NVARCHAR(256) = NULL,
	@returnid             INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER

    SELECT @informationsourceid = InformationSourceID
	FROM   Reference.InformationSource
	WHERE  Name = @informationsource

    IF EXISTS (SELECT 1
               FROM [Reference].[TicketSeasonType]
		  	   WHERE Name = @name)
    BEGIN
        UPDATE [Reference].[ProductCategory]
	    SET    Description         = @desc,
		       ArchivedInd         = @archivedind,
			   InformationSourceID = @informationsourceid,
			   ExtReference        = @extreference,
	           LastModifiedBy      = @userid,
		       LastModifiedDate    = GETDATE()
	    WHERE  Name = @name
    END
    ELSE
    BEGIN
	    INSERT INTO [Reference].[TicketSeasonType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[InformationSourceID]
           ,[ExtReference])
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
		   ,@userid
           ,@archivedind
		   ,@informationsourceid
		   ,@extreference)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = TicketSeasonTypeID
	FROM   [Reference].[TicketSeasonType]
	WHERE  Name = @name

    RETURN
END