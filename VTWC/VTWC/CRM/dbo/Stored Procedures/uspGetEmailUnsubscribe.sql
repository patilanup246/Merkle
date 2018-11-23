
/*============================================================================
Name:         dbo.uspGetEmailUnsubscribe
Purpose:	  Gets daily list of Email Unsubscribe.
Parameters:
Notes:	

Created: 2018-08-14		Dhana Mani		Creation
Modified:
Peer Review:
Call script: exec dbo.uspGetEmailUnsubscribe
==================================================================================*/ 
CREATE PROCEDURE [dbo].[uspGetEmailUnsubscribe]
	 @DebugPrint tinyint = 0,
	 @PkgExecKey			   INTEGER = -1,
	 @DebugRecordset		   INTEGER = 0

AS

BEGIN TRY
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- Standard declarations and variable setting.
	---------------------------------------------------------
	DECLARE @ThisDb sysname = DB_NAME()
		  , @Rows int
		  , @ThisProc sysname = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNOWN')
		  , @FileName varchar(127)
		  , @SPID int = @@SPID
		  , @updates varchar(max)
		  ,	@cr char(1) = CHAR(10)
	
	DECLARE @ChannelID INT, @AddressTypeID INT, @LastModifiedDate DATE 

	SELECT @ChannelID = ChannelID
	FROM Reference.Channel
	WHERE Name = 'Email' 

	SELECT @AddressTypeID = AddressTypeID
	FROM Reference.AddressType
	WHERE Name = 'Email'

	SELECT @LastModifiedDate = CAST(GETDATE() AS date)

	EXEC synUspAudit @AuditType='PROCESS START'
				, @Process=@ThisProc, @DatabaseName=@ThisDb, @Rows=NULL,@PrintToScreen=@DebugPrint
				, @Message = 'dbo.uspGetEmailUnsubscribe Start'

	--Get the list
	SELECT KM.TCSCustomerID AS CustomerID, EA.ParsedAddress AS Email
		   ,P.Name AS [Type]
	FROM Staging.STG_CustomerPreference AS CP
	INNER JOIN Staging.STG_KeyMapping AS KM
		ON CP.CustomerID = KM.CustomerID 
		AND KM.IsParentInd = 1
	INNER JOIN  Staging.STG_ElectronicAddress AS EA
		ON CP.CustomerID = EA.CustomerID
		AND EA.AddressTypeID = @AddressTypeID
	INNER JOIN Reference.Preference AS P
		ON CP.PreferenceID = P.PreferenceID 
	WHERE CP.[Value] = 0
	AND CP.ChannelID = @ChannelID
	AND CP.LastModifiedDate >= @LastModifiedDate



	EXEC synUspAudit @AuditType='TRACE'
				   , @Process=@ThisProc
				   , @ProcessStep='Finished Running the get list of email unsubscribe from customer preference'
				   , @DatabaseName=@ThisDb
				   , @FileName=@FileName
				   , @Rows=@@RowCount
				   , @PrintToScreen=@DebugPrint

	EXEC synUspAudit @AuditType='PROCESS COMPLETE'
				, @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=@@RowCount,@PrintToScreen=@DebugPrint 
				, @Message = 'dbo.uspGetEmailUnsubscribe Finish'

	END TRY
	BEGIN CATCH
		DECLARE 
			@ErrorMessage VARCHAR(4000) = ERROR_MESSAGE() ,
			@ErrorNumber INT = ERROR_NUMBER(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE(),
			@ErrorLine INT = ERROR_LINE(),
			@ErrorProcedure VARCHAR(126) = ISNULL(ERROR_PROCEDURE(), 'N/A')
			;
		-- Log
		EXEC synUspAudit @AuditType='ERROR', @Message=@ErrorMessage
					         , @Process=@ThisProc, @DatabaseName=@ThisDb, @FileName=@FileName, @Rows=NULL,@PrintToScreen=@DebugPrint
	    
		--Rethrow the error
		RAISERROR  ( @ErrorMessage, @ErrorSeverity,	1);     
	END CATCH