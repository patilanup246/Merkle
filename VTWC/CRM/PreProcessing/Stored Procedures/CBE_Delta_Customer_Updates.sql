

CREATE PROCEDURE [PreProcessing].[CBE_Delta_Customer_Updates]
(
    @userid                INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @dataimporttype      NVARCHAR(256) = 'CBE Regular Import'

	DECLARE @spname              NVARCHAR(256)	
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER
	DECLARE @logmessage          NVARCHAR(MAX)

	DECLARE @dataimportlogid                  INTEGER
	DECLARE @dataimportdetailid               INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @dataimportlogid = DataImportLogID
	FROM   [Operations].[DataImportLog] a
	INNER JOIN [Reference].[OperationalStatus] b ON a.OperationalStatusID = b.OperationalStatusID
	INNER JOIN [Reference].[DataImportType] c ON c.DataImportTypeID = a.DataImportTypeID
	WHERE (b.Name = 'Processing' OR b.Name = 'Retrieving')
	AND   c.Name = @dataimporttype

    IF @dataimportlogid IS NULL OR @dataimportlogid !> 0
    BEGIN
	    SET @logmessage = 'No or invalid data import log reference.' + ISNULL(CAST(@dataimportdetailid AS NVARCHAR(256)),'NULL') 
	    
	    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	                                          @logsource       = @spname,
			    							  @logmessage      = @logmessage,
				    						  @logmessagelevel = 'ERROR',
						    				  @messagetypecd   = NULL
        RETURN
    END	

	/**CUSTOMERS**/

	DECLARE CBE_Customers CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_Customer a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid

        OPEN CBE_Customers

	    FETCH NEXT FROM CBE_Customers
		     INTO @dataimportdetailid

	   WHILE @@FETCH_STATUS = 0
       BEGIN

	       EXEC [PreProcessing].[CBE_Customers] @userid             = @userid,
                                                @dataimportdetailid = @dataimportdetailid
		
		   FETCH NEXT FROM CBE_Customers
		       INTO @dataimportdetailid
       END

	   CLOSE CBE_Customers
     
    DEALLOCATE CBE_Customers

/* 
	--/**ADDRESSES**/

	DECLARE Addresses CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_Address a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN Addresses

	    FETCH NEXT FROM Addresses
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_Address_Insert] @userid             = @userid,
	                                                  @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM Addresses
		        INTO @dataimportdetailid
        END

	    CLOSE Addresses
     
    DEALLOCATE Addresses

	--/***CUSTOMER LOYALTY***/

	DECLARE CustomerLoyalty CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_CustomerLoyalty a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN CustomerLoyalty

	    FETCH NEXT FROM CustomerLoyalty
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_CustomerLoyalty_Insert] @userid             = @userid,
	                                                          @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM CustomerLoyalty
		        INTO @dataimportdetailid
        END

	    CLOSE CustomerLoyalty
     
    DEALLOCATE CustomerLoyalty

	--/***SALES TRANSACTIONS***/

	DECLARE SalesTransactions CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_SalesTransaction a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN SalesTransactions

	    FETCH NEXT FROM SalesTransactions
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_SalesTransaction_Insert] @userid             = @userid,
	                                                           @dataimportdetailid = @dataimportdetailid
			
			EXEC [PreProcessing].[CBE_SalesTransaction_TVM_Insert] @userid              = @userid,
	                                                               @dataimportdetailid  = @dataimportdetailid

		    FETCH NEXT FROM SalesTransactions
		        INTO @dataimportdetailid
        END

	    CLOSE SalesTransactions
     
    DEALLOCATE SalesTransactions


	/***SALES DETAILS - TICKETS***/

	DECLARE SalesDetailTickets CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_Ticket a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN SalesDetailTickets

	    FETCH NEXT FROM SalesDetailTickets
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_SalesDetail_Ticket_Insert] @userid             = @userid,
	                                                             @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM SalesDetailTickets
		        INTO @dataimportdetailid
        END

	    CLOSE SalesDetailTickets
     
    DEALLOCATE SalesDetailTickets

	/***JOURNEYS***/

	DECLARE Journeys CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_JourneyDirection a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN Journeys

	    FETCH NEXT FROM Journeys
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_Journey_Insert] @userid             = @userid,
	                                                  @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM Journeys
		        INTO @dataimportdetailid
        END

	    CLOSE Journeys
     
    DEALLOCATE Journeys

	/***JOURNEY LEGS***/

	DECLARE JourneyLegs CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_JourneyLeg a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN JourneyLegs

	    FETCH NEXT FROM JourneyLegs
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_JourneyLeg_Insert] @userid             = @userid,
	                                                     @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM JourneyLegs
		        INTO @dataimportdetailid
        END

	    CLOSE JourneyLegs
     
    DEALLOCATE JourneyLegs

	/***SEAT RESERVATIONS***/

	DECLARE SeatReservations CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_SeatReservation a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN SeatReservations

	    FETCH NEXT FROM SeatReservations
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_SeatReservation_Insert] @userid             = @userid,
	                                                          @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM SeatReservations
		        INTO @dataimportdetailid
        END

	    CLOSE SeatReservations
     
    DEALLOCATE SeatReservations

    /***SALES DETAILS - SUPPLEMENTS***/

	DECLARE SalesDetailSupplements CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_SupplementSale a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog    c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN SalesDetailSupplements

	    FETCH NEXT FROM SalesDetailSupplements
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_SalesDetail_Supplement_Insert] @userid             = @userid,
	                                                                 @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM SalesDetailSupplements
		        INTO @dataimportdetailid
        END

	    CLOSE SalesDetailSupplements
     
    DEALLOCATE SalesDetailSupplements

    /***REFUNDS***/

	DECLARE Refunds CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_Refund a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog    c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN Refunds

	    FETCH NEXT FROM Refunds
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_Refund_Insert] @userid             = @userid,
	                                                                 @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM Refunds
		        INTO @dataimportdetailid
        END

	    CLOSE Refunds
     
    DEALLOCATE Refunds

    /***REFUND DETAILS***/

	DECLARE RefundDetails CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_RefundDetail a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog    c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN RefundDetails

	    FETCH NEXT FROM RefundDetails
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [PreProcessing].[CBE_RefundDetail_Insert] @userid = @userid,
	                                                       @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM RefundDetails
		        INTO @dataimportdetailid
        END

	    CLOSE RefundDetails
     
    DEALLOCATE RefundDetails

	/**Evoucher**/
	
	DECLARE Evouchers CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_EVoucher a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog    c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN Evouchers

	    FETCH NEXT FROM Evouchers
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    
			EXEC [PreProcessing].[CBE_EVoucherBatch_Insert] @userid = @userid,
	                                                        @dataimportdetailid = @dataimportdetailid
			
			
			
			EXEC [PreProcessing].[CBE_EVoucher_Insert] @userid = @userid,
	                                                   @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM Evouchers
		        INTO @dataimportdetailid
        END

	    CLOSE Evouchers
     
    DEALLOCATE Evouchers

	/**EVoucherTicket**/

	DECLARE EvoucherTickets CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_EVoucherTicket a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog    c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN EvoucherTickets

	    FETCH NEXT FROM EvoucherTickets
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    
			EXEC [PreProcessing].[CBE_EVoucherTicket_Insert] @userid = @userid,
	                                                        @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM EvoucherTickets
		        INTO @dataimportdetailid
        END

	    CLOSE EvoucherTickets
     
    DEALLOCATE EvoucherTickets

	/**EVoucherApplied**/

	DECLARE EvoucherApplied CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.CBE_EvoucherApplied a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog    c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
	    GROUP BY a.dataimportdetailid
	
	    OPEN EvoucherApplied

	    FETCH NEXT FROM EvoucherApplied
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		    
			EXEC [PreProcessing].[CBE_EVoucherApplied_Insert] @userid = @userid,
	                                                          @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM EvoucherApplied
		        INTO @dataimportdetailid
        END

	    CLOSE EvoucherApplied
     
    DEALLOCATE EvoucherApplied

	*/

    UPDATE a 
	SET  OperationalStatusID = b.OperationalStatusID
	    ,LastModifiedDate    = GETDATE()
	FROM [Operations].[DataImportLog] a
	INNER JOIN [Reference].[OperationalStatus] b ON b.Name = 'Completed'
	AND  a.DataImportLogID = @dataimportlogid


	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN
END