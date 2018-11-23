/*===========================================================================================
Name:			Preprocessing.TOCPlus_Customer_Profanity_Update
Purpose:		Parse customer forename and surname, then update Preprocessing TOCPlus Customer profanity indicator fields
Parameters:		@dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-09-05	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC Preprocessing.TOCPlus_Customer_Profanity_Update
=================================================================================================*/

CREATE PROCEDURE [PreProcessing].[TOCPlus_Customer_Profanity_Update]
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
 
	IF OBJECT_ID(N'tempdb..#ProfanityInd') IS NOT NULL
	DROP TABLE #ProfanityInd
	SELECT [Staging].[profanitycheck] (forename + '' + surname) AS ProfanityInd, TCScustomerID
	INTO #ProfanityInd
	FROM PreProcessing.TOCPLUS_Customer
	WHERE DataImportDetailID = @dataimportdetailid
	ORDER BY TCScustomerID 
	OFFSET (@LoopCount * @BatchSize) ROWS
	FETCH NEXT @BatchSize ROWS ONLY

	UPDATE A
	SET A.profanityInd = B.ProfanityInd
	FROM PreProcessing.TOCPLUS_Customer A
	INNER JOIN #ProfanityInd B
	ON A.TCScustomerID = B.TCScustomerID
	AND A.DataImportDetailID = @dataimportdetailid

	SET @LoopCount = @LoopCount + 1

	END
 END 
GO


