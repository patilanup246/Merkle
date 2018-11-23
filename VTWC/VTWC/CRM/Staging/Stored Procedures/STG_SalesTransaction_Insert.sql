
/*===========================================================================================
Name:			STG_SalesTransaction_Insert
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		USINARI
Modified:		

Peer Review:	
Call script:	e.g, EXEC Staging.STG_SalesTransaction_Insert 0, 429
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_SalesTransaction_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	DECLARE @importfilename				NVARCHAR(256)
	
	DECLARE @dataimportdetailid_Journey INTEGER 

	
	DECLARE @StepName                 NVARCHAR(280)
	DECLARE @ProcName						 NVARCHAR(256)
	DECLARE @DbName				       NVARCHAR(256) 
	DECLARE @AuditType				       NVARCHAR(256) 
	DECLARE @SpId							 INT 
	
	
	DECLARE @DebugPrint					INT = 0

	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	SELECT @DbName = DB_NAME()
	SELECT @SpId = @@SPID
	SELECT @AuditType = 'PROCESS START'
	SELECT @StepName = 'Staging.STG_SalesTransaction_Insert ProcedureStart'

	
	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC uspSSISProcStepStart @spname, @StepName

	
	BEGIN TRY
	BEGIN TRANSACTION

	
	SELECT @dataimportdetailid_Journey = DataImportDetailID FROM operations.DataImportDetail k
	WHERE ([name] = 'TOC Plus Journey')
	AND EXISTS(SELECT DataImportLogID FROM operations.DataImportDetail b 
	WHERE k.dataimportlogid = b.dataimportlogid AND b.DataImportDetailID = @dataimportdetailid)
	
		
	--Log start time--
	
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT
										 
    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Trainline'

	
	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

											  COMMIT TRANSACTION
											  RETURN
    END

   SELECT @now = GETDATE()
	
	SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid


	SELECT @StepName = 'DataImportDetail_Update'

	--EXEC dbo.uspSSISProcStepStart @spname, @StepName

	EXEC [Operations].[DataImportDetail_Update] @userid            = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
												           @importfilename = @importfilename,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

	--EXEC dbo.uspSSISProcStepSuccess @spname, @StepName
		
	UPDATE a
	SET 
	     LastModifiedDate = GETDATE()
        ,LastModifiedBy = 1  
        ,ArchivedInd = 0 
		,SalesTransactionDate = b.transactiondate
		,SalesAmountTotal = b.totalcostofallpurchases
        ,FulfilmentMethodID = d.FulfilmentMethodID 
		,FulfilmentDate = b.DateCreated --,Staging.SetUKTime(a.DateCreated)
		,SalesTransactionNumber = b.TOCTransactionID  
		,paymenttype = b.paymenttype
		,cardtype = b.cardtype
		,voucherused = b.voucherused
		,channelcode = b.channelcode
		,LastModifiedExtractNumber = @dataimportdetailid

	FROM [Staging].[STG_SalesTransaction] a
	INNER JOIN [PreProcessing].[TOCPLUS_Transaction] b ON (a.ExtReference = CAST(b.tcstransactionid AS NVARCHAR(256)))
	LEFT  JOIN Reference.FulfilmentMethod  d ON (b.originatingsystemtype + ' ' + b.originatingsystem) = (d.Name)
					     								             AND  d.InformationSourceID = @informationsourceid
	WHERE b.tcscustomerid IS NOT NULL 
	AND   b.DataImportDetailID = @dataimportdetailid  and b.DataImportDetailID is not null
	AND   b.ProcessedInd = 0
    AND   a.SourceModifiedDate <= b.Dateupdated
	
											
    INSERT INTO [Staging].[STG_SalesTransaction]
           (
				 [Name]
				,[Description]
				,CreatedDate
				,CreatedBy
				,LastModifiedDate
				,LastModifiedBy
				,ArchivedInd
				,SourceCreatedDate
			   ,SourceModifiedDate
				,SalesTransactionDate
				,SalesAmountTotal
				,LoyaltyReference
				,RetailChannelID
				,LocationID
				,CustomerID
				,IndividualID
				,ExtReference
				,InformationSourceID
				,BookingReference
				,FulfilmentMethodID
				,NumberofAdults
				,NumberofChildren
				,FulfilmentDate
				,SalesAmountNotRail
				,SalesAmountRail
				,BookingReferenceLong
				,BookingSourceCd
				,LoyaltySchemeName
				,LoyaltyProgrammeTypeID
				,SalesTransactionNumber
				,paymenttype
				,cardtype
				,voucherused
				,channelcode
				,CreatedExtractNumber
				,LastModifiedExtractNumber
		   )
    
	SELECT      
			NULL AS "Name"
           ,NULL AS "Description"
           ,GETDATE() AS CreatedDate
           ,@userid AS CreatedBy
           ,GETDATE() AS LastModifiedDate
           ,@userid AS LastModifiedBy
           ,0 AS ArchivedInd
			  ,a.DateCreated AS SourceCreatedDate --,Staging.SetUKTime(a.DateCreated)
			  ,a.DateUpdated AS SourceModifiedDate --,Staging.SetUKTime(a.LastModifiedDateETL)
           ,a.transactiondate AS SalesTransactionDate --,Staging.SetUKTime(a.transactiondate)
           ,a.totalcostofallpurchases AS SalesAmountTotal
           ,null AS LoyaltyReference
           ,NULL AS RetailChannelID --c.RetailChannelID
           ,NULL AS LocationID
           ,b.CustomerID AS CustomerID
           ,NULL AS IndividualID
           ,CAST(a.tcstransactionid AS NVARCHAR(256)) as ExtReference
           ,@informationsourceid as InformationSourceID
			  ,NULL AS BookingReference --SUBSTRING(a.Name,1,CHARINDEX('-',a.Name,1)-1) 
			  ,d.FulfilmentMethodID AS FulfilmentMethodID
			  ,NULL AS NumberofAdults --f.totaladults 
			  ,NULL AS NumberofChildren --f.totalchildren a.[out_numberchildren]
			  ,a.DateCreated AS FulfilmentDate--,Staging.SetUKTime(a.DateCreated)
			  ,NULL AS SalesAmountNotRail --a.[out_totalnonrailbasketvalue]
			  ,NULL AS SalesAmountRail --a.[out_totalrailbasketvalue]
			  ,NULL AS BookingReferenceLong --f.tcsbookingid
		     ,NULL AS BookingSourceCd --a.[out_bookingsourceId]
		     ,NULL AS LoyaltySchemeName -- f.channelcode AS LoyaltySchemeNam
 		     ,NULL AS LoyaltyProgrammeTypeID
		     ,a.TOCTransactionID AS SalesTransactionNumber
			 ,a.paymenttype
			 ,a.cardtype
			 ,a.voucherused
			 ,a.channelcode
			 ,@dataimportdetailid
			 ,@dataimportdetailid

		   
		FROM  [PreProcessing].[TOCPLUS_Transaction] a --PreProcessing.MSD_SalesOrder a
				INNER JOIN Staging.STG_KeyMapping        b ON a.[tcscustomerid] = b.[tcsCustomerID] and (b.IsParentInd =1) 
				LEFT  JOIN Reference.FulfilmentMethod    d ON (a.originatingsystemtype + ' ' + a.originatingsystem) = (d.Name)
					     								             AND  d.InformationSourceID = @informationsourceid
		--		LEFT  JOIN PreProcessing.TOCPLUS_Journey f ON (a.tcstransactionid = f.tcstransactionid) ---and (f.DataImportDetailID = @dataimportdetailid_Journey)
		WHERE a.tcscustomerid IS NOT NULL --AND b.CustomerID IS NOT NULL
		AND   a.DataImportDetailID = @dataimportdetailid  and a.DataImportDetailID is not null
		AND   a.ProcessedInd = 0
		AND  NOT EXISTS (SELECT Extreference FROM staging.stg_salestransaction k WHERE CAST(a.tcstransactionid AS NVARCHAR(256)) = k.ExtReference)

		--Added to address Duplicate tcstransactionid issue in the same feed
		AND a.TOCTransactionID = (
											SELECT MAX(TOCTransactionID) 
												FROM  [PreProcessing].[TOCPLUS_Transaction] a1 --PreProcessing.MSD_SalesOrder a
												WHERE a1.tcscustomerid IS NOT NULL --AND b.CustomerID IS NOT NULL
												AND   a1.DataImportDetailID = @dataimportdetailid  and a1.DataImportDetailID is not null
												AND   a1.ProcessedInd = 0
												AND a1.tcstransactionid = a.tcstransactionid
										)



	UPDATE a
	SET  ProcessedInd = 1, LastModifiedDateETL =GETDATE()
	FROM PreProcessing.TOCPLUS_Transaction a
	INNER JOIN Staging.STG_KeyMapping  b ON a.[tcscustomerid] = b.[tcsCustomerID]
	--INNER JOIN Staging.STG_SalesTransaction  c ON CAST(a.tcstransactionid AS NVARCHAR(256)) = c.ExtReference
	AND   a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

	--SELECT @recordcount = @@ROWCOUNT


	--Set minimum sales transaction date for Date first purchase in STG_Customer
	UPDATE a
    SET DateFirstPurchase = b.LatestDate
	   ,LastModifiedDate  = GETDATE()
    FROM [Staging].[STG_Customer] a
    INNER JOIN (SELECT CustomerID,
                       MIN([SalesTransactionDate]) AS LatestDate
                FROM   [Staging].[STG_SalesTransaction]
			    GROUP  BY CustomerID) b
            ON  a.CustomerID = b.CustomerID
    --WHERE a.DateFirstPurchase IS NULL


	--Set maximum sales transaction date for Date Last Purchased in STG_Customer
	UPDATE a
    SET DateLastPurchase = b.LatestDate
	   ,LastModifiedDate  = GETDATE()
    FROM [Staging].[STG_Customer] a
    INNER JOIN (SELECT CustomerID,
                       MAX([SalesTransactionDate]) AS LatestDate
                FROM   [Staging].[STG_SalesTransaction]
			    GROUP  BY CustomerID) b
            ON  a.CustomerID = b.CustomerID
	--WHERE a.DateLastPurchase<b.LatestDate



			
	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.TOCPLUS_Transaction
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid


	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Transaction
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

	SELECT @StepName = 'Data Import Detail Update'

	--EXEC uspSSISProcStepStart @spname, @StepName

	
	EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
															  @importfilename = @importfilename,
	                                            @starttimeimport       = NULL,
	                                            @endtimeimport         = @now,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = @successcountimport,
	                                            @errorcountimport      = @errorcountimport

    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

	COMMIT TRANSACTION
	---EXEC dbo.uspSSISProcStepSuccess @spname, @StepName		
	
	END TRY
	BEGIN CATCH  
	 DECLARE   
	  @ErrorMessage VARCHAR(4000),  
	  @ErrorNumber INT,  
	  @ErrorSeverity INT,  
	  @ErrorState INT,  
	  @ErrorLine INT,  
	  @ErrorProcedure VARCHAR(126);  
  
  
	  ROLLBACK TRANSACTION;
	 SELECT   
	  @ErrorNumber = ERROR_NUMBER(),  
	  @ErrorSeverity = ERROR_SEVERITY(),  
	  @ErrorState = ERROR_STATE(),  
	  @ErrorLine = ERROR_LINE(),  
	  @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), 'N/A');  
  
	 --Build the error message string  
	 SELECT @ErrorMessage = 'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +  
				'Message: ' + ERROR_MESSAGE()        
	 
	 SELECT @StepName = 'STG_SalesTransaction'
    --EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMessage, -1
	 
	 RAISERROR                                      
	 (  
	  @ErrorMessage,  
	  @ErrorSeverity,  
	  1,  
	  @ErrorNumber,  
	  @ErrorSeverity,  
	  @ErrorState,  
	  @ErrorProcedure,  
	  @ErrorLine  
	 );      
	END CATCH
	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	SELECT @DbName = DB_NAME()
	SELECT @SpId = @@SPID
	SELECT @AuditType = 'PROCESS END'
	SELECT @StepName = 'Staging.STG_SalesTransaction_Insert Procedure Try'

	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC dbo.uspSSISProcStepSuccess @spname, @StepName

	 
	RETURN 
END