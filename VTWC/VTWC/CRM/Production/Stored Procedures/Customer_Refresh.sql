
CREATE PROCEDURE [Production].[Customer_Refresh]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    EXEC [Staging].[STG_CustomerEmailSubscription_Update]  @userid         = @userid,
									  					     @recordcount    = @recordcount OUTPUT

	EXEC	[Operations].[TableBackup]
			@table_name = N'Production.Customer'
			
	TRUNCATE TABLE Production.Customer

    EXEC [Production].[Customer_Insert]

	EXEC	[Operations].[CheckTableAndRestoreOnFailure]
			@table_name = N'Production.Customer'

    EXEC [Production].[Customer_CustomerType_Update]

    EXEC [Production].[Customer_RFV_Update]
    
    EXEC [Production].[Customer_Inferred_HomeStation]
    
    EXEC [Production].[customer_rfv_history_production]

    EXEC [Production].[Customer_Aggregates] -- SPF 20-Jan-2017

	EXEC [Production].[Customer_RAG_update] -- SPF 16-Aug-2018

	SELECT @recordcount =  COUNT(1)
    FROM  [Production].[Customer]

	
	
	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END