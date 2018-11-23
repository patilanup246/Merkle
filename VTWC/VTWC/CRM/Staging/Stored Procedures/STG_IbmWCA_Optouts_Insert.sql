/*===========================================================================================
Name:			STG_IbmWCA_OptOuts_Insert
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		USINARI
Modified:		

Peer Review:	
Call script:	e.g, EXEC Staging.STG_IbmWCA_OptOuts_Insert 0, XXX --1053
=================================================================================================*/

ALTER PROCEDURE [Staging].[STG_IbmWCA_OptOuts_Insert]
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
	DECLARE @totalrecordcount		  INTEGER = 0

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
  
	DECLARE @customerid               INTEGER
	DECLARE @preferenceid             INTEGER
	DECLARE @channelid                INTEGER
	DECLARE @value							 BIT
	DECLARE @sourcecreateddate			 DATETIME
	DECLARE @sourcemodifieddate		 DATETIME    
   DECLARE @PkgExecKey					 INTEGER	   =-1
	DECLARE @DebugRecordset				 INTEGER	   = 0

	DECLARE @Email							 NVARCHAR(3000)

	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	SELECT @DbName = DB_NAME()
	SELECT @SpId = @@SPID
	SELECT @AuditType = 'PROCESS START'
	SELECT @StepName = 'Staging.STG_IbmWCA_OptOuts_Insert ProcedureStart'

	
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

	EXEC dbo.uspSSISProcStepStart @spname, @StepName

	EXEC [Operations].[DataImportDetail_Update] @userid            = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
												           @importfilename = @importfilename,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

	EXEC dbo.uspSSISProcStepSuccess @spname, @StepName

	IF CURSOR_STATUS('global','CursorIBMWcaOptouts')>=-1
	BEGIN
	CLOSE CursorIBMWcaOptouts
	DEALLOCATE CursorIBMWcaOptouts  
	END  
	
	SELECT @channelid = channelid from reference.channel where name = 'Email'
	SELECT @preferenceid = preferenceid from reference.preference where name = 'IBM WCA optouts'


	DECLARE CursorIBMWcaOptouts CURSOR READ_ONLY
		FOR 
			SELECT a.CustomerID, a.Email, a.EventTimeStamp 
			from ibm_system.dbo.SP_EmailOptOut a INNER JOIN Staging.STG_KeyMapping b on a.CustomerID = b.CustomerID  WHERE a.IsProcessedInd = 0
			Union
			SELECT a.CustomerID, a.Email, a.EventTimeStamp 
			from ibm_system.dbo.SP_OptOut a INNER JOIN  Staging.STG_KeyMapping b on a.CustomerID = b.CustomerID  WHERE a.IsProcessedInd = 0

			OPEN CursorIBMWcaOptouts

			FETCH NEXT FROM CursorIBMWcaOptouts		INTO @customerid, @Email, @sourcecreateddate

			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				EXEC [Staging].[STG_CustomerPreference_Update] 	@userid = @userid,   
																				@customerid = @customerid ,
																				@preferenceid = @preferenceid,
																				@channelid=@channelid,
																				@value= 0,
																				@sourcecreateddate =@sourcecreateddate ,
																				@sourcemodifieddate= @now,	 
																				@DebugPrint= @DebugPrint,
																				@PkgExecKey=@PkgExecKey ,
																				@DebugRecordset= @DebugRecordset
			
				
				FETCH NEXT FROM CursorIBMWcaOptouts		INTO @customerid, @email, @sourcecreateddate

			END  

		CLOSE CursorIBMWcaOptouts
     
		DEALLOCATE CursorIBMWcaOptouts

   	
	SELECT @totalrecordcount= COUNT(*) FROM
	(		SELECT Customerid, Email, EventTimeStamp from ibm_system.dbo.SP_EmailOptOut WHERE IsProcessedInd = 0
			Union
			SELECT Customerid, Email, EventTimeStamp from ibm_system.dbo.SP_OptOut WHERE IsProcessedInd = 0
   ) a

	UPDATE a
	SET  IsProcessedInd = 1 --, LastModifiedDateETL =GETDATE()
	FROM ibm_system.dbo.SP_EmailOptOut a
	INNER JOIN Staging.STG_KeyMapping b on a.CustomerID = b.CustomerID 
	WHERE    a.IsProcessedInd = 0

	SELECT @recordcount = @@ROWCOUNT

	UPDATE a
	SET  IsProcessedInd = 1 --, LastModifiedDateETL =GETDATE()
	FROM ibm_system.dbo.SP_OptOut a
	INNER JOIN Staging.STG_KeyMapping b on a.CustomerID = b.CustomerID 
	WHERE    a.IsProcessedInd = 0

	SELECT @successcountimport = @recordcount + @@ROWCOUNT
	
	SELECT @errorcountimport = @totalrecordcount - @successcountimport 

	SELECT @StepName = 'Data Import Detail Update'

	--EXEC uspSSISProcStepStart @spname, @StepName

	EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	  										    @importfilename = @importfilename,
	                                            @starttimeimport       = NULL,
	                                            @endtimeimport         = @now,
	                                            @totalcountimport      = @totalrecordcount,
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
	 
	 SELECT @StepName = 'STG_IbmWCA_OptOuts_Insert'
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
	SELECT @StepName = 'Staging.STG_IbmWCA_OptOuts_Insert Procedure Try'

	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	EXEC dbo.uspSSISProcStepSuccess @spname, @StepName

	
	RETURN 
END

