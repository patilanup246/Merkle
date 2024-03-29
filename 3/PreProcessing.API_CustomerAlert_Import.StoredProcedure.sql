USE [CEM]
GO
/****** Object:  StoredProcedure [PreProcessing].[API_CustomerAlert_Import]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PreProcessing].[API_CustomerAlert_Import]
(@userid			  INTEGER = 0
)
AS
	BEGIN

		SET NOCOUNT ON;

		DECLARE @spname                 NVARCHAR(256)
		DECLARE @logmessage             NVARCHAR(MAX)
		DECLARE @recordcount            INTEGER = 0
		DECLARE @logtimingidnew         INTEGER
		DECLARE @alert_count			INTEGER
  		DECLARE @ErrMsg                 VARCHAR(4000)
	
		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
    
		--Log start time--

		EXEC [Operations].[LogTiming_Record] @userid = @userid,
											 @logsource = @spname,
											 @logtimingidnew = @logtimingidnew OUTPUT
        
		SELECT @alert_count = COUNT(1)
		FROM [PreProcessing].[CustomerAlert]

		IF @alert_count > 0
		BEGIN
			BEGIN TRAN MERGE_CUSTOMER_ALERT WITH MARK 'Merging Alerts data from CEM_API'
  
  			BEGIN TRY	
				SET IDENTITY_INSERT [Staging].[STG_CustomerAlert] ON
		
				MERGE [Staging].[STG_CustomerAlert] AS t
				USING
					(SELECT DISTINCT *
					FROM [PreProcessing].[CustomerAlert] 
					) AS s
					ON t.CustomerAlertID = s.CustomerAlertID 
					WHEN MATCHED AND t.LastModifiedDate < s.LastModifiedDate AND t.ArchivedInd = 0
					THEN UPDATE SET
						t.[Title] = s.[Title],
						t.[Forename] = s.[Forename],
						t.[Surname] = s.[Surname],
						t.[Email] = s.[Email],
						t.[EncryptedEmail] = s.[EncryptedEmail],
						t.[LocationFrom] = s.[LocationFrom],
						t.[LocationTo] = s.[LocationTo],
						t.[AlertName] = s.[AlertName],
						t.[DurationStartDate] = s.[DurationStartDate],
						t.[DurationEndDate] = s.[DurationEndDate],
						t.[OutwardJourney] = s.[OutwardJourney],
						t.[ReturnJourney] = s.[ReturnJourney],
						t.[LastModifiedDate]= s.[LastModifiedDate],
						t.[LastModifiedBy] = s.[LastModifiedBy],
						t.[ArchivedInd] = s.[ArchivedInd]
					WHEN NOT MATCHED
					THEN
						INSERT 
						([CustomerAlertID]
						,[Title]
						,[Forename]
						,[Surname]
						,[Email]
						,[EncryptedEmail]
						,[LocationFrom]
						,[LocationTo]
						,[AlertName]
						,[DurationStartDate]
						,[DurationEndDate]
						,[OutwardJourney]
						,[ReturnJourney]
						,[CreatedDate]
						,[CreatedBy]
						,[LastModifiedDate]
						,[LastModifiedBy]
						,[ArchivedInd])
						VALUES
						(s.[CustomerAlertID]
						,s.[Title]
						,s.[Forename]
						,s.[Surname]
						,s.[Email]
						,s.[EncryptedEmail]
						,s.[LocationFrom]
						,s.[LocationTo]
						,s.[AlertName]
						,s.[DurationStartDate]
						,s.[DurationStartDate]
						,s.[OutwardJourney]
						,s.[ReturnJourney]
						,s.[CreatedDate]
						,s.[CreatedBy]
						,s.[LastModifiedDate]
						,s.[LastModifiedBy]
						,s.[ArchivedInd]);

				SET IDENTITY_INSERT [Staging].[STG_CustomerAlert] OFF

				COMMIT TRAN MERGE_CUSTOMER_ALERT

				SELECT @recordcount = @@ROWCOUNT
	
				TRUNCATE TABLE [PreProcessing].[CustomerAlert] 
  			END TRY BEGIN CATCH
  				ROLLBACK TRAN MERGE_CUSTOMER_ALERT 
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
