CREATE PROCEDURE [Operations].[DataImportLog_Add_Other]
(

	 @Datatype INTEGER,
	 @increment	INTEGER

)
AS
BEGIN
--
	DECLARE @now                        DATETIME
	DECLARE @endate                        DATETIME

 SELECT @endate=MAX(DateQueryEnd), @now = GETDATE() FROM [CEM].[Operations].[DataImportLog] 
 WHERE DataImportTypeID = @Datatype 


 IF DATEADD(hour,@increment,@endate) < @now 
	EXEC [Operations].[DataImportLog_Add_Increment] @dataimporttypeid = @Datatype, 	 @dateparttype = 1	, @dateinc = @increment; 
ELSE
	EXEC [Operations].[DataImportLog_Add] @dataimporttypeid = @Datatype;

END