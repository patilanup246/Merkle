/*===========================================================================================
Name:			[Railtimetable].[Rail_Timetable_XML_Insert] 
Purpose:		Insert national rail time table xml information into table PreProcessing.RailTimeTable
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-10-11	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC [Railtimetable].[Rail_Timetable_XML_Insert] 
=================================================================================================*/

CREATE PROCEDURE [Railtimetable].[Rail_Timetable_XML_Insert] 
@userid                INTEGER = 0,
@dataimportdetailid    INTEGER, 
@filepath              NVARCHAR(255),
@DebugPrint			   INTEGER = 0,
@PkgExecKey			   INTEGER = -1,
@DebugRecordset		   INTEGER = 0
----------------------------------------
AS 
BEGIN

	SET NOCOUNT ON;

	DECLARE @now                    DATETIME = GETDATE()
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @importfilename			NVARCHAR(256)


   DECLARE @spid	INTEGER	= @@SPID
   DECLARE @spname  SYSNAME = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
   DECLARE @dbname  SYSNAME = DB_NAME()
   DECLARE @Rows	INTEGER = 0
   DECLARE @ProcName NVARCHAR(50)
   DECLARE @StepName NVARCHAR(50)

   DECLARE @informationsourceid INT 

   DECLARE  @ErrorMsg		NVARCHAR(MAX)
   DECLARE  @ErrorNum		INTEGER
   DECLARE  @ErrorSeverity	 NVARCHAR(255)
   DECLARE  @ErrorState NVARCHAR(255)

   DECLARE @xml XML 

   EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SET @ProcName = 'Railtimetable.Rail_Timetable_XML_Insert'
   
    SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid

	SET @StepName = 'Insert rail timetable xml into preprocessing'
	BEGIN TRY		

		EXEC uspSSISProcStepStart @ProcName, @StepName

		INSERT INTO [PreProcessing].[RailTimeTable] (XMLData, CreatedDateETL, LastModifiedDateETL, ProcessedInd, DataImportDetailID)
		EXEC('SELECT CONVERT(XML, BulkColumn) AS BulkColumn, GETDATE() AS CreatedDateETL, GETDATE() AS LastModifiedDateETL,0, ' + @dataimportdetailid + '
		FROM OPENROWSET(BULK ''' + @filepath +''', SINGLE_BLOB) AS x;')

		EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;		

	-- End auditting
	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS END'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid, @PrintToScreen=@DebugPrint
 END
GO

