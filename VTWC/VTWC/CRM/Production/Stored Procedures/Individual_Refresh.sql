CREATE PROCEDURE [Production].[Individual_Refresh]
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

    EXEC [Staging].[STG_IndividualEmailSubscription_Update]  @userid         = @userid,
									  					     @recordcount    = @recordcount OUTPUT

	EXEC	[Operations].[TableBackup]
			@table_name = N'Production.Individual'
			
	TRUNCATE TABLE Production.Individual

    EXEC [Production].[Individual_Insert]

    EXEC Production.Individual_CustomerType_Update

    EXEC Production.Individual_RFV_Update

    SELECT @recordcount =  COUNT(1)
    FROM  [Production].[Individual]
	
	EXEC	[Operations].[CheckTableAndRestoreOnFailure]
			@table_name = N'Production.Individual'

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END