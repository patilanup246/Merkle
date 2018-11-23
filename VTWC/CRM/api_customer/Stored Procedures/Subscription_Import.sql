CREATE PROCEDURE [api_customer].[Subscription_Import]
(@userid			  INTEGER = 0
)
AS
	BEGIN

		SET NOCOUNT ON;

		DECLARE @spname                 NVARCHAR(256)
		DECLARE @logmessage             NVARCHAR(MAX)
		DECLARE @recordcount            INTEGER = 0
		DECLARE @logtimingidnew         INTEGER
	
		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
    
		--Log start time--

		EXEC [Operations].[LogTiming_Record] @userid = @userid,
											 @logsource = @spname,
											 @logtimingidnew = @logtimingidnew OUTPUT
		
		SET IDENTITY_INSERT [Reference].[SubscriptionType] ON

		MERGE [Reference].[SubscriptionType] AS t
        USING
			(SELECT *
			FROM [PreProcessing].[SubscriptionType] 
			) AS s
	        ON t.SubscriptionTypeID = s.SubscriptionTypeID
			WHEN MATCHED AND t.LastModifiedBy < s.LastModifiedBy
			THEN UPDATE SET
				t.[Name] = s.[Name],
				t.[Description] = s.[Description],
				t.[AllowMultipleInd] = s.[AllowMultipleInd],
				t.[CaptureTimeInd] = s.[CaptureTimeInd],
				t.[OptInDefault] = s.[OptInDefault],
				t.[DisplayName] = s.[DisplayName],
				t.[DisplayDescription] = s.[DisplayDescription],
				t.[MessageTypeCd] = s.[MessageTypeCd],
				t.[OptInMandatoryInd] = s.[OptInMandatoryInd],
				t.[LastModifiedDate]= s.[LastModifiedDate],
				t.[LastModifiedBy] = s.[LastModifiedBy],
				t.[ArchivedInd] = s.[ArchivedInd]
			WHEN NOT MATCHED
			THEN
				INSERT 
				([SubscriptionTypeID]
				,[Name]
				,[Description]
				,[AllowMultipleInd]
				,[CaptureTimeInd]
				,[OptInDefault]
				,[DisplayName]
				,[DisplayDescription]
				,[MessageTypeCd]
				,[OptInMandatoryInd]
				,[CreatedDate]
				,[CreatedBy]
				,[LastModifiedDate]
				,[LastModifiedBy]
				,[ArchivedInd])
				VALUES
				(s.[SubscriptionTypeID]
				,s.[Name]
				,s.[Description]
				,s.[AllowMultipleInd]
				,s.[CaptureTimeInd]
				,s.[OptInDefault]
				,s.[DisplayName]
				,s.[DisplayDescription]
				,s.[MessageTypeCd]
				,s.[OptInMandatoryInd]				
				,s.[CreatedDate]
				,s.[CreatedBy]
				,s.[LastModifiedDate]
				,s.[LastModifiedBy]
				,s.[ArchivedInd]);

		SET IDENTITY_INSERT [Reference].[SubscriptionType] OFF

		SELECT @recordcount = @@ROWCOUNT

		TRUNCATE TABLE [PreProcessing].[SubscriptionType] 
	
		--Log end time
		EXEC [Operations].[LogTiming_Record] @userid         = @userid,
			                                 @logsource      = @spname,
											 @logtimingid    = @logtimingidnew,
											 @recordcount    = @recordcount,
											 @logtimingidnew = @logtimingidnew OUTPUT
    END