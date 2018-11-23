/*===========================================================================================
Name:			PreProcessing.TOCPlus_Customers
Purpose:		Creates collections of unprocessed records from preprocessing table, for each record 
				calls customer process proc to load customers from preprocessing to staging 
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-01	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC PreProcessing.TOCPlus_Customers 0,50
=================================================================================================*/

CREATE PROCEDURE [PreProcessing].[TOCPlus_Customers]
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

	-- Standard declarations and variable setting.
	---------------------------------------------------------
	DECLARE @tcscustomerid          INTEGER
	DECLARE @addresstypeidemail     INTEGER
	DECLARE @addresstypeidmobile    INTEGER

    DECLARE @now                    DATETIME
	DECLARE @importfilename			NVARCHAR(256)
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

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
	
	--EXEC dbo.uspAuditAddAudit
	--	 @AuditType='PROCESS START'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SELECT @now = GETDATE()

	SET @ProcName = 'PreProcessing.TOC_Customers'

	SET @StepName = 'Operations.DataImportDetail_Update'

	SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid

	BEGIN TRY		

		--EXEC uspSSISProcStepStart @ProcName, @StepName

		EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
													@dataimportdetailid    = @dataimportdetailid,
													@operationalstatusname = 'Processing',
													@importfilename         = @importfilename,
													@starttimepreprocessing      = NULL,
													@endtimepreprocessing        = NULL,
													@starttimeimport       = @now,
													@endtimeimport         = NULL,
													@totalcountimport      = NULL,
													@successcountimport    = NULL,
													@errorcountimport      = NULL
	
		--EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;
	--RAISERROR('',10,1) WITH NOWAIT

	SELECT @addresstypeidemail = AddressTypeID
	FROM Reference.AddressType
	WHERE Name = 'Email'

	SELECT @addresstypeidmobile = AddressTypeID
	FROM Reference.AddressType
	WHERE Name = 'Mobile'

	SET @StepName = 'Check if reference values are populated'
    IF @addresstypeidemail IS NULL OR @addresstypeidmobile IS NULL
	BEGIN
	    SET @ErrorMsg = 'No or invalid @addresstypeidemail or @addresstypeidmobile; @dataimportdetailid = ' + ISNULL(CAST(@dataimportdetailid AS NVARCHAR(256)),'NULL')		
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey
        RETURN
    END
		
	--Process any new or updated customers
	SET @StepName = 'PreProcessing.TOC_Customer_Process'
	
	DECLARE Customers CURSOR READ_ONLY
	FOR
	    SELECT TCScustomerID
		FROM   PreProcessing.TOCPLUS_Customer WITH (NOLOCK)
		WHERE  DataImportDetailID = @dataimportdetailid
		AND    ProcessedInd = 0
		--AND    Account_Type IN ('Full','Partial')
		
		OPEN Customers
		
		FETCH NEXT FROM Customers
		    INTO @tcscustomerid

        WHILE @@FETCH_STATUS = 0
		BEGIN
		    BEGIN TRY
				--EXEC uspSSISProcStepStart @ProcName, @StepName

				EXEC [PreProcessing].[TOCPlus_Customer_Process] @userid             = @userid,
															@tcs_customerid     = @tcscustomerid,
															@dataimportdetailid = @dataimportdetailid

				--EXEC uspSSISProcStepSuccess @ProcName, @StepName
			END TRY
			BEGIN CATCH
				SELECT @ErrorMsg = 'Unable to process customer, tcscutomerid - '   + CAST(@tcscustomerid AS NVARCHAR(50))
				SET @ErrorNum = ERROR_NUMBER()
				EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey

			END CATCH 
		    FETCH NEXT FROM Customers
		        INTO @tcscustomerid

        END

		CLOSE Customers

    DEALLOCATE Customers

    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.TOCPLUS_Customer
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Customer
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @Rows = @successcountimport + @errorcountimport

	SET @StepName = 'Operations.DataImportDetail_Update'

	BEGIN TRY		

		--EXEC uspSSISProcStepStart @ProcName, @StepName

		EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
													@dataimportdetailid    = @dataimportdetailid,
													@operationalstatusname = 'Completed',													
													@importfilename         = @importfilename,
													@starttimepreprocessing      = NULL,
													@endtimepreprocessing        = NULL,
													@starttimeimport       = NULL,
													@endtimeimport         = @now,
													@totalcountimport      = @Rows,
													@successcountimport    = @successcountimport,
													@errorcountimport      = @errorcountimport
		--EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH

		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey

	END CATCH ;

	-- End auditting
	--EXEC dbo.uspAuditAddAudit
	--	 @AuditType='PROCESS END'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid,@Rows = @Rows, @PrintToScreen=@DebugPrint


	RETURN
END
GO

