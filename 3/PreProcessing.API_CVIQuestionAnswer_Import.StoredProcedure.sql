USE [CEM]
GO
/****** Object:  StoredProcedure [PreProcessing].[API_CVIQuestionAnswer_Import]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PreProcessing].[API_CVIQuestionAnswer_Import]
(@userid			  INTEGER = 0
)
AS
	BEGIN

		SET NOCOUNT ON;

		DECLARE @spname                 NVARCHAR(256)	
		DECLARE @logmessage             NVARCHAR(MAX)
		DECLARE @recordcount            INTEGER = 0
		DECLARE @logtimingidnew         INTEGER
		DECLARE @qa_count				INTEGER
  		DECLARE @ErrMsg                 VARCHAR(4000)

		SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
    
		--Log start time--
		EXEC [Operations].[LogTiming_Record] @userid = @userid,
											 @logsource = @spname,
											 @logtimingidnew = @logtimingidnew OUTPUT
        
		SELECT @qa_count = COUNT(1)
		FROM [PreProcessing].[CVIQuestionAnswer]

		IF @qa_count > 0
		BEGIN
			BEGIN TRAN MERGE_CVI_QUESTION_ANSWER WITH MARK 'Merge CVI Question Answer data from CEM_API'
  
  			BEGIN TRY	
				SET IDENTITY_INSERT [Reference].[CVIQuestionAnswer] ON
		
				MERGE [Reference].[CVIQuestionAnswer] AS t
				USING
					(SELECT DISTINCT *
					FROM [PreProcessing].[CVIQuestionAnswer] 
					) AS s
					ON t.CVIQuestionAnswerID = s.CVIQuestionAnswerID 
					WHEN MATCHED AND t.LastModifiedDate < s.LastModifiedDate AND t.ArchivedInd = 0
					THEN UPDATE SET
						t.[Name] = s.[Name],
						t.[Description] = s.[Description],
						t.[LastModifiedDate]= s.[LastModifiedDate],
						t.[LastModifiedBy] = s.[LastModifiedBy],
						t.[ArchivedInd] = s.[ArchivedInd],
						t.[CVIQuestionID] = s.[CVIQuestionID],
						t.[CVIAnswerID] = s.[CVIAnswerID]
					WHEN NOT MATCHED
					THEN
						INSERT 
						([CVIQuestionAnswerID]
						,[Name]
						,[Description]
						,[CreatedDate]
						,[CreatedBy]
						,[LastModifiedDate]
						,[LastModifiedBy]
						,[ArchivedInd]
						,[CVIQuestionID]
						,[CVIAnswerID])
						VALUES
						(s.[CVIQuestionAnswerID]
						,s.[Name]
						,s.[Description]
						,s.[CreatedDate]
						,s.[CreatedBy]
						,s.[LastModifiedDate]
						,s.[LastModifiedBy]
						,s.[ArchivedInd]
						,s.[CVIQuestionID]
						,s.[CVIAnswerID]);

				SET IDENTITY_INSERT [Reference].[CVIQuestionAnswer] OFF

				COMMIT TRAN MERGE_CVI_QUESTION_ANSWER
			
				SELECT @recordcount = @@ROWCOUNT

				TRUNCATE TABLE [PreProcessing].[CVIQuestionAnswer]
  			END TRY BEGIN CATCH
  				ROLLBACK TRAN MERGE_CVI_QUESTION_ANSWER
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
