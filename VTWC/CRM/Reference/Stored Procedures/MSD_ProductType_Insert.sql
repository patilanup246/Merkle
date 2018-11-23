CREATE PROCEDURE [Reference].[MSD_ProductType_Insert]
(
	@userid         INTEGER = 0,   
	@return         INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @destinationtable    NVARCHAR(256) = 'Reference.MSD_ProductType'
    DECLARE @sql                 NVARCHAR(MAX)

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT


	--SELECT @destinationtable = [Reference].[Configuration_GetSetting] ('Migration','MSD Destination Database') + '.' +
 --                              @destinationtable
     
 --   SELECT @sql = 'INSERT INTO ' + @destinationtable + ' ' +
 --                 '([ProductTypeId] ' +
 --                 ',[Name]) '

 --   SELECT @sql = @sql + 'SELECT [Value] ' +
	--              ',[ValueName] ' +
	--			  'FROM [Reference].[MSD_GetLookupValue_All] (''Product'',''ProductTypeCode'') ' +
	--			  'WHERE [Value] NOT IN (SELECT [ProductTypeId] FROM ' + @destinationtable + ') '


 --   EXEC @return = sp_executesql @stmt = @sql

	SELECT @recordcount = @@ROWCOUNT

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT    
	RETURN
END