/*===========================================================================================
Name:			STG_Journey_ReasonForTravel_Update
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		USINARI
Modified:		

Peer Review:	
Call script:	e.g, EXEC Staging.STG_Journey_ReasonForTravel_Update 0, XXX
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_Journey_ReasonForTravel_Update]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    
	SET NOCOUNT ON;

   DECLARE @JourneyID				  INTEGER
	DECLARE @CVIQuestionID			  INTEGER
	DECLARE @CVIAnswerID				  INTEGER

	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	DECLARE @importfilename				NVARCHAR(256)
	
	
	DECLARE @StepName                 NVARCHAR(280)
	DECLARE @ProcName						 NVARCHAR(256)
	DECLARE @DbName				       NVARCHAR(256) 
	DECLARE @AuditType				       NVARCHAR(256) 
	DECLARE @SpId							 INT 
	
	
	DECLARE @DebugPrint					INT = 0
		
	DECLARE @recordcountIns            INTEGER       = 0
	
	DECLARE @recordcountUpd            INTEGER       = 0
	DECLARE @rowcountUpd					INTEGER       = 0
	DECLARE @rowcountIns					INTEGER       = 0

	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	SELECT @DbName = DB_NAME()
	SELECT @SpId = @@SPID
	SELECT @AuditType = 'PROCESS START'
	SELECT @StepName = 'Staging.STG_Journey_ReasonForTravel_Update ProcedureStart'

	
	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC uspSSISProcStepStart @spname, @StepName

	
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
		
   SELECT @recordcount = 0

	IF CURSOR_STATUS('global','Cur_Reasonfortravel')>=-1
   BEGIN
	CLOSE Cur_Reasonfortravel
	DEALLOCATE Cur_Reasonfortravel  
	END

	
	DECLARE Cur_Reasonfortravel CURSOR READ_ONLY
    FOR 
			SELECT d.journeyID, (SELECT CVIQuestionID FROM [Reference].[CVIQuestion] WHERE Name = 'REASON_FOR_TRAVEL') AS CVIQuestionID , b.CVIAnswerID 
			FROM PreProcessing.TOCPLUS_Journey a
			INNER JOIN staging.STG_Journey d on a.journeyid = d.ExtReference
			INNER JOIN [Reference].[CVIStandardAnswer] b
			--ON a.reasonfortravel = b.Value
			ON (case (a.reasonfortravel) when ' ' then 'EMPTY' when NULL then 'EMPTY' else a.reasonfortravel end) = b.Value
			WHERE a.DataImportDetailID = @dataimportdetailid
			--AND   a.ProcessedInd = 0

		   OPEN Cur_Reasonfortravel

			FETCH NEXT FROM Cur_Reasonfortravel    INTO @JourneyID, @CVIQuestionID, @CVIAnswerID

			WHILE @@FETCH_STATUS = 0
			  BEGIN

				   IF EXISTS (SELECT 1 FROM  [Staging].[STG_JourneyCVI] a
												WHERE JourneyID = @JourneyID
												AND CVIQuestionID = @CVIQuestionID)
												--AND CVIAnswerID = @CVIAnswerID)
					BEGIN
						UPDATE a
						SET 
								 LastModifiedDate = GETDATE()
								,LastModifiedBy = 1 
								,CVIQuestionID = @CVIQuestionID
								,CVIAnswerID = @CVIAnswerID

						FROM [Staging].[STG_JourneyCVI] a
						WHERE JourneyID = @JourneyID
						AND CVIQuestionID = @CVIQuestionID
						--AND CVIAnswerID = @CVIAnswerID
					
						SELECT @rowcountUpd = @@ROWCOUNT
						IF @rowcountUpd = 0
						BEGIN 

							SELECT @errorcountimport = @errorcountimport + 1
						
						END
						ELSE
						BEGIN
								SELECT @recordcountUpd = @recordcountUpd + @rowcountUpd
						END		
					
					END
					
					ELSE	 
					BEGIN

						INSERT INTO [Staging].[STG_JourneyCVI]
							(
							 [JourneyId]
							,[CVIQuestionID]
							,[CVIAnswerID]
							,[CreatedBy]
							,[CreatedDate]
							,[LastModifiedBy]
							,[LastModifiedDate]
						)
    
						SELECT      
							 @JourneyID
							,@CVIQuestionID
							,@CVIAnswerID
							,@userid AS CreatedBy
							,GETDATE() AS CreatedDate
							,@userid AS LastModifiedBy
							,GETDATE() AS LastModifiedDate
			
						SELECT @rowcountIns = @@ROWCOUNT
						SELECT @recordcountIns = @recordcountIns + @rowcountIns

					END

		    FETCH NEXT FROM Cur_Reasonfortravel   INTO @JourneyID, @CVIQuestionID, @CVIAnswerID

		END

		CLOSE Cur_Reasonfortravel
     
		DEALLOCATE Cur_Reasonfortravel


	SELECT @successcountimport = @recordcountUpd + @recordcountIns

	SELECT @recordcount = @successcountimport + @errorcountimport

	SELECT @StepName = 'Data Import Detail Update'

	--EXEC uspSSISProcStepStart @spname, @StepName

	
	--EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	--                                            @dataimportdetailid    = @dataimportdetailid,
	--                                            @operationalstatusname = 'Completed',
	--														  @importfilename = @importfilename,
	--                                            @starttimeimport       = NULL,
	--                                            @endtimeimport         = @now,
	--                                            @totalcountimport      = @recordcount,
	--                                            @successcountimport    = @successcountimport,
	--                                            @errorcountimport      = @errorcountimport

															  
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
	 
	 SELECT @StepName = 'STG_Journey_ReasonForTravel_Update'
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
	SELECT @StepName = 'Staging.STG_Journey_ReasonForTravel_Update Procedure Try'

	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC dbo.uspSSISProcStepSuccess @spname, @StepName


	RETURN 
END
GO


