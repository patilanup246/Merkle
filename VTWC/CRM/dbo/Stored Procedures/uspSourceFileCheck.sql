
/*===========================================================================================
Name:			 uspSourceFileCheck
Purpose:		 Checks that expected files have been received and loaded.
Parameters:		 @StartDate - [Optional] The range to run the expected checks over. 
                 If not specified the procedure will run for the current day only.
				 @EndDate - [Optional] The range to run the expected checks over.
				 @DebugPrint - Displays debug information to the message pane.
				 @DebugRecordSet - When implmented, used to control displaying debug recordset information
								   to screen, or storing debug recordsets to global temp tables.
				
Notes:			 This is based on the BAYF file checking routine but only looks at whether a file
				 is received, and loaded, not at the count of those files to obtain an average.
				 This is because on certain days (such as weekends) we often (usually) receive
				 empty files for some file types because transactions are not processed over the weekend.
             
			
Created:		2012-11-12	Dean Griffith
Modified:		2012-11-15  Philip Robinson. Amended so @DebugPrint not a depenancy for debug email.
											 Removed some files from config table as not daily files.
				2013-01-17	Steve Blackman. Copied and ammended to work with Lloyds Pharmacy.
											Creates a success and error emails.
											Email addresses taken from dbgConfigurationParameters. seperate for success and error.
											Compass success flag file created and put on sftp site to indicate successful load.
											NOTE: Need to check if load window occurs on same day.
				2014-06-26	Rob Lewis		Added time check to set date range because if this is run after midnight it wont pick files up.

				2014-07-24  Chris Stubbs	Added wildcard to check for frequency of feeds as some contain an extra * from the Daily reports.

Call script:	
EXEC uspSourceFileCheck @startdate='03 Jan 2013', @enddate='03 Jan 2013', @debugprint=1, @debugrecordset=1 , @DebugEmailAddress = 'steve.blackman@dbg.co.uk'
=================================================================================================*/
CREATE PROCEDURE dbo.uspSourceFileCheck
				@StartDate date = NULL,
				@EndDate date = NULL,
				@PkgExecKey int = 0,
				@DebugEmailAddress varchar(8000) = NULL,
				@DebugPrint tinyint = 0,
				@DebugRecordSet tinyint = 0
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

  -- CONFIGURATION: All proc configurable parts are in this section.
  -- Enter details of expected files in the table below.
  ---------------------------------------------------------  
	DECLARE @ThisDb sysname = DB_NAME()
		  , @Rows int
		  , @ThisProc sysname = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNOWN')
		  , @FileName varchar(127)
		  , @SPID int = @@SPID
		  , @updates varchar(max)
		  ,	@cr char(1) = CHAR(10)
		  
		  -- email
		  , @Profile varchar(255)        
		  , @Subject varchar(255)
		  , @Body VARCHAR(MAX)
		  , @Year VARCHAR(4)

--LLOYDS SPECIFIC REMOVE IF NEEDED AND SEARCH AND REPLACE THE VARIABLES @EndDate/@StartDate
    --   -- Set start and end dates
	   ---- Note if the files start loading on day A and continue into day B, the files in day B will be excluded.  
	   ---- If we search for files from day B it will listall files as missing from this day.
    --   IF	CAST(GETDATE() AS TIME) >= '00:00:00'
    --   AND	CAST(GETDATE() AS TIME) <= '13:00:00' 
    --   SET	@StartDate = COALESCE(@StartDate, GETDATE()-1)
    --   ELSE  
    --   SET	@StartDate = COALESCE(@StartDate, GETDATE());

	   --SET	@EndDate = @StartDate;

	-- Get current year
	SET @Year = DATEPART(yyyy, GETDATE())
	
	-- Find email profile to use
	SELECT TOP 1 @Profile = name
	FROM msdb.dbo.sysmail_profile
	-- The ORDER BY clause is used to find the best matching dbmail profile if one exists similar to the DB_NAME() 
	--(removing DW from the name so TalkTalkDW searching for a profile containing 'LloydsPharmacy')
	ORDER BY CASE WHEN name LIKE '%'+REPLACE(DB_NAME(), 'DW','')+'%' 
                 THEN 1 ELSE 2 END
				 

	---------------------------------------------------
	-- Set Email recipients
	--------------------------------------------------- 
	DECLARE @RecipientsSuccess varchar(8000),
			@RecipientsError varchar(8000)
	
	EXEC dbo.uspAuditAddAudit @AuditType='TRACE START',@Process=@ThisProc, @DatabaseName=@ThisDb,@SPID =@SPID, @PrintToScreen=@DebugPrint
		                      , @ProcessStep='Set Email Recipient', @Message=NULL, @Rows=NULL
  
	-- Use debug email address if one supplied.
	IF @DebugEmailAddress IS NOT NULL 
	BEGIN
		SET	@RecipientsSuccess = @DebugEmailAddress
		SET @RecipientsError =  @DebugEmailAddress
	END	
	-- If no debug email address provided get the email addresses specified in dbgConfigurationParameters
	ELSE 
	BEGIN
		SELECT @RecipientsSuccess = [Value] FROM dbo.[dbgConfigurationParameters] WHERE [Parameter] = 'LoadCheckEmailGroupSuccess'
		SELECT @RecipientsError = [Value] FROM dbo.[dbgConfigurationParameters] WHERE [Parameter] = 'LoadCheckEmailGroupError'
	END

	EXEC dbo.uspAuditAddAudit @AuditType='TRACE END',@Process=@ThisProc, @DatabaseName=@ThisDb,@SPID =@SPID, @PrintToScreen=@DebugPrint
		                      , @ProcessStep='Set Email Recipient' , @Message=NULL, @Rows=@@ROWCOUNT


	---------------------------------------------------
	-- Set file statuses
	--------------------------------------------------- 
	-- What statuses we should send alerts on (comma seperated list):
	--  MISSING: The file does nto exist in AuditFeedFile
	--  UNPROCESSED: A file entry exists in AuditFeedFile but does not have an ETLStartDate
	--  ERROR: A file entry exists with an ETLStartDate but no ETLStopDate. usually indicative of an error.
	--------------------------------------------------- 

	DECLARE @SendAlertForTheseStatus varchar(50) = 'MISSING, UNPROCESSED, ERROR, LOADED'
  
	IF OBJECT_ID('tempdb.dbo.#ExpectedFiles') IS NOT NULL DROP TABLE #ExpectedFiles

	CREATE TABLE #ExpectedFiles	
		(SpecificationName VARCHAR(255), 
		FilePart VARCHAR(255), 
		WhenExpected VARCHAR(255))
    
	INSERT #ExpectedFiles (SpecificationName, FilePart, WhenExpected)
	SELECT FileSpecificationName, REPLACE(FileNameWildCard,'*','%') + '%', TransferFrequency
	FROM dbo.MetadataFileSpecification
	--WHERE FileSpecificationName NOT IN ('')

	IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Built table #ExpectedFiles. '+CONVERT(varchar,@@ROWCOUNT)+' rows.'


	-- Modified as some feeds have a value of Daily*
	UPDATE #ExpectedFiles 
	SET WhenExpected = 'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday'
	WHERE WhenExpected LIKE 'Daily%'
	
	--------------------------------------------------- 
	-- Processing: Calculate if any files are missing or unprocessed.
	--------------------------------------------------- 
	IF OBJECT_ID('tempdb.dbo.#MissingFiles') IS NOT NULL DROP TABLE #MissingFiles
  
	CREATE TABLE #MissingFiles (
		theDate date
		, ExpectedDay varchar(30) -- Debug only
		, SpecificationName VARCHAR(255)
		, FilePart varchar(255)
		, FileLoadStatus varchar(30)
		, OriginalFileName varchar(255))

  		-- DECLARE @startdate date ='07 Jul 2014', @enddate date ='10 Jul 2014'
		-- FileLoadStatus - see description near top of script.

		;WITH CTE_DateRange AS (SELECT TheDate
								FROM dbo.DimDate 		
								WHERE CONVERT(date, TheDate) BETWEEN @StartDate AND @EndDate),
		CTE_ExpectedDays AS		(SELECT SpecificationName, 
										FilePart, 
										split.Item AS ExpectedDay
								 FROM #ExpectedFiles
								 CROSS APPLY dbo.fnSplitStringList(WhenExpected, ',') split)

		INSERT #MissingFiles (
			theDate 
			, ExpectedDay 
			, SpecificationName
			, FilePart 
			, FileLoadStatus 
			, OriginalFileName)

		SELECT theDate
			, ExpectedDay
			, SpecificationName
			, REPLACE(FilePart, '%', '*') AS FilePart     -- Remove % for presentation reasons.
			, CASE	WHEN af.FeedFileKey IS NULL THEN 'MISSING' 
					WHEN af.FeedFileKey IS NOT NULL 
					  AND ETLStartDate IS NULL THEN 'UNPROCESSED'
					WHEN af.FeedFileKey IS NOT NULL 
					  AND ETLStartDate IS NOT NULL
					  AND ETLStopDate IS NULL THEN 'ERROR'
					ELSE 'LOADED' 
			  END AS FileLoadStatus
			,  af.OriginalFileName
		FROM CTE_DateRange cte_d
		LEFT JOIN CTE_ExpectedDays cte_e ON DATENAME(dw, cte_d.TheDate) = cte_e.ExpectedDay
		LEFT JOIN dbo.AuditFeedFile af ON af.OriginalFileName LIKE cte_e.FilePart
		  -- Most file types join on ETL date. For the DBGyyymmdd.ZIP use DropDate. If ETLStart is blank, use DropDate.
		  AND (TheDate = CONVERT(DATE, af.ETLStartDate) 
		  OR TheDate = CONVERT(DATE, af.DropDate) 
		  OR TheDate = CONVERT(DATE, af.DropDate) AND ETLStartDate IS NULL)

	IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Built table #MissingFiles. '+CONVERT(varchar,@@ROWCOUNT)+' rows.'  
  
	-- Display results to screen for full debug mode.
	IF @DebugRecordSet>0 SELECT '#MissingFiles' AS [#MissingFiles], * FROM #MissingFiles

	--------------------------------------------------- 
	-- Build and send success email
	--------------------------------------------------- 
	IF EXISTS (SELECT TOP 1 1 FROM #MissingFiles WHERE FileLoadStatus = 'LOADED')
	BEGIN
		-- Set header.
		SET @Body = '<HTML> <HEAD><TITLE></TITLE> </head> 
			<table WIDTH=100% BORDER=0 CELLSPACING=1 CELLPADDING=1> <tr bgcolor=#0080C0 style="color:#ffffff;font-size:9pt;font- weight:200;" class="white"> 
			<td width="80%" bgcolor="#FFFFFF"> 
			  <font color="#000000"><span style="font-weight: 200"> 
			  <font face="Arial" style="font-size: 20pt"> 
			  <a title="Audit Report"> <TD width="20%" bgcolor="#FFFFFF">
			  <p align="right"><span style="font-weight: 400"> 
			  <font color="#000000"><br><font face="Arial" size="3"> 
			  <br>
			</font></font></span>
			</td> </tr> </table> 
			<table WIDTH=100% BORDER=0 CELLSPACING=1 CELLPADDING=1 height="50"> <tr bgcolor=#0080C0 style="color:#ffffff;font-size:9pt;font-weight:500;" class="white"> 
			  <td width="100%" bgcolor="#990033"> 
			  <font face="Arial" style="font-weight: 700; vertical-align: bottom" size="5"> 
			  Loaded Files  
				<font color="#C0C0C0">Notification</font></table>
				<table WIDTH=100% BORDER=0 CELLSPACING=1 CELLPADDING=1> 
				<tr bgcolor=#0080C0 style="color:#ffffff;font-size:9pt;font-weight:200;" class="white"> 
				  <td width="33%" bgcolor="#FFFFFF"> <font color="#000000"> 
				  <p align="center">&nbsp;</p></td> </tr> </table> 
				  <p align="center"> 
				  </a><br>&nbsp;</font></span></td> <p align="center">
				  <font face="Arial" size="6" color="#000080">
		  
				  <!-- Configure header text here. -->
				  The following files loaded sucessfully into '+DB_NAME()+' on '+ @@SERVERNAME +'
		  
		  
				
			  <table border="2" cellspacing="0" cellpadding="7">
			  <tr>
			  <td><b>Feed Name </b></td>
			  <td><b>File Name Pattern</b></td>
			  <td><b>Expected Day</b></td>
			  <td><b>File Load Status</b></td>
			  <td><b>File Name</b></td>
			  <td><b>Load Date</b></td>
			  </tr>'

		-- Set table elements.
		SELECT @Body +=
            + '<font face="Arial" size="1" color="#000080">'
            + '<tr>'
			+ '<td>' +ISNULL(SpecificationName,'')+ '</td>'
            + '<td>' +ISNULL(FilePart,'')+ '</td>'
            + '<td align="right">' +ISNULL(ExpectedDay,'')+ '</td>' 
            + '<td align="right">' +ISNULL(FileLoadStatus,'')+ '</td>' 
            + '<td align="right">' +ISNULL(OriginalFileName,'')+ '</td>' 
            + '<td align="right">' +ISNULL(CONVERT(varchar, theDate),'')+ '</td>' 
            + '</tr></font>' 
		FROM #MissingFiles
		WHERE FileLoadStatus = 'LOADED'
		
		  
		-- Set footer.
		SET @Body +='</table><br><br>NO ACTION REQUIRED <br><br> 
					 <p align="center">
					 <font size="2" color="#0000FF">All Reports are Copyright dbg ' + @Year + ' (C) </font></p> 
					 </body></html>'

		-- Set Subject
		SET @Subject = DB_NAME()+ ' Loaded Files Check - ' + DATENAME(weekday, GETDATE()) + ' ' + CAST(GETDATE() AS VARCHAR)
		

		-- Send the email
		---------------------------------------------------------
		IF @RecipientsSuccess IS NOT NULL
		BEGIN
			EXEC [msdb].[dbo].[sp_send_dbmail] @profile_name = @profile
                                 , @Recipients = @RecipientsSuccess
                                 , @body = @body
                                 , @subject = @subject
                                 --, @importance ='High'
                                 , @body_format = 'HTML'
		END
	END


	--------------------------------------------------- 
	-- Build and send ERROR email
	--------------------------------------------------- 
	IF EXISTS (SELECT TOP 1 1 FROM #MissingFiles WHERE FileLoadStatus <> 'LOADED' AND FileLoadStatus IS NOT NULL)
	BEGIN
		-- Set header.
		SET @Body = '<HTML> <HEAD><TITLE></TITLE> </head> 
			 <table WIDTH=100% BORDER=0 CELLSPACING=1 CELLPADDING=1> <tr bgcolor=#0080C0 style="color:#ffffff;font-size:9pt;font- weight:200;" class="white"> 
			<td width="80%" bgcolor="#FFFFFF"> 
			  <font color="#000000"><span style="font-weight: 200"> 
			  <font face="Arial" style="font-size: 20pt"> 
			  <a title="Audit Report"> <TD width="20%" bgcolor="#FFFFFF">
			  <p align="right"><span style="font-weight: 400"> 
			  <font color="#000000"><br><font face="Arial" size="3"> 
			  <br>
			</font></font></span>
			</td> </tr> </table> 
			<table WIDTH=100% BORDER=0 CELLSPACING=1 CELLPADDING=1 height="50"> <tr bgcolor=#0080C0 style="color:#ffffff;font-size:9pt;font-weight:500;" class="white"> 
			  <td width="100%" bgcolor="#990033"> 
			  <font face="Arial" style="font-weight: 700; vertical-align: bottom" size="5"> 
			  Expected Feeds 
				<font color="#C0C0C0">Notification</font></table>
				<table WIDTH=100% BORDER=0 CELLSPACING=1 CELLPADDING=1> 
				<tr bgcolor=#0080C0 style="color:#ffffff;font-size:9pt;font-weight:200;" class="white"> 
				  <td width="33%" bgcolor="#FFFFFF"> <font color="#000000"> 
				  <p align="center">&nbsp;</p></td> </tr> </table> 
				  <p align="center"> 
				  </a><br>&nbsp;</font></span></td> <p align="center">
				  <font face="Arial" size="6" color="#000080">
		  
				  <!-- Configure header text here. -->
				  Possible issue with '+DB_NAME()+' feed supply on '+ @@SERVERNAME +'
		  
		  
				  <br> 
			  <p align="center"><font face="Arial" size="4" color="#000080"> 
			  <br> The automated source file test has detected the following potential issues.<br>Please Investigate.
			  <br><br><br>
			  <table border="2" cellspacing="0" cellpadding="7">
			  <tr>
			  <td><b>Feed Name </b></td>
			  <td><b>File Name Pattern</b></td>
			  <td><b>Expected Day</b></td>
			  <td><b>File Load Status</b></td>
			  <td><b>File Name</b></td>
			  <td><b>Date</b></td>
			  </tr>'   
  
		-- Set table elements.
		SELECT @Body +=
					+ '<font face="Arial" size="1" color="#000080">'
					+ '<tr>'
					+ '<td>' +ISNULL(SpecificationName,'')+ '</td>'
					+ '<td>' +ISNULL(FilePart,'')+ '</td>'
					+ '<td align="right">' +ISNULL(ExpectedDay,'')+ '</td>' 
					+ '<td align="right">' +ISNULL(FileLoadStatus,'')+ '</td>' 
					+ '<td align="right">' +ISNULL(OriginalFileName,'')+ '</td>' 
					+ '<td align="right">' +ISNULL(CONVERT(varchar, theDate),'')+ '</td>' 
					+ '</tr></font>' 
		FROM #MissingFiles
		WHERE FileLoadStatus <> 'LOADED' 
		  AND FileLoadStatus IS NOT NULL

  
		-- Set footer.
		SET @Body +='</table><br><br>ACTION REQUIRED <br><br> 
					<p align="center">
					<font size="2" color="#0000FF">All Reports are Copyright dbg ' + @Year + ' (C) </font></p> 
					</body></html>'
		
		-- Set Subject
		SET @Subject = DB_NAME()+ ' Expected File Check - ' + DATENAME(weekday, GETDATE()) + ' ' + CAST(GETDATE() AS VARCHAR)
						

		-- Send the email
		---------------------------------------------------------
		IF @RecipientsError IS NOT NULL
		BEGIN
			EXEC [msdb].[dbo].[sp_send_dbmail] @profile_name = @profile
                                 , @Recipients = @RecipientsError
                                 , @body = @body
                                 , @subject = @subject
                                 , @importance ='High'
                                 , @body_format = 'HTML'
		END
	END
	

--Seems to be Lloyds specific.  Test without this and remove if happy.

	----------------------------------------------------- 
	---- Create Compass success flag files and put on SFTP site
	----------------------------------------------------- 
	--DECLARE @FilePath varchar(255)
	--SELECT @FilePath = [Value] FROM dbo.[dbgConfigurationParameters] WHERE [Parameter] = 'LoadSuccessFilePath'
	
	
	--IF EXISTS (SELECT TOP 1 1 FROM #MissingFiles WHERE FileLoadStatus = 'LOADED' AND FilePart LIKE '%_COM_%') AND @FilePath IS NOT NULL
	--BEGIN 
	--	DECLARE @LoadedFileName VARCHAR(50)

	--	-- get the loaded files
	--	IF OBJECT_ID('tempdb.dbo.#LoadedFiles') IS NOT NULL DROP TABLE #LoadedFiles		
		
	--	SELECT OriginalFileName,
	--		CAST(0 as bit) AS Processed
	--	INTO #LoadedFiles
	--	FROM #MissingFiles 
	--	WHERE FilePart LIKE '%_COM_%'
	--	AND FileLoadStatus = 'LOADED'

	--	WHILE EXISTS (SELECT TOP 1 1 FROM #LoadedFiles WHERE Processed=0)
	--	BEGIN
	--		-- get the file name
	--		SELECT TOP 1 @LoadedFileName=OriginalFileName + '.OK' FROM #LoadedFiles WHERE Processed=0
			
	--		-- create the file and put on the ftp site
	--		EXEC DbgCentral.dbo.clrExtractResultSet 
	--			 @sqlSource = 'SELECT '''''
	--			,@sqlTargetFolder = @FilePath
	--			,@sqlTargetFile =  @LoadedFileName  
	--			,@sqlDelimiter = '|'
	--			,@sqlRightAlignColumnList = NULL
	--			,@sqlOptions = 'HQ'
	--			,@sqlDebug = 0	
				
	--		UPDATE #LoadedFiles
	--		SET Processed=1
	--		WHERE OriginalFileName=REPLACE(@LoadedFileName,'.OK','')
	--	END
	--END

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