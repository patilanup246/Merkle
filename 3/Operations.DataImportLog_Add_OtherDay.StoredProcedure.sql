USE [CEM]
GO
/****** Object:  StoredProcedure [Operations].[DataImportLog_Add_OtherDay]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Operations].[DataImportLog_Add_OtherDay]
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


 IF DATEADD(day,@increment,@endate) < @now 
	EXEC [Operations].[DataImportLog_Add_Increment] @dataimporttypeid = @Datatype, 	 @dateparttype = 2	, @dateinc = @increment; 
ELSE
	EXEC [Operations].[DataImportLog_Add] @dataimporttypeid = @Datatype;

END

GO
