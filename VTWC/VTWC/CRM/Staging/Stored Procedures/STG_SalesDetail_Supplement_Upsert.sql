/*===========================================================================================
Name:			Staging.STG_SalesDetail_Supplement_Upsert
Purpose:		Insert/Update journey supplement information into table Staging.STG_SalesDetail.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-10	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Staging.STG_SalesDetail_Supplement_Upsert
=================================================================================================*/

  CREATE PROCEDURE [Staging].[STG_SalesDetail_Supplement_Upsert]
    @userid                INTEGER = 0,
	@dataimportdetailid    INTEGER, 
	@DebugPrint			   INTEGER = 0,
	@PkgExecKey			   INTEGER = -1,
	@DebugRecordset		   INTEGER = 0
  ----------------------------------------
  AS 
  BEGIN

  
   SET NOCOUNT ON;

	DECLARE @now                    DATETIME = GETDATE()
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @importfilename			NVARCHAR(256)


   DECLARE @spid	INTEGER	= @@SPID
   DECLARE @spname  SYSNAME = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
   DECLARE @dbname  SYSNAME = DB_NAME()
   DECLARE @Rows	INTEGER = 0
   DECLARE @ProcName NVARCHAR(50)
   DECLARE @StepName NVARCHAR(50)

   DECLARE @informationsourceid INT 

   DECLARE  @ErrorMsg		NVARCHAR(MAX)
   DECLARE  @ErrorNum		INTEGER
   DECLARE  @ErrorSeverity	 NVARCHAR(255)
   DECLARE  @ErrorState NVARCHAR(255)

	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SET @ProcName = 'PreProcessing.TOCPlus_SalesDetail_Supplement_Insert'
   
    SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid

	SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'TrainLine'

	SET @StepName = 'Check if information source reference values are populated'

	IF @informationsourceid                 IS NULL
	BEGIN
	    SET @ErrorMsg = 'No or invalid reference information.' +
		                  ' @informationsourceid =  '                + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') 
	    
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey

        RETURN
    END

	IF OBJECT_ID(N'tempdb..#Product') IS NOT NULL
	DROP TABLE #Product
	SELECT SupplementTypeCode AS TicketTypeCode, SupplementTypeDesc AS [Name], @InformationSourceID AS InformationSourceID
	INTO #Product
	FROM PreProcessing.TOCPLUS_Supplements
	WHERE DataImportDetailID = @DataImportDetailID
	GROUP BY SupplementTypeCode, SupplementTypeDesc

	EXEC [Reference].[Product_Upsert]


    SET @StepName = 'Operations.DataImportDetail_Update'
	BEGIN TRY		

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

	

	SET @StepName = 'Insert sales detail supplement information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert sales detail supplement information start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		IF OBJECT_ID(N'tempdb..#Supplements') IS NOT NULL
		DROP TABLE #Supplements
		SELECT SalesTransactionID, ProductID, UnitPrice, Quantity, SalesAmount, ExtReference
			   ,TCSBookingID, InformationSourceID, CustomerID, DateCreated, DateUpdated, DataImportDetailID
		INTO #Supplements
		FROM (
			SELECT ST.SalesTransactionID, P.ProductID, SUPP.Cost AS UnitPrice, SUPP.Quantity, SUPP.TotalCost AS SalesAmount
				   ,SUPP.SupplementID  AS ExtReference, SUPP.TCSBookingID, @InformationSourceID AS InformationSourceID
				   ,ST.CustomerID, SUPP.DateCreated, SUPP.DateUpdated, SUPP.DataImportDetailID
				   ,ROW_NUMBER() OVER (PARTITION BY SUPP.TCSBookingID, SUPP.SupplementID ORDER BY SUPP.SupplementID DESC) AS Ranking
			FROM Staging.STG_SalesTransaction AS ST
			INNER JOIN (SELECT *
						FROM PreProcessing.TOCPLUS_Supplements
						WHERE DataImportDetailID = @DataImportDetailID
						AND ProcessedInd = 0) AS SUPP
				ON ST.ExtReference = SUPP.TCSTransactionId 
			LEFT JOIN Reference.Product AS P
				ON SUPP.SupplementTypeCode = P.TicketTypeCode) AS SQ
		WHERE Ranking =1 

		MERGE Staging.STG_SalesDetail AS TRGT
		USING #Supplements AS SRC
		ON TRGT.ExtReference = SRC.ExtReference
		WHEN NOT MATCHED THEN
		-- Inserting new sales detail information 
		INSERT (SalesTransactionID, ProductID, Quantity, UnitPrice, SalesAmount, IsTrainTicketInd
				,ExtReference, InformationSourceID, CustomerID, CreatedDate, CreatedBy, CreatedExtractNumber
				,LastModifiedDate, LastModifiedBy, LastModifiedExtractNumber)
		VALUES
				(SalesTransactionID, ProductID, Quantity, UnitPrice, SalesAmount, 0
				,ExtReference, InformationSourceID, CustomerID, DateCreated, 0, @DataImportDetailID
				,DateUpdated, 0, @DataImportDetailID)
		WHEN MATCHED 
			AND SRC.DateUpdated > TRGT.LastModifiedDate
			THEN 
				-- Update existing broad_log information 
				UPDATE 
				SET   TRGT.LastModifiedDate = SRC.DateUpdated
				    , TRGT.LastModifiedExtractNumber = @DataImportDetailID
					, TRGT.SalesTransactionID = SRC.SalesTransactionID
				    , TRGT.ProductID = SRC.ProductID
					, TRGT.Quantity = SRC.Quantity
					, TRGT.UnitPrice = SRC.UnitPrice
					, TRGT.SalesAmount = SRC.SalesAmount
					, TRGT.CustomerID = SRC.CustomerID;


		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert sales detail supplements information finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing supplements table start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE B
	SET  B.ProcessedInd = 1
	FROM [PreProcessing].TOCPLUS_Supplements AS B 
	INNER JOIN #Supplements AS S
		ON B.SupplementID = S.ExtReference
		AND B.TCSBookingID = S.TCSBookingID
	INNER JOIN  Staging.STG_SalesDetail AS BL ON S.ExtReference = BL.ExtReference
	AND   B.DataImportDetailID = @dataimportdetailid

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing supplements table finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Supplements
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Supplements
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

	SET @StepName = 'Operations.DataImportDetail_Update'
	BEGIN TRY
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
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid, @PrintToScreen=@DebugPrint
 END
GO

