CREATE PROCEDURE [Reference].[MSD_StringMapBase_Refresh]
(
	@userid         INTEGER = 0,   
	@return         INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @sourcetable         NVARCHAR(256) = 'StringMapBase'
    DECLARE @destinationtable    NVARCHAR(256) = 'Reference.MSD_StringMapBase'
    DECLARE @sql                 NVARCHAR(MAX)
	
	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	--SELECT @sourcetable = [Reference].[Configuration_GetSetting] ('Migration','MSD Source Database') + '.' + 
	--                      [Reference].[Configuration_GetSetting] ('Migration','MSD Source Schema') + '.' +
 --                         @sourcetable

	--SELECT @destinationtable = [Reference].[Configuration_GetSetting] ('Migration','MSD Destination Database') + '.' +
 --                              @destinationtable

	----Cleardown destination table
	
	--SELECT @sql = 'DELETE FROM ' + @destinationtable

	--EXEC @return = sp_executesql @stmt = @sql

	--IF @return != 0
	--BEGIN
	--    RETURN
	--END

	----Get the data

 --   SELECT @sql ='INSERT INTO ' + @destinationtable + ' ' +
 --                 '([ObjectTypeCode] ' +
 --                 ',[AttributeName] ' +
	--              ',[AttributeValue] ' +
	--              ',[LangId] ' +
 --                 ',[OrganizationId] ' +
 --                 ',[Value] ' +
 --                 ',[DisplayOrder] ' +
 --                 ',[StringMapId]) '  +
 --                 'SELECT  [ObjectTypeCode] ' +
	--			  ',[AttributeName] ' +
 --                 ',[AttributeValue] ' +
 --                 ',[LangId] ' +
 --                 ',[OrganizationId] ' +
 --                 ',[Value] ' +
 --                 ',[DisplayOrder] ' +
 --                 ',[StringMapId] ' +
	--			  'FROM ' + @sourcetable

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