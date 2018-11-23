
/*===============================================================================================
Name:			uspSSISGetAuditTablesKeys
Purpose:		Checks to see if an AuditFeedFile row exists for the specified
				file and if not inserts one.
Parameters:		@TableName	  - The name of the table that is being populated with data.
				@PkgExecKey	  - The primary key of the AuditPkgExec row under which this ETL
								process is running.
				@FeedFileKey  - The key of the AuditFeedFile row that is created/updated by
								this stored procedure.
Outputs:		@TableProcessKey  - The key of the AuditTableProcessing row that is created/updated
								by this stored procedure.
				@DimAuditKey  - The key of the DimAudit row that is created/updated by this
								stored procedure.
Notes:			    
			
Created:		2009-05-23	Caryl Wills
Modified:		2011-05-01  Philip Robinson. Fixed logic. TableProcessing row not created when -1
							passed in as TableProcessKey.
                2011-05-26	Philip Robinson. Removed transaction.
				2011-11-22	Ryan Brownley. Added @ProcessingSummaryGroup parameter to pass to
							DimAudit for later join.
                2016-04-08  Caryl Wills. Changed the code used to establish the number of rows in a table
                            so that it can cope with a fully qualified (schema.tablename) table name.
Peer Review:	
Call script:	EXEC uspSSISGetAuditTablesKeys ?,?,?
=================================================================================================*/
CREATE PROCEDURE dbo.uspSSISGetAuditTablesKeys
				 @TableName VARCHAR(50),
				 @PkgExecKey INT,
				 @FeedFileKey INT,
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
    WHERE object_name(id) = CASE WHEN CHARINDEX('.', REVERSE(@Tablename)) > 0
                                 THEN RIGHT(@TableName, CHARINDEX('.', REVERSE(@Tablename)) - 1)
                                 ELSE @TableName
                            END
      AND indid <= 1  

    SELECT @TableProcessKey = TableProcessKey
    FROM dbo.AuditTableProcessing
    WHERE PkgExecKey = @PkgExecKey
	AND	FeedFileKey = @FeedFileKey
	AND	TableName = @TableName

    IF @TableProcessKey IS NULL OR @TableProcessKey <= 0
      BEGIN 
	    INSERT INTO AuditTableProcessing
	    (
		    PkgExecKey,
		    FeedFileKey,
		    TableName,
		    TableInitialRowCnt,
		    ShowInLoadReport
	    )
	    Values
	    (
		    @PkgExecKey,
		    @FeedFileKey,
		    @TableName,
		    @RC_Initial,
		    'Y'
	    )

	    SELECT @TableProcessKey = CONVERT(INT,SCOPE_IDENTITY())
	  END

	-- Now insert a DimAudit row.
	INSERT INTO DimAudit
	(
		TableProcessKey,
		BranchName,
		ProcessingSummaryGroup
	)
	Values
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