/*===========================================================================================
Name:			PreProcessing.STG_SalesDetail_Insert
Purpose:		Load preprocessed bookings from TOC into staging sales details table 
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
Notes:			 
			
Created:		2018-08-01	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC PreProcessing.STG_SalesDetail_Insert 0, 50
=================================================================================================*/

CREATE PROCEDURE [PreProcessing].[STG_SalesDetail_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER,	
	@DebugPrint			   INTEGER = 0,
	@PkgExecKey			   INTEGER = -1,
	@DebugRecordset		   INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER
	DECLARE @TransactionStatusID    INT
	DECLARE @ProductID              INT = -1
	
	DECLARE @importfilename			NVARCHAR(256)

	DECLARE @recordcount            INTEGER       = 0
	DECLARE @spid	INTEGER	 = @@SPID
	DECLARE @spname  SYSNAME = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
	DECLARE @dbname  SYSNAME = DB_NAME()
	DECLARE @Rows	INTEGER  = 0
	DECLARE @ProcName NVARCHAR(50)
	DECLARE @StepName NVARCHAR(50)

	DECLARE  @ErrorMsg		NVARCHAR(MAX)
	DECLARE  @ErrorNum		INTEGER
	DECLARE  @ErrorSeverity	 NVARCHAR(255)
	DECLARE  @ErrorState NVARCHAR(255)
	
	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SELECT @now = GETDATE()

	SET @ProcName = 'PreProcessing.STG_SalesDetail_Insert'

    SELECT @InformationSourceID = InformationSourceID
	FROM Reference.InformationSource 
	WHERE [Name] = 'TrainLine'

	SET @StepName = 'Check if infromation source id is populated'
	IF @informationsourceid IS NULL
	BEGIN
	    SET @ErrorMsg = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL');	    
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg,1;	
    END

	--needs updating
	--SELECT @TransactionStatusID = TransactionStatusID
	--FROM Reference.TransactionStatus
	--WHERE [Name] = 'TrainLine' 

	SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid

	BEGIN TRY
		SET @StepName = 'Operations.DataImportDetail_Update'

		EXEC uspSSISProcStepStart @ProcName, @StepName

		EXEC [Operations].[DataImportDetail_Update] @userid                 = @userid,
													@dataimportdetailid     = @dataimportdetailid,
													@operationalstatusname  = 'Processing',
													@importfilename         = @importfilename,
													@starttimepreprocessing = NULL,
													@endtimepreprocessing   = NULL,
													@starttimeimport        = @now,
													@endtimeimport          = NULL,
													@totalcountimport       = NULL,
													@successcountimport     = NULL,
													@errorcountimport       = NULL
		EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Perform Insert to sales detail table Staging.STG_SalesDetail'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	 IF OBJECT_ID(N'tempdb..#Bookings') IS NOT NULL
	 DROP TABLE #Bookings
     SELECT B.transactiondate AS CreatedDate
		   ,0 AS CreatedBy
		   ,B.cmddateupdated  AS LastModifiedDate
		   ,0 AS LastModifiedBy
		   ,0 AS ArchiveInd
		   ,ST.SalesTransactionID
		   ,B.noofitems AS Quantity
		   ,B.purchasevalue AS SalesAmount
		   ,CASE WHEN B.purchasecode = 'RAIL' THEN 1 ELSE 0 END AS IsTrainTicketInd
		   ,CAST(B.purchaseid AS NVARCHAR(20)) AS ExtReference 
		   ,@InformationSourceID AS InformationSourceID
		   ,-1 AS TransactionStatusID
		   ,KM.CustomerID 
		   ,CASE WHEN B.refundind = 'N' THEN 0 WHEN B.refundind = 'Y' THEN 1 ELSE NULL END AS refundind
		   ,B.refunddate 
		   ,B.businessorleisure 
		   ,-1 as ProductID
	INTO #Bookings
	FROM (SELECT ROW_NUMBER() OVER (PARTITION BY purchaseid ORDER BY cmddateupdated DESC, TOCBookingsID DESC) AS Ranking
			   ,purchaseid, tcstransactionid, tcscustomerid, purchasecode, transactiondate
			   ,purchasevalue, noofitems, purchasedate, businessorleisure, refundind, refunddate
			   ,amendedind,amendeddate, cmddateupdated, DataImportDetailID
			   ,CASE WHEN refundind  = 'N' AND amendedind = 'N' THEN 'Purchased' 
					 WHEN refundind  = 'Y' THEN 'Refunded'
					 WHEN amendedind = 'Y' THEN 'Amended'
				END AS TransactionStatus
		FROM PreProcessing.TOCPLUS_Bookings
		WHERE  DataImportDetailID = @dataimportdetailid
		AND ProcessedInd = 0 ) AS B
	INNER JOIN Staging.STG_KeyMapping AS KM
		ON B.tcscustomerid = KM.TCSCustomerID
	LEFT JOIN Staging.STG_SalesTransaction AS ST
		ON B.tcstransactionid = ST.ExtReference 
	LEFT JOIN Reference.TransactionStatus AS TS
		ON B.TransactionStatus = TS.[Name]
	WHERE SalesTransactionID IS NOT NULL
	AND B.Ranking = 1

	MERGE Staging.STG_SalesDetail AS TRGT
	USING #Bookings AS SRC
	ON TRGT.ExtReference = SRC.ExtReference
	WHEN NOT MATCHED THEN
	-- Inserting new sales detail information 
	INSERT (CreatedDate, CreatedBy, CreatedExtractNumber, LastModifiedDate, LastModifiedBy, LastModifiedExtractNumber
		   ,ArchivedInd, SalesTransactionID, Quantity, SalesAmount, IsTrainTicketInd, ExtReference, InformationSourceID
		   ,TransactionStatusID, CustomerID, refundind, refunddate, businessorleisure, ProductID)
	VALUES
			(CreatedDate, CreatedBy, @dataimportdetailid, LastModifiedDate, LastModifiedBy, @dataimportdetailid, ArchiveInd
			,SalesTransactionID, Quantity, SalesAmount, IsTrainTicketInd, ExtReference, InformationSourceID, TransactionStatusID
		    ,CustomerID, refundind, refunddate, businessorleisure, ProductID)
	WHEN MATCHED 
		AND SRC.LastModifiedDate > TRGT.LastModifiedDate
		THEN 
			-- Update existing sales detail information
			UPDATE 
			SET TRGT.LastModifiedDate = SRC.LastModifiedDate
			    ,TRGT.LastModifiedExtractNumber = @dataimportdetailid
				,TRGT.SalesTransactionID = SRC.SalesTransactionID
				,TRGT.Quantity = SRC.Quantity
				,TRGT.SalesAmount = SRC.SalesAmount
				,TRGT.IsTrainTicketInd = SRC.IsTrainTicketInd
				,TRGT.InformationSourceID = SRC.InformationSourceID
				,TRGT.TransactionStatusID = SRC.TransactionStatusID
				,TRGT.CustomerID = SRC.CustomerID
				,TRGT.refundind = SRC.refundind
				,TRGT.refunddate = SRC.refunddate
				,TRGT.businessorleisure = SRC.businessorleisure
				,TRGT.ProductID = SRC.ProductID;

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Perform Insert to sales detail table Staging.STG_SalesDetail'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing booking table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE B
	SET  B.ProcessedInd = 1
	     ,B.LastModifiedDateETL = GETDATE()
	FROM [PreProcessing].TOCPLUS_Bookings AS B 
	INNER JOIN  [Staging].[STG_SalesDetail] AS SD ON B.purchaseid = SD.ExtReference
	AND   B.DataImportDetailID = @dataimportdetailid
	WHERE TRY_CAST(SD.ExtReference AS INT) IS NOT NULL

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing booking table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint
		
	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.TOCPLUS_Bookings
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Bookings
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

	SELECT @now = GETDATE()

	BEGIN TRY
		SET @StepName = 'Operations.DataImportDetail_Update'

		EXEC uspSSISProcStepStart @ProcName, @StepName
		EXEC [Operations].[DataImportDetail_Update] @userid						= @userid,
													@dataimportdetailid			= @dataimportdetailid,
													@operationalstatusname		= 'Completed',
													@importfilename             = @importfilename,
													@starttimepreprocessing     = NULL,
													@endtimepreprocessing		= NULL,
													@starttimeimport			= NULL,
													@endtimeimport				= @now,
													@totalcountimport			= @recordcount,
													@successcountimport			= @successcountimport,
													@errorcountimport			= @errorcountimport
		EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;

	-- End auditting
	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS END'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid,@Rows = @Rows, @PrintToScreen=@DebugPrint
	RETURN 
END
GO


