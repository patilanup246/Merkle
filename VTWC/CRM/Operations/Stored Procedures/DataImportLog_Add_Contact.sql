CREATE PROCEDURE [Operations].[DataImportLog_Add_Contact]
(

	 @increment	INTEGER

)
AS
BEGIN
--
	DECLARE @now                        DATETIME
	DECLARE @endate                        DATETIME

 SELECT @endate=MAX(DateQueryEnd), @now = GETDATE() FROM [CEM].[Operations].[DataImportLog] 
 WHERE DataImportTypeID = 1 


 IF DATEADD(day,@increment,@endate) < @now 
	EXEC [Operations].[DataImportLog_Add_Increment] @dataimporttypeid = 1, 	 @dateparttype = 2	, @dateinc = @increment; 
ELSE
	EXEC [Operations].[DataImportLog_Add] @dataimporttypeid = 1;

END