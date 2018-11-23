
CREATE PROCEDURE [api_manager].[deleteSubscription] 
     @userid     int,          -- who has requested the action
     @subscriptionTypeID   INTEGER = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER
    DECLARE @ErrMsg varchar(max)
	DECLARE @numSubsUpdated      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	
	IF NOT EXISTS (SELECT 1 FROM Reference.SubscriptionType
					WHERE SubscriptionTypeID = @subscriptionTypeID)
		BEGIN
			SET @ErrMsg = 'Subscription Type with ID: (' + CAST(@subscriptionTypeID AS VARCHAR(56)) + ') does not exist';
			THROW 90508, @ErrMsg,1
		END
	ELSE IF NOT EXISTS (SELECT 1 FROM Reference.SubscriptionType
						WHERE SubscriptionTypeID = @subscriptionTypeID
						AND ArchivedInd = 0)
		BEGIN
			SET @ErrMsg = 'Nothing to delete';
			THROW 90508, @ErrMsg,1
		END
	ELSE
		BEGIN
			UPDATE Reference.SubscriptionType
			   SET ArchivedInd = 1,
				   LastModifiedDate = GETDATE(),
				   LastModifiedBy = @userid
			 WHERE SubscriptionTypeID = @subscriptionTypeID

			 SELECT @numSubsUpdated = @@ROWCOUNT
			 IF @numSubsUpdated = 0 
			 BEGIN
				SET @ErrMsg = 'Unable to delete subscription type with ID: (' + CAST(@subscriptionTypeID AS VARCHAR(56)) + ')';
				THROW 90508, @ErrMsg,1
			 END
		END	 

  	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

	RETURN @numSubsUpdated
END