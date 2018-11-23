
CREATE PROCEDURE [Reference].[AggregationType_Set]
(
	@userid               INTEGER        = 0,
	@name                 NVARCHAR(256),
	@desc                 NVARCHAR(4000) = NULL,
	@archivedind          BIT            = 0,
	@displayname          NVARCHAR(256)  = NULL,
	@displayorder         INTEGER        = NULL,
	@returnid             INTEGER OUTPUT
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
               FROM [Reference].[AggregationType]
		   	   WHERE Name = @name)
    BEGIN
        UPDATE [Reference].[AggregationType]
        SET    [Description]      = @desc
              ,[LastModifiedDate] = GETDATE()
              ,[LastModifiedBy]   = @userid
              ,[ArchivedInd]      = @archivedind
			  ,[DisplayName]      = CASE WHEN @displayname IS NULL THEN @name ELSE @displayname END
			  ,[DisplayOrder]     = @displayorder
        WHERE Name = @name
	END 
    ELSE
    BEGIN
        INSERT INTO [Reference].[AggregationType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[DisplayName]
		   ,[DisplayOrder]
		   )
        VALUES
           (@name
           ,@desc
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,@archivedind
		   ,CASE WHEN @displayname IS NULL THEN @name ELSE @displayname END
		   ,@displayorder)
    END

	SELECT @recordcount = @@ROWCOUNT

	SELECT @returnid = AggregationTypeID
	FROM   [Reference].[AggregationType]
	WHERE  Name = @name

	-- Create production view dynamically
	DECLARE @cols	AS NVARCHAR(MAX),
			@query  AS NVARCHAR(MAX)

	select @cols = STUFF((SELECT ', ' + QUOTENAME(Name) 
						from (select distinct isnull(DisplayOrder,9999) [DisplayOrder], name 
						from [Reference].[AggregationType]
						WHERE [ArchivedInd]=0) s
						order by isnull(DisplayOrder,9999), Name
				FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')

	set @query = 'alter view [Production].[vw_CustomerAggregations] WITH SCHEMABINDING as
	SELECT CustomerID, ' + @cols + ' from 
	(
		select a.CustomerID, b.Name, a.Result
		FROM  Staging.STG_CustomerAggregation a with(nolock)
		INNER JOIN Reference.AggregationType  b with(nolock) ON b.AggregationTypeID = a.AggregationTypeID
	) x
	pivot 
	(
		sum(Result)
		for Name in (' + @cols + ')
	) p '
	execute(@query)

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END