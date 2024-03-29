USE [CEM]
GO
/****** Object:  StoredProcedure [PreProcessing].[API_CustomerSubscription_Import_Test]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PreProcessing].[API_CustomerSubscription_Import_Test]
(@userid			  INTEGER = 0
)
AS
	BEGIN

		SET NOCOUNT ON;

		DECLARE @spname                 NVARCHAR(256)
		DECLARE @logmessage             NVARCHAR(MAX)
		DECLARE @recordcount            INTEGER = 0
		DECLARE @logtimingidnew         INTEGER
		DECLARE @cs_count				INTEGER
  		DECLARE @ErrMsg                 VARCHAR(4000)
	
		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
    
		--Log start time--

		EXEC [Operations].[LogTiming_Record] @userid = @userid,
											 @logsource = @spname,
											 @logtimingidnew = @logtimingidnew OUTPUT		

		SELECT @cs_count = COUNT(1)
		FROM [PreProcessing].[CustomerSubscription]

		IF @cs_count > 0
		BEGIN
			BEGIN TRAN INSERT_CUSTOMER_SUBSCRIPTION WITH MARK 'Insert Customer Subscriptions data from CEM_API'
  
  			BEGIN TRY		
				DECLARE @SubsUpdates TABLE (
					[CustomerID] [int],
					[SubscriptionChannelTypeID] [int],
					[OptInInd] [int],
					[CreatedDate] [datetime],
					[CreatedBy] [int],
					[LastModifiedDate] [datetime],
					[LastModifiedBy] [int],
					[ArchivedInd] [int]
				)

				--Get CustomerID and SubscriptionChannelTypeID
				SELECT cs.*,km.CustomerID,sc.SubscriptionChannelTypeID
				INTO #TmpCustomerSubscriptions
				FROM [PreProcessing].[CustomerSubscription] cs
				INNER JOIN [Staging].[STG_KeyMapping] km ON cs.CBECustomerID = km.CBECustomerID
				INNER JOIN [Reference].[SubscriptionChannelType] sc ON sc.SubscriptionTypeID = cs.SubscriptionID
				
				INSERT @SubsUpdates
				SELECT CustomerID,SubscriptionChannelTypeID,OptInInd,CreatedDate,CreatedBy,LastModifiedDate,LastModifiedBy,ArchivedInd
				FROM (				
					MERGE 
						[Staging].[STG_CustomerSubscriptionPreference] AS t
					USING
						(SELECT DISTINCT *
							FROM #TmpCustomerSubscriptions 
						) AS s
						ON t.SubscriptionChannelTypeID = s.SubscriptionChannelTypeID AND t.CustomerId = s.CustomerID
						WHEN MATCHED AND t.LastModifiedDate < s.LastModifiedDate 
						THEN UPDATE SET
							--t.[OptInInd] = t.[OptInInd],
							--t.[InformationSourceID]	= 10,
							--t.[SourceChangeDate] = s.[LastModifiedDate],
							--t.[LastModifiedDate] = s.[LastModifiedDate],
							t.[LastModifiedDate] = CASE WHEN t.ArchivedInd = 0 THEN GETDATE() ELSE t.[LastModifiedDate] END,
							t.[LastModifiedBy] = CASE WHEN t.ArchivedInd = 0 THEN s.[LastModifiedBy] ELSE t.[LastModifiedBy] END,
							t.[ArchivedInd] = 1
							--t.[ArchivedInd] = s.[ArchivedInd]						
						WHEN NOT MATCHED 
						THEN
							INSERT
							([CustomerID]
							,[Name]
							,[Description]
							,[SubscriptionChannelTypeID]
							,[OptInInd]
							,[StartTime]
							,[EndTime]
							,[DaysofWeek]
							,[InformationSourceID]	
							,[SourceChangeDate]						
							,[CreatedDate]
							,[CreatedBy]
							,[LastModifiedDate]
							,[LastModifiedBy]
							,[ArchivedInd])
							VALUES
							(s.[CustomerID]
							,NULL
							,NULL
							,s.[SubscriptionChannelTypeID]
							,s.[SubscriptionValue]
							,NULL
							,NULL
							,NULL
							,10
							,s.[LastModifiedDate]				
							,s.[CreatedDate]
							,s.[CreatedBy]
							,s.[LastModifiedDate]
							,s.[LastModifiedBy]
							,s.[ArchivedInd])
						OUTPUT $action, s.CustomerID,s.SubscriptionChannelTypeID,s.SubscriptionValue,s.CreatedDate,s.CreatedBy,s.LastModifiedDate,s.LastModifiedBy,s.ArchivedInd
				) AllChanges(ActionType,CustomerID,SubscriptionChannelTypeID,OptInInd,CreatedDate,CreatedBy,LastModifiedDate,LastModifiedBy,ArchivedInd)
				WHERE AllChanges.ActionType = 'UPDATE'
				
				INSERT INTO [Staging].[STG_CustomerSubscriptionPreference]
				([CustomerID]
				,[SubscriptionChannelTypeID]
				,[OptInInd]
				,[InformationSourceID]	
				,[SourceChangeDate]		
				,[CreatedDate]
				,[CreatedBy]
				,[LastModifiedDate]
				,[LastModifiedBy]
				,[ArchivedInd])
				SELECT DISTINCT CustomerID,SubscriptionChannelTypeID,OptInInd,10,GETDATE(),GETDATE(),CreatedBy,GETDATE(),LastModifiedBy,ArchivedInd 
				FROM @SubsUpdates
				WHERE ArchivedInd = 0

				COMMIT TRAN INSERT_CUSTOMER_SUBSCRIPTION
			
				SELECT @recordcount = @@ROWCOUNT
	
				TRUNCATE TABLE [PreProcessing].[CustomerSubscription]
  			END TRY 
			BEGIN CATCH
  				ROLLBACK TRAN INSERT_CUSTOMER_SUBSCRIPTION 
				SET @ErrMsg = ERROR_MESSAGE()
  				BEGIN
  					THROW 95801, @ErrMsg, 1
  				END 		
  			END CATCH
		END

		--Log end time
		EXEC [Operations].[LogTiming_Record] @userid         = @userid,
			                                 @logsource      = @spname,
											 @logtimingid    = @logtimingidnew,
											 @recordcount    = @recordcount,
											 @logtimingidnew = @logtimingidnew OUTPUT
    END
GO
