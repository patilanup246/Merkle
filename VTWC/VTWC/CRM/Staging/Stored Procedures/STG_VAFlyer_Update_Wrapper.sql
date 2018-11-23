
/*===========================================================================================
Name:			STG_VAFlyer_Update_Wrapper
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		
Modified:		

Peer Review:	
Call script:	EXEC STG_VAFlyer_Update_Wrapper 0
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_VAFlyer_Update_Wrapper]
(
    @userid                INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @dataimporttype      NVARCHAR(256) = 'Trainline Main TOC Plus'

	DECLARE @spname              NVARCHAR(256)	
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER
	DECLARE @logmessage          NVARCHAR(MAX)

	DECLARE @dataimportlogid                  INTEGER
	DECLARE @dataimportdetailid               INTEGER

	DECLARE @StepName                 NVARCHAR(256)
	DECLARE @ProcName						 NVARCHAR(256)
	
	DECLARE @DbName				       NVARCHAR(256) 
	DECLARE @AuditType				       NVARCHAR(256) 
	DECLARE @SpId							 INT 
	
	
	DECLARE @DebugPrint					INT = 0
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	SELECT @DbName = DB_NAME()
	SELECT @SpId = @@SPID
	SELECT @AuditType = 'PROCESS START'
	SELECT @StepName = 'Staging.STG_VAFlyer_Update_Wrapper'
	
	EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0

	BEGIN TRY
	EXEC dbo.uspSSISProcStepStart @spname, @StepName
	--BEGIN TRANSACTION

	
	--Log start time--
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT


	IF CURSOR_STATUS('global','GetLogId_VAFlyer')>=-1
   BEGIN
	CLOSE GetLogId_VAFlyer
	DEALLOCATE GetLogId_VAFlyer  
	END

	IF CURSOR_STATUS('global','VAFlyer')>=-1
   BEGIN
	CLOSE VAFlyer
	DEALLOCATE VAFlyer  
	END  

	DECLARE GetLogId_VAFlyer CURSOR READ_ONLY
   FOR 
	SELECT distinct a.DataImportLogID
	FROM   [Operations].[DataImportLog] a
	INNER JOIN [Reference].[OperationalStatus] b ON a.OperationalStatusID = b.OperationalStatusID
	INNER JOIN [Reference].[DataImportType] c ON c.DataImportTypeID = a.DataImportTypeID
	INNER JOIN Operations.DataImportDetail e ON a.DataImportLogID = e.DataImportLogID
	INNER JOIN PreProcessing.TOCPLUS_VAFlyerTrans d ON d.DataImportDetailID = e.DataImportDetailID 
	WHERE (b.Name = 'Imported') 
	AND   c.Name = @dataimporttype

	
	OPEN GetLogId_VAFlyer

	FETCH NEXT FROM GetLogId_VAFlyer 		INTO @dataimportlogid
	WHILE @@FETCH_STATUS = 0
   BEGIN
   
	 IF @dataimportlogid IS NULL OR @dataimportlogid !> 0
    BEGIN
	    SET @logmessage = 'No or invalid data import log reference.' + ISNULL(CAST(@dataimportlogid AS NVARCHAR(256)),'NULL') 
	    
	    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	                                          @logsource       = @spname,
			    							  @logmessage      = @logmessage,
				    						  @logmessagelevel = 'ERROR',
						    				  @messagetypecd   = NULL

		--COMMIT TRANSACTION
		RETURN
    END	


	DECLARE VAFlyer CURSOR READ_ONLY
    FOR 
	    SELECT a.dataimportdetailid
	    FROM  PreProcessing.TOCPLUS_VAFlyerTrans a
        INNER JOIN Operations.DataImportDetail b ON a.dataimportdetailid = b.dataimportdetailid
		INNER JOIN Operations.DataImportLog c ON c.DataImportLogID = b.DataImportLogID
        WHERE c.DataImportLogID = @dataimportlogid
		AND b.NAME = 'TOC Plus VA Flyers'
	    GROUP BY a.dataimportdetailid
	
	    OPEN VAFlyer

	    FETCH NEXT FROM VAFlyer
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
				--PRINT CAST(@dataimportlogid AS VARCHAR(30))
		      --PRINT CAST(@dataimportdetailid AS VARCHAR(30))
		    EXEC [Staging].[STG_SalesTransaction_VAFlyer_Update] @userid             = @userid,
	                                                           @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM VAFlyer
		        INTO @dataimportdetailid
        END

	   CLOSE VAFlyer
     
       DEALLOCATE VAFlyer

/*
	 
   UPDATE a 
	SET  OperationalStatusID = b.OperationalStatusID
	    ,LastModifiedDate    = GETDATE()
	FROM [Operations].[DataImportLog] a
	INNER JOIN [Reference].[OperationalStatus] b ON b.Name = 'Completed'
	AND  a.DataImportLogID = @dataimportlogid

	*/
   FETCH NEXT FROM GetLogId_VAFlyer 		INTO @dataimportlogid
   END

   CLOSE GetLogId_VAFlyer
   DEALLOCATE GetLogId_VAFlyer
	
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

	--COMMIT TRANSACTION
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

	  IF CURSOR_STATUS('global','GetLogId_VAFlyer')>=-1
     BEGIN
		CLOSE GetLogId_VAFlyer
		DEALLOCATE GetLogId_VAFlyer  
	  END

	  IF CURSOR_STATUS('global','VAFlyer')>=-1
     BEGIN
		CLOSE VAFlyer
		DEALLOCATE VAFlyer  
	  END  
	  --ROLLBACK TRANSACTION;
	 SELECT   
	  @ErrorNumber = ERROR_NUMBER(),  
	  @ErrorSeverity = ERROR_SEVERITY(),  
	  @ErrorState = ERROR_STATE(),  
	  @ErrorLine = ERROR_LINE(),  
	  @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), 'N/A');  
  
	 SELECT @ErrorMessage = 'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +  
				'Message: ' + ERROR_MESSAGE()        
	 
	 SELECT @StepName = 'STG_SalesTransaction_VAFlyer_Update'
	 EXEC dbo.uspSSISProcStepFailed  @spname, @StepName, 51403, @ErrorMessage, -1
	 
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

	 	
    EXEC dbo.uspSSISProcStepFailed @spname, @StepName, 51403, @ErrorMessage, -1

	END CATCH 
	
	SELECT @AuditType = 'PROCESS END'
	SELECT @StepName = 'Staging.STG_VAFlyerUpdate_Wrapper'
	
	EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0

	
	
	RETURN 
END