
/*===========================================================================================
Name:			STG_Load_FulfilmentMethodIds
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		
Modified:		

Peer Review:	
Call script:	EXEC STG_Load_FulfilmentMethodIds 0
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_Load_FulfilmentMethodIds]
(
    @userid                INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname              NVARCHAR(256)	
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER
	DECLARE @logmessage          NVARCHAR(MAX)

	
	DECLARE @StepName                 NVARCHAR(256)
	DECLARE @ProcName						 NVARCHAR(256)
	DECLARE @nameFulfilmentmethod NVARCHAR(256) = ' ' 

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	BEGIN TRANSACTION
	BEGIN TRY

	
		--EXEC dbo.uspAuditAddAudit 	@AuditType='PROCESS START', @Process=@spname, @SPID =@@SPID
	
	DECLARE GetFulfilmentMethods CURSOR READ_ONLY
   FOR 
		SELECT DISTINCT originatingsystemtype + ' ' + originatingsystem as Name1 
		FROM PreProcessing.TOCPLUS_Transaction a
		INNER JOIN Staging.STG_KeyMapping        b ON a.[tcscustomerid] = b.[tcsCustomerID] and (b.IsParentInd =1) 
		WHERE NOT EXISTS (SELECT 1 FROM  [Reference].[FulfilmentMethod] c WHERE c.name = a.originatingsystemtype + ' ' + a.originatingsystem)

	OPEN GetFulfilmentMethods

	FETCH NEXT FROM GetFulfilmentMethods 		INTO @nameFulfilmentmethod
	WHILE @@FETCH_STATUS = 0
   BEGIN
   
   INSERT INTO [Reference].[FulfilmentMethod] ([Name], [Description], [CreatedDate], [CreatedBy], [LastModifiedDate], [LastModifiedBy]  ,[ArchivedInd]
															  ,[InformationSourceID],[ExtReference],[DisplayName], [ValidityStartDate], [ValidityEndDate])
	VALUES     (@nameFulfilmentmethod, @nameFulfilmentmethod, getdate(), 0, getdate(), 0, 0, 1, @nameFulfilmentmethod, @nameFulfilmentmethod, getdate(), getdate())
	FETCH NEXT FROM GetFulfilmentMethods 		INTO @nameFulfilmentmethod
   END

	CLOSE GetFulfilmentMethods
   DEALLOCATE GetFulfilmentMethods
	
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

	COMMIT TRANSACTION
		
	   --EXEC dbo.uspAuditAddAudit 	@AuditType='PROCESS END', @Process=@spname, @SPID =@@SPID

	END TRY
	BEGIN CATCH  
	 DECLARE   
	  @ErrorMessage VARCHAR(4000),  
	  @ErrorNumber INT,  
	  @ErrorSeverity INT,  
	  @ErrorState INT,  
	  @ErrorLine INT,  
	  @ErrorProcedure VARCHAR(126);  

	  IF CURSOR_STATUS('global','GetFulfilmentMethods')>=-1
     BEGIN
		CLOSE GetFulfilmentMethods
		DEALLOCATE GetFulfilmentMethods  
	  END
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
	 
	 --SELECT @StepName = 'STG_SalesTransaction'
   -- EXEC dbo.uspSSISProcStepFailed @spname, @spname, 51403, @ErrorMessage, -1
	   
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