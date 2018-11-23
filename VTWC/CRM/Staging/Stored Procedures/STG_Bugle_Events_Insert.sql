
/*===========================================================================================
Name:			STG_Bugle_Events_Insert
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		USINARI
Modified:		

Peer Review:	
Call script:	e.g, EXEC Staging.STG_Bugle_Events_Insert 0, 429
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_Bugle_Events_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN

    SET NOCOUNT ON;

	DECLARE @LoyaltyProgrammeTypeID INTEGER
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
	SELECT @StepName = 'Staging.STG_Bugle_Events_Insert ProcedureStart'

	
	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	EXEC uspSSISProcStepStart @spname, @StepName

	BEGIN TRY
	BEGIN TRANSACTION

		--Log start time--
	
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT
										 
    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Bugle'

	
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

	
	INSERT INTO [Staging].[STG_BugleEvents]
			   ([CreatedDate]
			   ,[CreatedBy]
			   ,[LastModifiedDate]
			   ,[LastModifiedBy]
			   ,[ArchivedInd]
			   ,[StartDate]
			   ,[StartTime]
			   ,[TrainID]
			   ,[Description]
			   ,[LocationOriginID]
			   ,[LocationDestinationID]
			   ,[LocationID]
			   ,[LocationSeq]
			   ,[PlannedActivity]
			   ,[PublicTime]
			   ,[ActualTime]
			   ,[ActualActivity]
			   ,[PublicVar]
			   ,[DelayJourneyEventInfo])
  

		SELECT 
				 GETDATE() AS CreatedDate
				,0 AS CreatedBy
				,GETDATE() AS LastModifiedDate
				,0 AS LastModifiedBy
			    ,0 AS ArchivedInd
			    ,convert(date, [Start Date], 121) AS StartDate
				,convert(time(7), [Start Time], 121) AS StartTime
				,[Train] AS TrainID
				,a.[Description] AS Description

				,b.locationID AS LocationOriginID
			    ,c.locationID AS LocationDestinationID
			    ,d.locationID AS LocationID
			    --,convert(INT, [LocationSeq]) AS LocationSeq
				,LocationSeq
				,[PlannedActivity] AS PlannedActivity
				,[PublicTime] AS PublicTime
				,[ActualTime] AS ActualTime
				,[ActualActivity] AS ActualActivity
				,[PublicVar] AS PublicVar
				,[DelayJourneyEventInfo] AS DelayJourneyEventInfo

		  FROM [PreProcessing].[BugleEvents] a
		  LEFT JOIN Reference.LocationAlias b ON (a.[Origin] = b.Name) --AND (b.InformationSourceID = 4) --@informationsourceid)
		  LEFT JOIN Reference.LocationAlias c ON (a.[Dest] = c.Name) --AND (c.InformationSourceID = 4) -- @informationsourceid)
		  LEFT JOIN Reference.LocationAlias d ON (a.[Location] = d.Name) --AND (d.InformationSourceID =  4) --@informationsourceid)

		 WHERE Dataimportdetailid = @dataimportdetailid
		 AND a.ProcessedInd = 0
		 AND a.PlannedActivity IN ('A', 'D', 'O', 'T')
		 AND a.ActualActivity <> 'PASS'

	
	UPDATE a
	SET  ProcessedInd = 1, LastModifiedDateETL =GETDATE()
	FROM PreProcessing.[BugleEvents] a
	WHERE a.DataImportDetailID = @dataimportdetailid  and a.DataImportDetailID is not null
	AND   a.ProcessedInd = 0
 

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
	EXEC dbo.uspSSISProcStepSuccess @spname, @StepName		
	
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
	 
	 SELECT @StepName = 'STG_Bugle_Events_Insert'
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
	SELECT @StepName = 'Staging.STG_Bugle_Events_Insert Procedure Try'

	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	EXEC dbo.uspSSISProcStepSuccess @spname, @StepName

	 
	RETURN 
END