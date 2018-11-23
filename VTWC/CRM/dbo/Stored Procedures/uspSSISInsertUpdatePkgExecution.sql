
/*===========================================================================================
Name:			uspSSISInsertUpdatePkgExecution
Purpose:		To insert/update package execution audit row
Created:		2010-12-08	Nitin Khurana
Modified:		2011-02-02  Philip Robinson. Remove COMMIT and ROLLBACK trans as no BEGIN TRAN and could cause error.
Modified:       2011-02-04  Philip Robinson. Adding select under first IF clause so always returns a value.
                            SSIS would fail if empty or no RS was returned.
Modified:       2011-02-19 Philip Robinson. Changed two IF stmts to IF...ELSE. This removes the loose coupling requirement 
                           that @PkgExecutionKeyIN must be zero. It will now work with the more usual default pkg key of -1.
                           This was causing some very obscure bugs when a null variable output was returned.
                           Besides, -1 is more commonly the default key setup in pkgs rather than 0.
                2012-06-19 Michal Zglinski. Added 3 new optional parameters @PathFolder, @InternalEmailTo, @ExternalEmailTo
                           to pass variables from SSIS packages (LoadAttributesKeys and LoadDimCustomerAndAttributeKeys)
				2013-12-11 Rich Hemmings. Changed default parameter values.
Peer Review:	
Call script:	
=================================================================================================*/

CREATE PROCEDURE [dbo].[uspSSISInsertUpdatePkgExecution]
@PkgName              varchar(50) = NULL
,@PkgGUID             uniqueidentifier = NULL
,@PkgVersionGUID      uniqueidentifier = NULL
,@PkgVersionMajor     smallint = NULL
,@PkgVersionMinor     smallint = NULL
,@ExecStartDT         datetime = NULL
,@PkgVersionBuild     smallint = NULL
,@PathFolder          varchar(255) = NULL
,@InternalEmailTo     varchar(8000) = NULL
,@ExternalEmailTo     varchar(8000) = NULL
,@ParentPkgExecKey    int = -1
,@PkgExecutionKeyIN   int = -1
,@PkgExecutionKeyOUT  int = NULL OUTPUT  

AS
BEGIN
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
	SET @PkgExecutionKeyOUT = -1;
	IF (@PkgExecutionKeyIN > 0)
	 BEGIN
	  UPDATE AuditPkgExecution
	  SET    ExecStopDT = getdate(),
			 SuccessFlag = 'Y'   
	  WHERE  PkgExecKey = @PkgExecutionKeyIN
	  
	  SET @PkgExecutionKeyOUT = @PkgExecutionKeyIN
	END
	ELSE
	BEGIN
	  INSERT INTO AuditPkgExecution 
				   (
					PkgName
				   ,PkgGUID
				   ,PkgVersionGUID
				   ,PkgVersionMajor
				   ,PkgVersionMinor
				   ,PkgVersionBuild
				   ,ExecStartDT
				   ,ParentPkgExecKey
				   ,PathFolder
                   ,InternalEmailTo
                   ,ExternalEmailTo
				   )
	  Values      (
				   @PkgName
				   ,@PkgGUID
				   ,@PkgVersionGUID
				   ,@PkgVersionMajor
				   ,@PkgVersionMinor
				   ,@PkgVersionBuild
				   ,@ExecStartDT
				   ,@ParentPkgExecKey
                   ,@PathFolder
                   ,@InternalEmailTo
                   ,@ExternalEmailTo
				  )

	  SET @PkgExecutionKeyOUT = (CAST(SCOPE_IDENTITY()  As Int))
	  
	  
	 END
	   
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000)
			   ,@ErrorNumber INT
			   ,@ErrorSeverity INT
			   ,@ErrorState INT
			   ,@ErrorLine INT
			   ,@ErrorProcedure VARCHAR(126);
		SELECT @ErrorNumber = ERROR_NUMBER()
			  ,@ErrorSeverity = ERROR_SEVERITY()
			  ,@ErrorState = ERROR_STATE()
			  ,@ErrorLine = ERROR_LINE()
			  ,@ErrorProcedure =ISNULL(ERROR_PROCEDURE(),'N/A');
		--Build the error message string
		--SELECT @ErrorMessage = 'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +
		--                                   'Message: '+ERROR_MESSAGE()

		--Rethrow the error
		RAISERROR
		(
			@ErrorMessage
		   ,@ErrorSeverity
		   ,1
		   ,@ErrorNumber
		   ,@ErrorSeverity
		   ,@ErrorState
		   ,@ErrorProcedure
		   ,@ErrorLine
		);
	END CATCH
END