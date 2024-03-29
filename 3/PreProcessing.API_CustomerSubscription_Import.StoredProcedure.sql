USE [CEM]
GO
/****** Object:  StoredProcedure [PreProcessing].[API_CustomerSubscription_Import]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [PreProcessing].[API_CustomerSubscription_Import]
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
				--Get CustomerID and SubscriptionChannelTypeID
				SELECT cs.*,km.CustomerID,sc.SubscriptionChannelTypeID
				INTO #TmpCustomerSubscriptions
				FROM [PreProcessing].[CustomerSubscription] cs
				INNER JOIN [Staging].[STG_KeyMapping] km ON cs.CBECustomerID = km.CBECustomerID
				INNER JOIN [Reference].[SubscriptionChannelType] sc ON sc.SubscriptionTypeID = cs.SubscriptionID

				MERGE [Staging].[STG_CustomerSubscriptionPreference] AS t
				USING
					(SELECT DISTINCT *
					 FROM #TmpCustomerSubscriptions 
					) AS s
					ON t.SubscriptionChannelTypeID = s.SubscriptionChannelTypeID AND t.CustomerId = s.CustomerID AND t.ArchivedInd = 0
					WHEN MATCHED AND t.LastModifiedDate < s.LastModifiedDate AND t.[OptInInd] <> s.[SubscriptionValue] 
					THEN UPDATE SET
						t.[OptInInd] = s.[SubscriptionValue],
						t.[InformationSourceID]	= 10,
						t.[SourceChangeDate] = s.[LastModifiedDate],
						t.[LastModifiedDate] = s.[LastModifiedDate],
						t.[LastModifiedBy] = s.[LastModifiedBy],
						t.[ArchivedInd] = s.[ArchivedInd]
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
						,s.[ArchivedInd]);
	
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
