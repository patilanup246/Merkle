
/*===============================================================================================
Name:			uspProcCreateAuditRows.sql
Purpose:		Inserts an AuditTableProcessing row exists for the specified file and inserts a
                DimAudit row. This proc should not be used in an SSIS package - use
                uspGetAuditTablesKeys instead.
Parameters:		@TableName	  - The name of the table that is being populated with data.
                @ProcessingSummaryGroup - Allows you to specify the ProcessingSummaryGroup written
                                          to the DimAudit row.
Outputs:		@TableProcessKey  - The key of the AuditTableProcessing row that is created/updated
								    by this stored procedure.
				@DimAuditKey  - The key of the DimAudit row that is created/updated by this
								stored procedure.
Notes:			    
			
Created:		2016-04-11	Caryl Wills
Modified:		

Peer Review:	
Call script:	EXEC uspProcCreateAuditRows ?,?,?
=================================================================================================*/
CREATE PROCEDURE dbo.uspProcCreateAuditRows
				 @TableName VARCHAR(50),
				 @TableProcessKey INT OUTPUT,
				 @DimAuditKey INT OUTPUT,
				 @ProcessingSummaryGroup VARCHAR(200) = 'Normal'
AS
SET XACT_ABORT ON;
SET NOCOUNT ON;
BEGIN TRY
	DECLARE @RC_Initial INT = -1
	
	-- Get the initial rowcount from the table we're working on.  We are
	-- using the data from sysindexes beacuse it is quicker than getting
	-- the row count from COUNT(1) on very large tables.	
	SET @TableProcessKey = NULL;
	SET @DimAuditKey = NULL;
	
    SELECT @RC_Initial = rows FROM sysindexes 
    WHERE OBJECT_NAME(id) = CASE WHEN CHARINDEX('.', REVERSE(@Tablename)) > 0
                                 THEN RIGHT(@TableName, CHARINDEX('.', REVERSE(@Tablename)) - 1)
                                 ELSE @TableName
                            END
      AND indid <= 1  

	INSERT INTO AuditTableProcessing
	(
		PkgExecKey,
		FeedFileKey,
		TableName,
		TableInitialRowCnt,
		ShowInLoadReport
	)
	VALUES
	(
		-1,
		-1,
		@TableName,
		@RC_Initial,
		'Y'
	)

	SELECT @TableProcessKey = CONVERT(INT,SCOPE_IDENTITY())

	-- Now insert a DimAudit row.
	INSERT INTO DimAudit
	(
		TableProcessKey,
		BranchName,
		ProcessingSummaryGroup
	)
	VALUES
	(
		@TableProcessKey,
		@TableName,
		@ProcessingSummaryGroup
	)

	SELECT @DimAuditKey = CONVERT(INT,SCOPE_IDENTITY())

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
	SELECT @ErrorMessage = 'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +
						   'Message: ' + ERROR_MESSAGE()      

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