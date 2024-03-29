USE [CEM]
GO
/****** Object:  StoredProcedure [PreProcessing].[API_CVIQuestion_Import]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PreProcessing].[API_CVIQuestion_Import]
(@userid			  INTEGER = 0
)
AS
	BEGIN

		SET NOCOUNT ON;

		DECLARE @spname                 NVARCHAR(256)
		DECLARE @logmessage             NVARCHAR(MAX)
		DECLARE @recordcount            INTEGER = 0
		DECLARE @logtimingidnew         INTEGER
		DECLARE @question_count			INTEGER
		DECLARE @ErrMsg                 VARCHAR(4000)
	
		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
    
	
		--Log start time--
		EXEC [Operations].[LogTiming_Record] @userid = @userid,
											 @logsource = @spname,
											 @logtimingidnew = @logtimingidnew OUTPUT
        
		SELECT @question_count = COUNT(1)
		FROM [PreProcessing].[CVIQuestion]

		IF @question_count > 0
		BEGIN
			BEGIN TRAN MERGE_CVI_QUESTION WITH MARK 'Merge CVI Question data from CEM_API'
  
  			BEGIN TRY	
				SET IDENTITY_INSERT [Reference].[CVIQuestion] ON

				MERGE [Reference].[CVIQuestion] AS t
				USING
					(SELECT DISTINCT *
					FROM [PreProcessing].[CVIQuestion] 
					) AS s
					ON t.CVIQuestionID = s.CVIQuestionID 
					WHEN MATCHED AND t.LastModifiedDate < s.LastModifiedDate AND t.ArchivedInd = 0
					THEN UPDATE SET
						t.[Name] = s.[Name],
						t.[Description] = s.[Description],
						t.[LastModifiedDate]= s.[LastModifiedDate],
						t.[LastModifiedBy] = s.[LastModifiedBy],
						t.[ArchivedInd] = s.[ArchivedInd],
						t.[DisplayName] = s.[DisplayName],
						t.[ExtReference] = s.[ExtReference],
						t.[InformationSourceID] = s.[InformationSourceID],
						t.[LookupReference] = s.[LookupReference],
						t.[CVITypeID] = s.[CVITypeID],
						t.[ResponseTypeID] = s.[ResponseTypeID]
					WHEN NOT MATCHED
					THEN
						INSERT 
						([CVIQuestionID]
						,[Name]
						,[Description]
						,[CreatedDate]
						,[CreatedBy]
						,[LastModifiedDate]
						,[LastModifiedBy]
						,[ArchivedInd]
						,[DisplayName]
						,[ExtReference]
						,[InformationSourceID]
						,[LookupReference]
						,[CVITypeID]
						,[ResponseTypeID])
						VALUES
						(s.[CVIQuestionID]
						,s.[Name]
						,s.[Description]
						,s.[CreatedDate]
						,s.[CreatedBy]
						,s.[LastModifiedDate]
						,s.[LastModifiedBy]
						,s.[ArchivedInd]
						,s.[DisplayName]
						,s.[ExtReference]
						,s.[InformationSourceID]
						,s.[LookupReference]
						,s.[CVITypeID]
						,s.[ResponseTypeID]);		
			
				SET IDENTITY_INSERT [Reference].[CVIQuestion] OFF

				COMMIT TRAN MERGE_CVI_QUESTION
			
				SELECT @recordcount = @@ROWCOUNT
		
				TRUNCATE TABLE [PreProcessing].[CVIQuestion] 
  			END TRY BEGIN CATCH
  				ROLLBACK TRAN MERGE_CVI_QUESTION
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
