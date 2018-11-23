/*===========================================================================================
Name:			[Staging].[STG_Leg_Upsert] 
Purpose:		Insert/Update leg information into table Staging.STG_Leg.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-29	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC [Staging].[STG_Leg_Upsert] 
=================================================================================================*/

  CREATE PROCEDURE [Staging].[STG_Leg_Upsert] 
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

	SET @ProcName = 'PreProcessing.TOCPlus_Leg_Insert'
   
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

	

	SET @StepName = 'Insert leg information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert leg information start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint
		
		IF OBJECT_ID(N'tempdb..#Leg') IS NOT NULL
		DROP TABLE #Leg
		SELECT Leg.jl_id AS LegID, @Now AS CreatedDate, 0 AS CreatedBy, @Now AS LastModifiedDate
		       ,0 AS LastModifiedBy, COALESCE(Leg.coach,'') + '' + COALESCE(TRY_CAST(Leg.seat_number AS NVARCHAR(20)),'') AS SeatReservation
			   ,Leg.quiet_coach, @InformationSourceID AS InformationSourceID, Leg.DateCreated AS SourceCreatedDate
			   ,Leg.DateUpdated AS SourceModifiedDate
		INTO #Leg
		FROM Staging.STG_JourneyLeg AS JL
		INNER JOIN (SELECT *
					FROM PreProcessing.TOCPLUS_Legs
					WHERE  DataImportDetailID = @dataimportdetailid
					AND    ProcessedInd = 0) AS Leg
			ON JL.ExtReference = Leg.jl_id 

		MERGE Staging.STG_Leg AS TRGT
		USING #Leg AS SRC
		ON TRGT.LegID = SRC.LegID
		WHEN NOT MATCHED THEN
		-- Inserting new leg information 
		INSERT (LegID, CreatedDate, CreatedBy, CreatedExtractNumber, LastModifiedDate, LastModifiedBy, LastModifiedExtractNumber
				,SeatReservation, QuietZone, InformationSourceID, SourceCreatedDate, SourceModifiedDate)
		VALUES
				(LegID, CreatedDate, CreatedBy, @dataimportdetailid, LastModifiedDate, LastModifiedBy, @dataimportdetailid
				,SeatReservation, quiet_coach, InformationSourceID, SourceCreatedDate, SourceModifiedDate)
		WHEN MATCHED 
			AND SRC.SourceModifiedDate > TRGT.SourceModifiedDate
			THEN 
				-- Update existing leg leginformation
				UPDATE 
				SET TRGT.SourceModifiedDate = SRC.SourceModifiedDate
					,TRGT.LastModifiedExtractNumber = @dataimportdetailid
				    ,TRGT.LastModifiedDate = @now
					,TRGT.LastModifiedBy = SRC.LastModifiedBy
					,TRGT.LegID = SRC.LegID
					,TRGT.SeatReservation = SRC.SeatReservation
					,TRGT.QuietZone = SRC.quiet_coach;

		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert leg information finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing leg table start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE B
	SET  B.ProcessedInd = 1
	FROM [PreProcessing].TOCPLUS_Legs AS B 
	INNER JOIN  Staging.STG_Leg AS BL ON B.jl_id = BL.legid
	AND   B.DataImportDetailID = @dataimportdetailid

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing leg table finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Legs
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Legs
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

