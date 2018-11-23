/*===========================================================================================
Name:			Preprocessing.TOCPlus_Customer_Email_Parser
Purpose:		Parse customer email address and update Preprocessing TOCPlus Customer Parsed email address fields
Parameters:		@dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-09-05	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Preprocessing.TOCPlus_Customer_Email_Parser
=================================================================================================*/

CREATE PROCEDURE [PreProcessing].[TOCPlus_Customer_Email_Parser]
@dataimportdetailid    INTEGER, 
@DebugPrint			   INTEGER = 0,
@PkgExecKey			   INTEGER = -1,
@DebugRecordset		   INTEGER = 0
----------------------------------------
AS 
BEGIN

	DECLARE @LoopCount INT = 0
	DECLARE @BatchSize INT = 100000
	DECLARE @RecordsCount INT = 0


	SELECT @RecordsCount = COUNT(*)
	FROM PreProcessing.TOCPLUS_Customer
	WHERE DataImportDetailID = @DataImportDetailID

	WHILE (@LoopCount * @BatchSize <= @RecordsCount)
	BEGIN
 
	IF OBJECT_ID(N'tempdb..#EmailUpdate') IS NOT NULL
	DROP TABLE #EmailUpdate
	SELECT [Staging].[ValidateEmail](emailaddress) AS ValidEmailAddress, TCScustomerID
	INTO #EmailUpdate
	FROM PreProcessing.TOCPLUS_Customer
	ORDER BY TCScustomerID 
	OFFSET (@LoopCount * @BatchSize) ROWS
	FETCH NEXT @BatchSize ROWS ONLY

	UPDATE A
	SET ParsedEmailInd = CASE WHEN  ValidEmailAddress = '1' THEN 1 ELSE 0 END 
		,ParsedAddressEmail = CASE WHEN  ValidEmailAddress = '1' THEN emailaddress ELSE null END
	,ParsedEmailScore = CASE WHEN  ValidEmailAddress = '1' THEN 100 else 0 end
	FROM PreProcessing.TOCPLUS_Customer A
	INNER JOIN #EmailUpdate B
	ON A.TCScustomerID = B.TCScustomerID

	SET @LoopCount = @LoopCount + 1

	END
 END 
GO


