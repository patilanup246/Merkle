
/*===========================================================================================
Name:			Staging.STG_CustomerPreference_Update
Purpose:		Insert/Update customer preferences against channels into table Staging.STG_CustomerPreference
				Add Inserted/Updated/Deleted preferences into table Audit.STG_CustomerPreference
Parameters:		@userid - The key for the user executing the proc.
				@customerid - The CRM key for the customer.
				@preferenceid - The key for identifying preferences.
				@channelid - The key for identifying channel.
				@value - optin/optout value
				@sourcecreateddate - date when source record was created
				@sourcemodifieddate - date when source record was modified
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-01	Dhana Mani
Modified:		2018-08-21  Dhana Mani
                Changed Update Match predicate to include condition source modified date is greater than target modified date		
Peer Review:	
Call script:	EXEC Staging.STG_CustomerPreference_Update
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_CustomerPreference_Update]
(
	@userid                       INTEGER       = 0,   
	@customerid                   INTEGER,
	@preferenceid                 INTEGER,
	@channelid                    INTEGER,
	@value						  BIT,
	@sourcecreateddate			  DATETIME,
	@sourcemodifieddate           DATETIME,	 
	@DebugPrint					  INTEGER	   = 0,
    @PkgExecKey					  INTEGER	   =-1,
	@DebugRecordset				  INTEGER	   = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @spid	INTEGER	= @@SPID
	 DECLARE @spname  SYSNAME = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
	 DECLARE @dbname  SYSNAME = DB_NAME()
	 DECLARE @Rows	INTEGER = 0
	 DECLARE @ProcName NVARCHAR(50)
	 DECLARE @StepName NVARCHAR(50)

	 DECLARE  @ErrorMsg		NVARCHAR(MAX)
	 DECLARE  @ErrorNum		INTEGER
	 DECLARE  @ErrorSeverity	 NVARCHAR(255)
	 DECLARE  @ErrorState NVARCHAR(255)

	 --EXEC dbo.uspAuditAddAudit
		-- @AuditType='PROCESS START'
		--,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SET @ProcName = 'Staging.STG_CustomerPreference_Update'
	SET @StepName = 'Insert customer preference'

	BEGIN TRY
		BEGIN TRAN

		--EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Perform Insert to STG_CustomerPreference'
  --                      ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		INSERT INTO [Audit].[STG_CustomerPreference]
		(customerid, preferenceid, channelid, actiontimestamp, [value], [action], createddate, createdby
		,lastmodifieddate, lastmodifiedby)
		SELECT customerid, preferenceid, channelid, actiontimestamp, [value], [action], createddate, createdby
			  ,lastmodifieddate, lastmodifiedby
		FROM (
		MERGE [Staging].[STG_CustomerPreference] AS TRGT
		USING (SELECT @customerid as customerid, @preferenceid as preferenceid, @channelid as channelid
					  ,@value as [value], @sourcecreateddate as createddate, @userid as createdby
					  ,@sourcemodifieddate as lastmodifieddate, @userid as lastmodifiedby) AS SRC
		ON TRGT.customerid	  = SRC.customerid
		AND TRGT.preferenceid = SRC.preferenceid
		AND TRGT.channelid    = SRC.channelid
		WHEN NOT MATCHED THEN
			INSERT (customerid, preferenceid, channelid, [value], createddate, createdby
				   ,lastmodifieddate, lastmodifiedby)
			VALUES (customerid, preferenceid, channelid, [value], createddate, createdby
				   ,lastmodifieddate, lastmodifiedby)
		WHEN MATCHED 
			AND SRC.lastmodifieddate > TRGT.lastmodifieddate
			AND TRGT.[Value] <> SRC.[Value]
			THEN 
				UPDATE 
				SET TRGT.[Value] = SRC.[Value]
					,TRGT.[LastModifiedDate] = SRC.[LastModifiedDate]
		OUTPUT   CASE WHEN $ACTION = 'INSERT' THEN inserted.customerid ELSE deleted.customerid END as customerid
				,CASE WHEN $ACTION = 'INSERT' THEN inserted.preferenceid ELSE deleted.preferenceid END as preferenceid
				,CASE WHEN $ACTION = 'INSERT' THEN inserted.channelid ELSE deleted.channelid END as channelid
				,GETDATE() as actiontimestamp
				,CASE WHEN $ACTION = 'INSERT' THEN inserted.value ELSE deleted.value END as [value]
				,CASE WHEN $ACTION = 'INSERT' THEN 'I' ELSE 'D' END as [action]
				,CASE WHEN $ACTION = 'INSERT' THEN inserted.createddate ELSE deleted.createddate END as createddate
				,CASE WHEN $ACTION = 'INSERT' THEN inserted.createdby ELSE deleted.createdby END as createdby
				,CASE WHEN $ACTION = 'INSERT' THEN inserted.lastmodifieddate ELSE deleted.lastmodifieddate END as lastmodifieddate
				,CASE WHEN $ACTION = 'INSERT' THEN inserted.lastmodifiedby ELSE deleted.lastmodifiedby END as lastmodifiedby
		) MERGE_OUT;

		SET @rows = @@rowcount

		--EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Prepare customer  Keys'
  --                  ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 90508, @ErrorMsg, 2;
	END CATCH
END