/*===========================================================================================
Name:			[STG_ReasonForTravel_nologids_Wrapper]
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		
Modified:		

Peer Review:	
Call script:	EXEC [Staging].[STG_ReasonForTravel_nologids_Wrapper] 0
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_ReasonForTravel_nologids_Wrapper]
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
	SELECT @StepName = 'Staging.STG_ReasonForTravel_nologids_Wrapper'
	
--	EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0

	BEGIN TRY
	--EXEC dbo.uspSSISProcStepStart @spname, @StepName
	--BEGIN TRANSACTION

	
	--Log start time--
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT


	
	IF CURSOR_STATUS('global','Journney')>=-1
    BEGIN
	CLOSE Journney
	DEALLOCATE Journney  
	END  

	
	DECLARE Journney CURSOR READ_ONLY
    FOR 

		select distinct CreatedExtractNumber   from  Staging.STG_Journey b 
		inner join Operations.DataImportDetail a on a.DataImportDetailID = b.CreatedExtractNumber
		where a.name = 'TOC Plus Journey'
		order by 1 


	    OPEN Journney

	    FETCH NEXT FROM Journney
		    INTO @dataimportdetailid

	    WHILE @@FETCH_STATUS = 0
        BEGIN
			  --PRINT 'DataimportDetailId= ' + CAST(@dataimportdetailid AS VARCHAR(30))
	
		    EXEC [Staging].[STG_Journey_ReasonForTravel_Update] @userid             = @userid,
	                                                           @dataimportdetailid = @dataimportdetailid
			
		    FETCH NEXT FROM Journney
		        INTO @dataimportdetailid
        END

	   CLOSE Journney
     
       DEALLOCATE Journney


   	END TRY
	BEGIN CATCH  
	 DECLARE   
	  @ErrorMessage VARCHAR(4000),  
	  @ErrorNumber INT,  
	  @ErrorSeverity INT,  
	  @ErrorState INT,  
	  @ErrorLine INT,  
	  @ErrorProcedure VARCHAR(126);  

	  IF CURSOR_STATUS('global','Journney')>=-1
     BEGIN
		CLOSE Journney
		DEALLOCATE Journney  
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
	 
	 SELECT @StepName = 'STG_ReasonForTravel_nologids_Wrapper'
	 --EXEC dbo.uspSSISProcStepFailed  @spname, @StepName, 51403, @ErrorMessage, -1
	 
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
	
		
	RETURN 
END

