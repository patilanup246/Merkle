USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[MSD_SalesOrder_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[MSD_SalesOrder_Insert]
(
    @userid         INTEGER = 0,
	@return         INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @source              NVARCHAR(256)
    DECLARE @destinationtable    NVARCHAR(256) = 'Migration.MSD_SalesOrder'
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
   
    --Get data
    SELECT @source = [Reference].[Configuration_GetSetting] ('Migration','MSD Source Database') + '.' + 
	                 [Reference].[Configuration_GetSetting] ('Migration','MSD Source Schema') + '.'

	SELECT @destinationtable = [Reference].[Configuration_GetSetting] ('Migration','MSD Destination Database') + '.' +
                               @destinationtable


	SELECT @from = 'FROM ' + @source + 'SalesOrderBase a, ' +
	               @source + 'SalesOrderExtensionBase b ' +
				   'WHERE a.SalesOrderID = b.SalesOrderID '
     
    SELECT @sql = 'INSERT INTO ' + @destinationtable + ' ' +
                  '([SalesOrderId] ' +
                  ',[ContactId] ' +
                  ',[OrderNumber] ' +
                  ',[Name] ' +
                  ',[Description] ' +
                  ',[TotalAmount] ' +
                  ',[CreatedOn] ' +
                  ',[ModifiedOn] ' +
                  ',[ShipTo_Line1] ' +
                  ',[ShipTo_Line2] ' +
                  ',[ShipTo_Line3] ' +
                  ',[out_shipto_line4] ' +
                  ',[out_shipto_line5] ' +
                  ',[ShipTo_City] ' +
                  ',[ShipTo_StateOrProvince] ' +
                  ',[ShipTo_Country] ' +
                  ',[ShipTo_PostalCode] ' +
                  ',[BillTo_Line1] ' +
                  ',[BillTo_Line2] ' +
                  ',[BillTo_Line3] ' +
                  ',[out_billto_line4] ' +
                  ',[out_billto_line5] ' +
                  ',[BillTo_City] ' +
                  ',[BillTo_StateOrProvince] ' +
                  ',[BillTo_Country] ' +
                  ',[BillTo_PostalCode] ' +
                  ',[out_bookingmethod] ' +
                  ',[out_bookingsourceId] ' +
                  ',[out_deliverymethod] ' +
                  ',[out_numberadults] ' +
                  ',[out_numberchildren] ' +
                  ',[out_orderfulfilmentdate] ' +
                  ',[out_orderplacedate] ' +
                  ',[out_webtisbookingid] ' +
                  ',[out_status] ' +
                  ',[out_supersales] ' +
                  ',[out_paymentcardtype] ' +
                  ',[out_purchasemethod] ' +
                  ',[out_purchasemethod1] ' +
                  ',[out_purchasemethod2] ' +
                  ',[out_purchasemethod3] ' +
                  ',[out_totalbasketvalue] ' +
                  ',[out_totalnonrailbasketvalue] ' +
                  ',[out_totalrailbasketvalue] ' +
                  ',[out_journeyorigin] ' +
                  ',[out_journeydestination] ' +
                  ',[out_route] ' +
                  ',[out_outlegclass] ' +
                  ',[out_outretailserviceids] ' +
                  ',[out_outseatreservations] ' +
                  ',[out_outserviceoperators] ' +
                  ',[out_outTOCdestination] ' +
                  ',[out_outTOCorigin] ' +
                  ',[out_retlegclass] ' +
                  ',[out_retretailserviceids] ' +
                  ',[out_retseatreservations] ' +
                  ',[out_retserviceoperators] ' +
                  ',[out_retTOCorigin] ' +
                  ',[out_retTOCdestination]) '

        SELECT @sql = @sql + 'SELECT a.[SalesOrderId] ' +
                  ',a.[CustomerId] ' +
                  ',a.[OrderNumber] ' +
                  ',a.[Name] ' +
                  ',a.[Description] ' +
                  ',a.[TotalAmount] ' +
                  ',a.[CreatedOn] ' +
                  ',a.[ModifiedOn] ' +
                  ',a.[ShipTo_Line1] ' +
                  ',a.[ShipTo_Line2] ' +
                  ',a.[ShipTo_Line3] ' +
                  ',b.[out_shipto_line4] ' +
                  ',b.[out_shipto_line5] ' +
                  ',a.[ShipTo_City] ' +
                  ',a.[ShipTo_StateOrProvince] ' +
                  ',a.[ShipTo_Country] ' +
                  ',a.[ShipTo_PostalCode] ' +
                  ',a.[BillTo_Line1] ' +
                  ',a.[BillTo_Line2] ' +
                  ',a.[BillTo_Line3] ' +
                  ',b.[out_billto_line4] ' +
                  ',b.[out_billto_line5] ' +
                  ',a.[BillTo_City] ' +
                  ',a.[BillTo_StateOrProvince] ' +
                  ',a.[BillTo_Country] ' +
                  ',a.[BillTo_PostalCode] ' +
                  ',b.[out_bookingmethod] ' +
                  ',b.[out_bookingsourceId] ' +
                  ',b.[out_deliverymethod] ' +
                  ',b.[out_numberadults] ' +
                  ',b.[out_numberchildren] ' +
                  ',b.[out_orderfulfilmentdate] ' +
                  ',b.[out_orderplacedate] ' +
                  ',b.[out_webtisbookingid] ' +
                  ',b.[out_status] ' +
                  ',b.[out_supersales] ' +
                  ',b.[out_paymentcardtype] ' +
                  ',b.[out_purchasemethod] ' +
                  ',b.[out_purchasemethod1] ' +
                  ',b.[out_purchasemethod2] ' +
                  ',b.[out_purchasemethod3] ' +
                  ',b.[out_totalbasketvalue] ' +
                  ',b.[out_totalnonrailbasketvalue] ' +
                  ',b.[out_totalrailbasketvalue] ' +
                  ',b.[out_journeyorigin] ' +
                  ',b.[out_journeydestination] ' +
                  ',b.[out_route] ' +
                  ',b.[out_outlegclass] ' +
                  ',b.[out_outretailserviceids] ' +
                  ',b.[out_outseatreservations] ' +
                  ',b.[out_outserviceoperators] ' +
                  ',b.[out_outTOCdestination] ' +
                  ',b.[out_outTOCorigin] ' +
                  ',b.[out_retlegclass] ' +
                  ',b.[out_retretailserviceids] ' +
                  ',b.[out_retseatreservations] ' +
                  ',b.[out_retserviceoperators] ' +
                  ',b.[out_retTOCorigin] ' +
                  ',b.[out_retTOCdestination] ' +
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
