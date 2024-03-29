USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[MSD_SalesOrderDetail_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[MSD_SalesOrderDetail_Insert]
(
	@userid         INTEGER = 0,   
	@return         INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @source              NVARCHAR(256)
    DECLARE @destinationtable    NVARCHAR(256) = 'Migration.MSD_SalesOrderDetail'
 	DECLARE @from                NVARCHAR(512)
    DECLARE @sql                 NVARCHAR(MAX)

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @source = [Reference].[Configuration_GetSetting] ('Migration','MSD Source Database') + '.' + 
	                 [Reference].[Configuration_GetSetting] ('Migration','MSD Source Schema') + '.'

	SELECT @destinationtable = [Reference].[Configuration_GetSetting] ('Migration','MSD Destination Database') + '.' +
                               @destinationtable

	SELECT @from = 'FROM ' + @source + 'SalesOrderDetailBase a, ' +
	               @source + 'SalesOrderDetailExtensionBase b ' +
				   'WHERE a.SalesOrderDetailID = b.SalesOrderDetailID '

	--Get the data    
                      
    SELECT @sql = 'INSERT INTO ' + @destinationtable + ' ' +
	              '([SalesOrderDetailId] ' +
                  ',[SalesOrderId] ' +
                  ',[ProductId] ' +
                  ',[Quantity] ' +
                  ',[PricePerUnit] ' +
                  ',[BaseAmount] ' +
                  ',[Description] ' +
                  ',[CreatedOn] ' +
                  ',[ModifiedOn] ' +
                  ',[out_deliverymethod] ' +
                  ',[out_productcategory] ' +
                  ',[out_traveldate] ' +
                  ',[out_RailCardType] ' +
                  ',[out_returndate] ' +
                  ',[out_status]) '

    SELECT @sql = @sql + 'SELECT a.[SalesOrderDetailId] ' +
	              ',a.[SalesOrderId] ' +
				  ',a.[ProductId] ' +
                  ',a.[Quantity] ' +
                  ',a.[PricePerUnit] ' +
                  ',a.[BaseAmount] ' +
                  ',a.[Description] ' +
                  ',a.[CreatedOn] ' +
                  ',a.[ModifiedOn] ' +
				  ',b.[out_deliverymethod] ' +
                  ',b.[out_productcategory] ' +
                  ',b.[out_traveldate] ' +
                  ',b.[out_RailCardType] ' +
                  ',b.[out_returndate] ' +
                  ',b.[out_status] ' +
				  @from

    EXEC @return = sp_executesql @stmt = @sql
	
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











GO
