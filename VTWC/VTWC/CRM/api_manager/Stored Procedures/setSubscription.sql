
CREATE PROCEDURE [api_manager].[setSubscription] 
     @userid     int,          -- who has requested the action
     @subscriptionTypeID   INTEGER = NULL,
     @typeID               varchar(512) = NULL,
	 @external_name        varchar(2000) = NULL,
	 @channels             api_manager.Channel READONLY,
	 @visible              bit = 1, --default visibility set to true
	 @OptinMandatory       bit,
	 @AllowMultiple        bit
AS
BEGIN
	BEGIN TRANSACTION

		SET NOCOUNT ON;

		DECLARE @spname              NVARCHAR(256)
		DECLARE @recordcount         INTEGER
		DECLARE @logtimingidnew      INTEGER
	    DECLARE @ErrMsg				 varchar(max)
		DECLARE @archived			 BIT

		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

		--Log start time--

		EXEC [Operations].[LogTiming_Record] @userid         = @userid,
		                                     @logsource      = @spname,
											 @logtimingidnew = @logtimingidnew OUTPUT

		
		--ArchivedInd 1 = Visible 0 and vice versa
		SELECT @archived = CASE WHEN @visible = 0 THEN 1 ELSE 0 END

		-- Validates if the subscription already exists.
		IF EXISTS (SELECT 1 
		             FROM Reference.SubscriptionType s WITH (NOLOCK)
	                WHERE s.SubscriptionTypeID = COALESCE(@SubscriptionTypeID, -99)) 
			BEGIN

			-- Check if the call wants to delete a non archived subscription with an UPDATE
			if @archived = 1 AND (SELECT ArchivedInd FROM Reference.SubscriptionType WHERE SubscriptionTypeID = @SubscriptionTypeID) = 0
			BEGIN
				SET @ErrMsg = 'Visible attribute is currently set to 1. To delete a subscription, please use the delete method.';
				THROW 90508, @ErrMsg,1
				ROLLBACK TRANSACTION
			END

				UPDATE Reference.SubscriptionType
				   SET DisplayName = COALESCE(@TypeID, DisplayName),
					   DisplayDescription = COALESCE(@external_name,DisplayDescription),
					   OptInMandatoryInd = COALESCE(@OptinMandatory,OptInMandatoryInd),
					   AllowMultipleInd = COALESCE(@AllowMultiple, AllowMultipleInd),
					   LastModifiedBy = @userid,
					   LastModifiedDate = GETDATE(),
					   MessageTypeCd = COALESCE(@TypeID, DisplayName),
					   Description = COALESCE(@external_name,DisplayDescription),
					   Name = COALESCE(@TypeID, DisplayName),
					   ArchivedInd = @archived
				WHERE SubscriptionTypeID = @SubscriptionTypeID

				SELECT @recordcount = @@ROWCOUNT

				if @recordcount = 0 
				BEGIN
					SET @ErrMsg = 'Unable to update the (' + @typeID + ') subscription type.';
					THROW 90508, @ErrMsg,1
					ROLLBACK TRANSACTION
				END

				-- Deleting Associated channels since they will be recreated later
				DELETE FROM Reference.SubscriptionChannelType
				 WHERE SubscriptiontypeID = @SubscriptionTypeID

				SELECT @recordcount = @@ROWCOUNT

				if @recordcount = 0 
				BEGIN
					SET @ErrMsg = 'Unable to delete channels associated to the (' + @typeID + ') subscription type.';
					THROW 90508, @ErrMsg,1
					ROLLBACK TRANSACTION
				END

			END
		ELSE
			BEGIN TRY

				-- Channels MUST exists beforehand 
					INSERT INTO Reference.SubscriptionType
					(   DisplayName,
						Name,
						Description,
						DisplayDescription,
						OptInMandatoryInd, 
						AllowMultipleInd,
						CreatedBy,
						CreatedDate,
						LastModifiedBy,
						LastModifiedDate,
						ArchivedInd,
						MessageTypeCd)
					VALUES
					(   @TypeID,
						@TypeID,
						@external_name,
						@external_name,
						@OptinMandatory,
						@AllowMultiple,
						@userid,
						GETDATE(),
						@userid,
						GETDATE(),
						@archived,
						@TypeID)
				 
	 				SET @recordcount = @@ROWCOUNT 
					SET @SubscriptionTypeID = SCOPE_IDENTITY()

					if @recordcount = 0 
					BEGIN
						SET @ErrMsg = 'Unable to create (' + @typeID + ') subscription type.';
						THROW 90508, @ErrMsg,1
						ROLLBACK TRANSACTION
					END

			END TRY
			BEGIN CATCH
				IF ERROR_NUMBER() = 2627
				BEGIN
						SET @ErrMsg = '(' + @typeID + ') subcription type already exists.';
						THROW 90508, @ErrMsg,1
						ROLLBACK TRANSACTION
					END
			END CATCH


			
			-- Associating Subscription to a Channel
			DECLARE @numChannelsAssociated  int
			DECLARE @numChannelsRequired	int

			SELECT @numChannelsRequired = COUNT(1) FROM @channels
			
			IF (SELECT COUNT(1) FROM @channels GROUP BY LOWER(short_name) HAVING COUNT(1) > 1) != 0
			BEGIN
				SET @ErrMsg = 'Duplicate channels provided';
				THROW 90508, @ErrMsg,1
				ROLLBACK TRANSACTION
			END

			INSERT INTO Reference.SubscriptionChannelType
				SELECT @typeID + ' - ' +ct.Name AS Name,
						@external_name + ' by ' + ct.Name AS Description,
						GETDATE() AS CreatedDate,
						@userid AS CreatedBy,
						GETDATE() AS LastModifiedDate,
						@userid AS LastModifiedBy,
						0 AS ArchivedInd,
						@SubscriptionTypeID as SubscriptionTypeID,
						ct.ChannelTypeID
				FROM Reference.ChannelType ct WITH (NOLOCK)
					 INNER JOIN @channels c ON LOWER(c.short_name) = LOWER(ct.Name)
				 
			SET @numChannelsAssociated = @@ROWCOUNT
					 
			IF @numChannelsAssociated != @numChannelsRequired
				BEGIN
					SET @ErrMsg = 'Unable to associate all provided channels to the (' + @typeID + ') subscription type.';
					THROW 90508, @ErrMsg,1
					ROLLBACK TRANSACTION
				END
	  	--Log end time

		EXEC [Operations].[LogTiming_Record] @userid         = @userid,
		                                     @logsource      = @spname,
											 @logtimingid    = @logtimingidnew,
											 @recordcount    = @recordcount,
											 @logtimingidnew = @logtimingidnew OUTPUT

        COMMIT TRANSACTION


	RETURN @recordcount

END