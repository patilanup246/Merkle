
CREATE PROCEDURE [PreProcessing].[CBE_Delta_Customer_Updates_Other]
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
	DECLARE @DataImportTypeID				INTEGER
	DECLARE @OperationalStatusPending 		INTEGER
	DECLARE @OperationalStatusProcessing 	INTEGER
	DECLARE @OperationalStatusCompleted 	INTEGER

	DECLARE @StartTimeImport				DATETIME
	DECLARE @endtime						DATETIME = GETDATE()
	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

SELECT @DataImportTypeID = DataImportTypeId 
FROM Reference.DataImportType
WHERE NAME = 'CBE Regular Import' 

SELECT @OperationalStatusPending = OperationalStatusId
FROM Reference.OperationalStatus
WHERE NAME = 'Pending'

SELECT @OperationalStatusProcessing = OperationalStatusId
FROM Reference.OperationalStatus
WHERE NAME = 'Processing'

SELECT @OperationalStatusCompleted = OperationalStatusId
FROM Reference.OperationalStatus
WHERE NAME = 'Completed'	 
	

DECLARE DataImportLogs CURSOR READ_ONLY
	FOR
	    SELECT Distinct(a.DataimportLogId) 
		FROM Operations.DataImportDetail a
		INNER JOIN Operations.DataImportLog b ON a.DataImportLogID = b.DataImportLogId
		WHERE (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
		AND b.DataimportTypeId = @DataimportTypeId 
		AND b.OperationalStatusID = @OperationalStatusCompleted
		AND DATEADD(dd,4,a.CreatedDate) >= GETDATE()
		ORDER BY a.DataImportLogID 
		
		OPEN DataImportLogs

		FETCH NEXT FROM DataImportLogs
		    INTO @dataimportlogid

	    WHILE @@FETCH_STATUS = 0
        BEGIN

		--/**ADDRESSES**/
					IF EXISTS (SELECT 1 
						FROM  Operations.DataImportDetail a
						WHERE a.DataImportLogID = @dataimportlogid
						AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
						AND a.NAME = 'CBE Address')
						BEGIN
	    	
								SELECT @dataimportdetailid = a.dataimportdetailid 
								FROM  Operations.DataImportDetail a
								WHERE a.DataImportLogID = @dataimportlogid
								AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
								AND a.NAME = 'CBE Address'

								EXEC [PreProcessing].[CBE_Address_Insert] @userid             = @userid,
													                      @dataimportdetailid = @dataimportdetailid
						END

					/***Loyalty***/
					IF EXISTS (SELECT 1 
						FROM  Operations.DataImportDetail a
						WHERE a.DataImportLogID = @dataimportlogid
						AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
						AND a.NAME = 'CBE CustomerLoyalty')
						BEGIN
	    	
								SELECT @dataimportdetailid = a.dataimportdetailid 
								FROM  Operations.DataImportDetail a
								WHERE a.DataImportLogID = @dataimportlogid
								AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
								AND a.NAME = 'CBE CustomerLoyalty'

								EXEC [PreProcessing].[CBE_CustomerLoyalty_Insert] @userid             = @userid,
													                              @dataimportdetailid = @dataimportdetailid
						END

					/***SalesTransaction***/
					IF EXISTS (SELECT 1 
						FROM  Operations.DataImportDetail a
						WHERE a.DataImportLogID = @dataimportlogid
						AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
						AND a.NAME = 'CBE SalesTransaction')
						BEGIN
	    	
								SELECT @dataimportdetailid = a.dataimportdetailid 
								FROM  Operations.DataImportDetail a
								WHERE a.DataImportLogID = @dataimportlogid
								AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
								AND a.NAME = 'CBE SalesTransaction'

									EXEC [PreProcessing].[CBE_SalesTransaction_Insert]		@userid             = @userid,
																							@dataimportdetailid = @dataimportdetailid
			
									EXEC [PreProcessing].[CBE_SalesTransaction_TVM_Insert]	@userid              = @userid,
																							@dataimportdetailid  = @dataimportdetailid
						END
							 		
					/***SALES DETAILS***/
					IF EXISTS (SELECT 1 
						FROM  Operations.DataImportDetail a
						WHERE a.DataImportLogID = @dataimportlogid
						AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
						AND a.NAME = 'CBE Ticket')
						BEGIN
	    	
								SELECT @dataimportdetailid = a.dataimportdetailid 
								FROM  Operations.DataImportDetail a
								WHERE a.DataImportLogID = @dataimportlogid
								AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
								AND a.NAME = 'CBE Ticket'

								EXEC [PreProcessing].[CBE_SalesDetail_Ticket_Insert] @userid             = @userid,
													                                 @dataimportdetailid = @dataimportdetailid
						END

					/***JOURNEYS***/
					IF EXISTS (SELECT 1 
						FROM  Operations.DataImportDetail a
						WHERE a.DataImportLogID = @dataimportlogid
						AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
						AND a.NAME = 'CBE Journey Direction')
						BEGIN
	    	
								SELECT @dataimportdetailid = a.dataimportdetailid 
								FROM  Operations.DataImportDetail a
								WHERE a.DataImportLogID = @dataimportlogid
								AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
								AND a.NAME = 'CBE Journey Direction'

								EXEC [PreProcessing].[CBE_Journey_Insert]			@userid             = @userid,
													                                @dataimportdetailid = @dataimportdetailid
						END			
						
					/***JOURNEY LEGS***/
					IF EXISTS (SELECT 1 
						FROM  Operations.DataImportDetail a
						WHERE a.DataImportLogID = @dataimportlogid
						AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
						AND a.NAME = 'CBE JourneyLeg')
						BEGIN
	    	
								SELECT @dataimportdetailid = a.dataimportdetailid 
								FROM  Operations.DataImportDetail a
								WHERE a.DataImportLogID = @dataimportlogid
								AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
								AND a.NAME = 'CBE JourneyLeg'

								EXEC [PreProcessing].[CBE_JourneyLeg_Insert]		@userid             = @userid,
													                                @dataimportdetailid = @dataimportdetailid
						END		

					/***SEAT RESERVATIONS***/
					IF EXISTS (SELECT 1 
						FROM  Operations.DataImportDetail a
						WHERE a.DataImportLogID = @dataimportlogid
						AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
						AND a.NAME = 'CBE SeatReservation')
						BEGIN
	    	
								SELECT @dataimportdetailid = a.dataimportdetailid 
								FROM  Operations.DataImportDetail a
								WHERE a.DataImportLogID = @dataimportlogid
								AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
								AND a.NAME = 'CBE SeatReservation'

								EXEC [PreProcessing].[CBE_SeatReservation_Insert]		@userid             = @userid,
																					    @dataimportdetailid = @dataimportdetailid
						END
							
					/***SALES DETAILS - SUPPLEMENTS***/
					IF EXISTS (SELECT 1 
						FROM  Operations.DataImportDetail a
						WHERE a.DataImportLogID = @dataimportlogid
						AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
						AND a.NAME = 'CBE SupplementSale')
						BEGIN
	    	
								SELECT @dataimportdetailid = a.dataimportdetailid 
								FROM  Operations.DataImportDetail a
								WHERE a.DataImportLogID = @dataimportlogid
								AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
								AND a.NAME = 'CBE SupplementSale'

								EXEC [PreProcessing].[CBE_SalesDetail_Supplement_Insert]		@userid             = @userid,
																								@dataimportdetailid = @dataimportdetailid
						END	
 
					/***REFUNDS***/
					IF EXISTS (SELECT 1 
						FROM  Operations.DataImportDetail a
						WHERE a.DataImportLogID = @dataimportlogid
						AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
						AND a.NAME = 'CBE Refund')
						BEGIN
	    	
								SELECT @dataimportdetailid = a.dataimportdetailid 
								FROM  Operations.DataImportDetail a
								WHERE a.DataImportLogID = @dataimportlogid
								AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
								AND a.NAME = 'CBE Refund'

								EXEC [PreProcessing].[CBE_Refund_Insert]						@userid             = @userid,
																								@dataimportdetailid = @dataimportdetailid
						END	
	
					/***REFUND DETAILS***/	
					IF EXISTS (SELECT 1 
					FROM  Operations.DataImportDetail a
					WHERE a.DataImportLogID = @dataimportlogid
					AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
					AND a.NAME = 'CBE Refund Detail')
					BEGIN
	    	
							SELECT @dataimportdetailid = a.dataimportdetailid 
							FROM  Operations.DataImportDetail a
							WHERE a.DataImportLogID = @dataimportlogid
							AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
							AND a.NAME = 'CBE Refund Detail'

							EXEC [PreProcessing].[CBE_RefundDetail_Insert]					@userid             = @userid,
																							@dataimportdetailid = @dataimportdetailid
					END	

					/**EvouchersBatch**/
					IF EXISTS (SELECT 1 
					FROM  Operations.DataImportDetail a
					WHERE a.DataImportLogID = @dataimportlogid
					AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
					AND a.NAME = 'CBE EVouchersBatch')
					BEGIN
	    	
							SELECT @dataimportdetailid = a.dataimportdetailid 
							FROM  Operations.DataImportDetail a
							WHERE a.DataImportLogID = @dataimportlogid
							AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
							AND a.NAME = 'CBE EVouchersBatch'

							EXEC [PreProcessing].[CBE_EVoucherBatch_Insert]		@userid = @userid,
																				@dataimportdetailid = @dataimportdetailid
																	   
					END	

					/**Evoucher**/
					IF EXISTS (SELECT 1 
					FROM  Operations.DataImportDetail a
					WHERE a.DataImportLogID = @dataimportlogid
					AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
					AND a.NAME = 'CBE EVoucher')
					BEGIN
	    	
							SELECT @dataimportdetailid = a.dataimportdetailid 
							FROM  Operations.DataImportDetail a
							WHERE a.DataImportLogID = @dataimportlogid
							AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
							AND a.NAME = 'CBE EVoucher'

							EXEC [PreProcessing].[CBE_EVoucher_Insert]			@userid = @userid,
																				@dataimportdetailid = @dataimportdetailid
													   
					END	

					/**EVoucherTicket**/
					IF EXISTS (SELECT 1 
					FROM  Operations.DataImportDetail a
					WHERE a.DataImportLogID = @dataimportlogid
					AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
					AND a.NAME = 'CBE EVoucherTicket')
					BEGIN
	    	
							SELECT @dataimportdetailid = a.dataimportdetailid 
							FROM  Operations.DataImportDetail a
							WHERE a.DataImportLogID = @dataimportlogid
							AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
							AND a.NAME = 'CBE EVoucherTicket'

							EXEC [PreProcessing].[CBE_EVoucherTicket_Insert]	@userid = @userid,
																				@dataimportdetailid = @dataimportdetailid
																		   
					END	

					/**EVoucherApplied**/
										IF EXISTS (SELECT 1 
					FROM  Operations.DataImportDetail a
					WHERE a.DataImportLogID = @dataimportlogid
					AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
					AND a.NAME = 'CBE EvoucherApplied')
					BEGIN
	    	
							SELECT @dataimportdetailid = a.dataimportdetailid 
							FROM  Operations.DataImportDetail a
							WHERE a.DataImportLogID = @dataimportlogid
							AND (a.OperationalStatusID = @OperationalStatusPending OR a.OperationalStatusID = @OperationalStatusProcessing)
							AND a.NAME = 'CBE EvoucherApplied'

							EXEC [PreProcessing].[CBE_EVoucherApplied_Insert]	@userid = @userid,
																				@dataimportdetailid = @dataimportdetailid
																		   
					END	


		    EXEC [Operations].[DataImportLog_Update] @userid                = @userid,
	                                                 @dataimportlogid       = @dataimportlogid,
	                                                 @operationalstatusname = 'Completed',
                                                     @endtimeimport         = @endtime


													 		  	  
			FETCH NEXT FROM DataImportLogs
		       INTO @dataimportlogid
        END

	    CLOSE DataImportLogs
     
    DEALLOCATE DataImportLogs

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN
END