/*===========================================================================================
Name:		dbo.uspUtilityToResetAuditFeedFileRow
Notes:  Takes action on a FeedFileRow to either reset the ETLStartDate or mark a row as not reportable.
        
If @Function = SetSuccess, then SuccessFlag=Y and ShowInLoadReport = Y.
If @Function = SetReportabletoNo, then ShowInLoadReport is set to N for the file
If @Function = SetReportabletoYes, then ShowInLoadReport is set to Y for the file
If @Function = ResetStartDate then ETLStartDate is set to NULL for the file.
If @Function = Help then display usage information to screen then exit.

The input parameters to this procedure must be either FeedfileKey OR @OriginalFileName       
Created	by Joey Breame 20042011
=================================================================================================*/
CREATE PROCEDURE [dbo].[uspUtilityToResetAuditFeedFileRow] 
  @Function  varchar(255),
  @OriginalFileName varchar(255) = NULL,
  @FeedFileKey INT = -1,
  @DebugPrint int = 0,
  @DebugRecordset int = 0
  
AS
BEGIN

SET XACT_ABORT ON;
SET NOCOUNT ON;

DECLARE @ErrNo INT;
DECLARE @ErrMsg VARCHAR(400);
DECLARE @ROWS AS INT;
DECLARE @ValidatedFeedFileKey int = NULL


BEGIN TRY

  PRINT '-- For information about how to use this function - run using @Function=''Help'''
  IF @Function = 'Help'
  BEGIN
    PRINT '--****************************************'
    PRINT '@Function = SetReportabletoNo, then ShowInLoadReport is set to N for the file'          
    PRINT '@Function = SetReportabletoYes, then ShowInLoadReport is set to Y for the file'
    PRINT '@Function = ResetStartDate then ETLStartDate is set to NULL for the file.'
    PRINT '@Function = SetSuccess, then SuccessFlag=Y and ShowInLoadReport = Y.'
    PRINT 'Either @OriginalFileName or @FeedFileKey must be provided, but not both'
    RETURN;
  END


  -- *****************************************************************
  -- VALIDATION
  -- *****************************************************************
  -- Check *either* file name or feed file key but not both
  IF @FeedFileKey > 0 AND LEN(ISNULL(@OriginalFileName,'')) > 0
  BEGIN
    RAISERROR ('You must specify either OriginalFileName or @FeedFileKey but not both. @FeedFileKey is only required when a duplicate OriginalFileName exists.', 16, 1); 
  END

  -- Check we have at least one of the required params.
  IF NOT ISNULL(@FeedFileKey,-1) > 0 AND LEN(ISNULL(@OriginalFileName,'')) = 0
  BEGIN
    RAISERROR ('You must specify either OriginalFileName or @FeedFileKey. @FeedFileKey is only required when a duplicate OriginalFileName exists.', 16, 1); 
  END

  -- Check there are not two files with the supplied name. 
  -- If duplicate files name exists, the action can only be performed by passing in FeedFilekey.
  IF LEN(ISNULL(@OriginalFileName,'')) > 0
     AND EXISTS (SELECT OriginalFileName
                 FROM dbo.AuditFeedFile
                 WHERE OriginalFileName = @OriginalFileName
                 GROUP BY OriginalFileName
                 HAVING COUNT(*)>1 )
  BEGIN
    RAISERROR ('More than one file called "%s" was found. When duplicate files exist you must use parameter @FeedFileKey (not @OriginalFileName) to target the correct feed file row.', 16, 1, @OriginalFileName); 
  END


  -- Validate the feed file key.
  IF ISNULL(@FeedFileKey,-1) NOT IN (-1, 0)
     AND NOT EXISTS (SELECT OriginalFileName
                     FROM dbo.AuditFeedFile
                     WHERE FeedFileKey = @FeedFileKey )
  BEGIN
    RAISERROR ('Entry for @FeedFileKey %i not found.', 16, 1, @FeedFileKey); 
  END


  -- Get and validate @FeedFileKey when OriginalFileName provided.
  ---------------------------------------------------------
  SELECT @ValidatedFeedFileKey = FeedFileKey
  FROM dbo.AuditFeedFile
  WHERE OriginalFileName = @OriginalFileName
     OR (FeedFileKey = @FeedFileKey AND ISNULL(@FeedFileKey,-1) NOT IN (0,-1) )


  --If there is no Feedfilekey, derive it from OriginalFileName
  IF NOT ISNULL(@ValidatedFeedFileKey, -1) > 0
  BEGIN
    RAISERROR ('No file row found based on pass parameters.', 16, 1); 
  END


  IF @DebugRecordset>0 SELECT '@DebugRecordset' AS DebugRecordset, @OriginalFileName AS [@OriginalFileName]
                                                                 , @FeedFileKey AS [@FeedFileKey]
                                                                 , @ValidatedFeedFileKey AS [@ValidatedFeedFileKey]

  -- *****************************************************************
  -- PERFORM THE ACTIONS
  -- *****************************************************************
  IF @Function = 'ResetStartDate' 
  BEGIN
    UPDATE dbo.AuditFeedFile
    SET ETLStartDate = NULL
    WHERE FeedFileKey = @ValidatedFeedFileKey  
      AND @ValidatedFeedFileKey > 0
    
    PRINT CONVERT(varchar(19), getdate(),121)+' ETLStartDate = NULL. '+CONVERT(varchar,@@ROWCOUNT)+' rows.'
  END
  -----------------------------------------------------------------------------------------------
  IF @Function = 'SetSuccess'
  BEGIN
      UPDATE dbo.AuditFeedFile
      SET SuccessFlag = 'Y'
        , ShowInLoadReport = 'Y'
        , ProcessStatus = 'Success(manual)'
      WHERE FeedFileKey = @ValidatedFeedFileKey  AND @ValidatedFeedFileKey > 0
          
      PRINT CONVERT(varchar(19), getdate(),121)+' Set SuccessFlag=Y. '+CONVERT(varchar,@@ROWCOUNT)+' rows.'
  END
  -----------------------------------------------------------------------------------------------
  IF @Function = 'SetReportabletoNo'
  BEGIN
      UPDATE dbo.AuditFeedFile
      SET ShowInLoadReport = 'N'
      WHERE FeedFileKey = @ValidatedFeedFileKey  AND @ValidatedFeedFileKey > 0
          
      PRINT CONVERT(varchar(19), getdate(),121)+' Set ShowInLoadReport=N. '+CONVERT(varchar,@@ROWCOUNT)+' rows.'
  END
  -----------------------------------------------------------------------------------------------
  IF @Function = 'SetReportabletoYes' 
  BEGIN
      UPDATE dbo.AuditFeedFile
      SET ShowInLoadReport = 'Y'
      WHERE FeedFileKey = @ValidatedFeedFileKey  AND @ValidatedFeedFileKey > 0;
      
      PRINT CONVERT(varchar(19), getdate(),121)+' Set ShowInLoadReport=Y. '+CONVERT(varchar,@@ROWCOUNT)+' rows.'
  END


END TRY
BEGIN CATCH
	DECLARE 
		@ErrorMessage VARCHAR(4000),
		@ErrorNumber INT,
		@ErrorSeverity INT,
		@ErrorState INT,
		@ErrorLine INT,
		@ErrorProcedure VARCHAR(126);

	SELECT 
		@ErrorNumber = ERROR_NUMBER(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE(),
		@ErrorLine = ERROR_LINE(),
		@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), 'N/A');

	--Build the error message string
	SELECT @ErrorMessage = ERROR_MESSAGE()+ 'Error %d, Level %d, State %d, Procedure %s, Line %d'

	--Rethrow the error
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
END