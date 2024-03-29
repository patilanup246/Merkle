USE [CEM]
GO
/****** Object:  StoredProcedure [PreProcessing].[API_CustomerPreference_Import_All]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [PreProcessing].[API_CustomerPreference_Import_All]
(@userid			  INTEGER = 0
)
AS
	BEGIN

		SET NOCOUNT ON;

		DECLARE @spname                 NVARCHAR(256)
		DECLARE @logmessage             NVARCHAR(MAX)
		DECLARE @recordcount            INTEGER = 0
		DECLARE @logtimingidnew         INTEGER
		DECLARE @cp_count				INTEGER
  		DECLARE @ErrMsg                 VARCHAR(4000)
	
		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
    
		--Log start time--

		EXEC [Operations].[LogTiming_Record] @userid = @userid,
											 @logsource = @spname,
											 @logtimingidnew = @logtimingidnew OUTPUT
		
		SELECT @cp_count = COUNT(1)
		FROM [PreProcessing].[CustomerPreference_All]

		IF @cp_count > 0
		BEGIN
			BEGIN TRAN INSERT_CUSTOMER_PREFERENCE WITH MARK 'Insert Customer Preferences data from CEM_API'
  
  			BEGIN TRY

				MERGE [Staging].[STG_CustomerPreference]  AS t
				USING
					(SELECT DISTINCT *
					 FROM [PreProcessing].[CustomerPreference_All]
					) AS s
					ON t.OptionID = s.OptionID AND t.CustomerId = s.CustomerID AND t.ArchivedInd = 0
					WHEN MATCHED AND (t.LastModifiedDate < s.LastModifiedDate OR t.LastModifiedBy = 0) AND t.PreferenceValue <> s.PreferenceValue
					THEN UPDATE SET
						t.[PreferenceValue] = s.[PreferenceValue],
						t.[LastModifiedDate] = s.[LastModifiedDate],
						t.[LastModifiedBy] = s.[LastModifiedBy],
						t.[ArchivedInd] = s.[ArchivedInd]
					WHEN NOT MATCHED
					THEN
						INSERT
						([CustomerID]
						,[OptionID]
						,[PreferenceValue]
						,[CreatedDate]
						,[CreatedBy]
						,[LastModifiedDate]
						,[LastModifiedBy]
						,[ArchivedInd])
						VALUES
						(s.[CustomerID]
						,s.[OptionID]
						,s.[PreferenceValue]
						,s.[CreatedDate]
						,s.[CreatedBy]
						,s.[LastModifiedDate]
						,s.[LastModifiedBy]
						,s.[ArchivedInd]);

				COMMIT TRAN INSERT_CUSTOMER_PREFERENCE

				SELECT @recordcount = @@ROWCOUNT

				TRUNCATE TABLE [PreProcessing].[CustomerPreference_All]
  			END TRY 
			BEGIN CATCH
				ROLLBACK TRAN INSERT_CUSTOMER_PREFERENCE  
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
