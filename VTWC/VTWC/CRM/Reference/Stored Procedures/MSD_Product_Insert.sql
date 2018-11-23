CREATE PROCEDURE [Reference].[MSD_Product_Insert]
(
    @userid         INTEGER = 0,
	@return         INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @sourcetable         NVARCHAR(256) = 'ProductBase'
	DECLARE @destinationtable    NVARCHAR(256) = 'Reference.MSD_Product'
    DECLARE @sql                 NVARCHAR(MAX)

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @sourcetable = [Reference].[Configuration_GetSetting] ('Migration','MSD Source Database') + '.' + 
	                      [Reference].[Configuration_GetSetting] ('Migration','MSD Source Schema') + '.' +
                          @sourcetable

    --Add Product Types from MSD Metadata

	UPDATE a
	SET   Name = ValueName
	FROM  [Reference].[MSD_ProductType] a,
	      Reference.MSD_GetLookupValue_All ('Product','ProductTypeCode') b
    WHERE a.MSDProductTypeId = b.Value

    INSERT INTO [Reference].[MSD_ProductType]
           ([MSDProductTypeId]
           ,[Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd])
    SELECT Value
           ,ValueName
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
    FROM  Reference.MSD_GetLookupValue_All ('Product','ProductTypeCode')
    WHERE Value NOT IN (SELECT [MSDProductTypeId]
	                    FROM   [Reference].[MSD_ProductType])

    --Now for the Products

	SELECT @destinationtable = [Reference].[Configuration_GetSetting] ('Migration','MSD Destination Database') + '.' +
                               @destinationtable
     
    SELECT @sql = 'INSERT INTO ' + @destinationtable + ' ' +
                  '([ProductIdMSD] ' +
                  ',[Name] ' +
                  ',[Description] ' +
                  ',[ProductTypeCode] ' +
                  ',[ProductNumber] ' +
                  ',[CreatedOn] ' +
                  ',[ModifiedOn] ' +
                  ',[StateCode] ' +
                  ',[StatusCode] ' +
				  ',[MSDProductTypeId]) ' +
				  ' SELECT [ProductId] ' +
                  ',[Name] ' +
                  ',[Description] ' +
                  ',[ProductTypeCode] ' +
                  ',[ProductNumber] ' +
                  ',[CreatedOn] ' +
                  ',[ModifiedOn] ' +
                  ',[StateCode] ' +
                  ',[StatusCode] ' +
				  ',[ProductTypeCode] ' +
				  'FROM ' + @sourcetable + ' ' +
				  'WHERE [ProductId] NOT IN (SELECT [ProductIdMSD] FROM ' +  @destinationtable + ')'

    EXEC @return = sp_executesql @stmt = @sql
	print @sql
	SELECT @recordcount = @@ROWCOUNT

	--Log SQL statement
    
	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	                                      @logsource       = @spname,
										  @logmessage      = @sql,
										  @logmessagelevel = 'DEBUG',
										  @messagetypecd   = 'SQL Check'
	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT    
	RETURN
END