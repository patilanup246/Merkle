CREATE PROCEDURE [Staging].[STG_FareAugmentationSegmentation] 
@userID INT
AS
BEGIN

	DECLARE @spname                        NVARCHAR(256)
	DECLARE @logtimingidnew                INTEGER
	DECLARE @logmessage                    NVARCHAR(MAX)
	DECLARE @SQLString                     nvarchar(500)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
 
	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
										  @logsource       = @spname,
										  @logmessage      = 'Fare Augmentation Segmentation - START',
										  @logmessagelevel = 'DEBUG',
										  @messagetypecd   = NULL
 
	EXEC Staging.STG_FareAugmentationSegmentation_CompetitorBooker @userid= @userID
	EXEC Staging.STG_FareAugmentationSegmentation_HotCakes @userid= @userID
	EXEC Staging.STG_FareAugmentationSegmentation_Tactical @userid= @userID

 	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
										  @logsource       = @spname,
										  @logmessage      = 'Fare Augmentation Segmentation - FINISH',
										  @logmessagelevel = 'DEBUG',
										  @messagetypecd   = NULL

END