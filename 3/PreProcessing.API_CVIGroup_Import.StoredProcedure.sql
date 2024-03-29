USE [CEM]
GO
/****** Object:  StoredProcedure [PreProcessing].[API_CVIGroup_Import]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PreProcessing].[API_CVIGroup_Import]
(@userid			  INTEGER = 0
)
AS
	BEGIN

		SET NOCOUNT ON;

		DECLARE @spname                 NVARCHAR(256)
		DECLARE @logmessage             NVARCHAR(MAX)
		DECLARE @recordcount            INTEGER = 0
		DECLARE @logtimingidnew         INTEGER
		DECLARE @group_count			INTEGER
  		DECLARE @ErrMsg                 VARCHAR(4000)
	
		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
    
		--Log start time--
		EXEC [Operations].[LogTiming_Record] @userid = @userid,
											 @logsource = @spname,
											 @logtimingidnew = @logtimingidnew OUTPUT
        
		SELECT @group_count = COUNT(1)
		FROM [PreProcessing].[CVIGroup]

		IF @group_count > 0
		BEGIN
			BEGIN TRAN MERGE_CVI_GROUP WITH MARK 'Merge CVI Group data from CEM_API'
  
  			BEGIN TRY	
				SET IDENTITY_INSERT [Reference].[CVIGroup] ON
		
				MERGE [Reference].[CVIGroup] AS t
				USING
					(SELECT DISTINCT *
					FROM [PreProcessing].[CVIGroup] 
					) AS s
					ON t.CVIGroupID = s.CVIGroupID 
					WHEN MATCHED AND t.LastModifiedDate < s.LastModifiedDate AND t.ArchivedInd = 0
					THEN UPDATE SET
						t.[Name] = s.[Name],
						t.[Description] = s.[Description],
						t.[LastModifiedDate]= s.[LastModifiedDate],
						t.[LastModifiedBy] = s.[LastModifiedBy],
						t.[ArchivedInd] = s.[ArchivedInd],
						t.[DisplayName] = s.[DisplayName],
						t.[ExtReference] = s.[ExtReference]
					WHEN NOT MATCHED
					THEN
						INSERT 
						([CVIGroupID]
						,[Name]
						,[Description]
						,[CreatedDate]
						,[CreatedBy]
						,[LastModifiedDate]
						,[LastModifiedBy]
						,[ArchivedInd]
						,[DisplayName]
						,[ExtReference])
						VALUES
						(s.[CVIGroupID]
						,s.[Name]
						,s.[Description]
						,s.[CreatedDate]
						,s.[CreatedBy]
						,s.[LastModifiedDate]
						,s.[LastModifiedBy]
						,s.[ArchivedInd]
						,s.[DisplayName]
						,s.[ExtReference]);

				SET IDENTITY_INSERT [Reference].[CVIQuestionAnswer] OFF

				COMMIT TRAN MERGE_CVI_GROUP
		
				SELECT @recordcount = @@ROWCOUNT		
		
				TRUNCATE TABLE [PreProcessing].[CVIGroup] 
  			END TRY BEGIN CATCH
  				ROLLBACK TRAN MERGE_CVI_GROUP
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
