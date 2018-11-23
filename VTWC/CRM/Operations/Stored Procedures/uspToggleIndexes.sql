
/*============================================================================
Description	Disable or rebuild all NC, non-primary indexes on specific table or all tables in a schema

Parameters	@Schema SYSNAME
				The name of the schema containing the tables to toggle indexes on
			@Table SYSNAME = NULL		
				The table within the @Schema to rebuild/disable indexes on
				If NULL, indexes will be rebuilt on all tables within the schema
			@Rebuild BIT
				If 1, indexes will be rebuilt
				If 0, indexes will be disabled
			@RebuildThreshold 
				Lower threshold at which an index qualifies for rebuild
			@ReorganiseThreshold
				Lower threshold at which an index qualifies for reorganise
			@PageCountThreshold
				Lower threshold at which an index will be considered for rebuild 
			
Date			Author				Reason
-------------------------------------------
2018-10-06		Iwan Jones			Deployment to VTWC solution
==================================================================================*/
CREATE PROCEDURE [Operations].[uspToggleIndexes]
    (
     @Schema sysname
    ,@Table sysname = NULL
    ,@Rebuild BIT
    ,@RebuildThreshold TINYINT = 30
    ,@ReorganiseThreshold TINYINT = 10
    ,@PageCountThreshold SMALLINT = 1000
    )
AS
    SET NOCOUNT ON; 

    DECLARE @spname NVARCHAR(256);
    SELECT  @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.'
            + OBJECT_NAME(@@PROCID);

    DECLARE @ProcessStepText VARCHAR(255);
    SELECT  @ProcessStepText = 'uspToggleIndexes on ' + @Schema + '.' + @Table
            + ' ' + CASE WHEN @Rebuild = 0 THEN 'DISABLE'
                         WHEN @Rebuild = 1 THEN 'REBUILD'
                         ELSE 'UNKNOWN'
                    END; 

    EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = @ProcessStepText, @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

    DECLARE @SQL NVARCHAR(MAX) = N''
       ,@DeadlockRetryAttempts TINYINT = 5;

    WHILE @DeadlockRetryAttempts > 0
        BEGIN
            BEGIN TRY

                IF OBJECT_ID(N'tempdb..#Indexes') IS NOT NULL
                    DROP TABLE [#Indexes];

		--	Get candidates for rebuild/reorg/disable
                SELECT  @Schema AS [Schema]
                       ,[indexes].[Table] AS [Table]
                       ,[indexes].[name] AS [IndexName]
                       ,CASE WHEN [dm_db_index_physical_stats].[avg_fragmentation_in_percent] >= @RebuildThreshold
                             THEN N'REBUILD'
                             WHEN [dm_db_index_physical_stats].[avg_fragmentation_in_percent] >= @ReorganiseThreshold
                             THEN N'REORGANIZE'
                        END AS [Toggle]
                       ,CASE WHEN [PartitionedIndex].[object_id] IS NOT NULL
                             THEN CAST([dm_db_index_physical_stats].[partition_number] AS NVARCHAR(5))
                             ELSE N'ALL'
                        END AS [Partition]
                INTO    [#Indexes]
                FROM    (
                         SELECT [indexes].[object_id]
                               ,[indexes].[index_id]
                               ,[indexes].[name]
                               ,[objects].[name] AS [Table]
                         FROM   [sys].[indexes]
                         INNER JOIN [sys].[objects]
                         ON     [indexes].[object_id] = [objects].[object_id]
                                AND [objects].[name] = COALESCE(@Table,
                                                              [objects].[name])
                                AND [indexes].[type_desc] = N'NONCLUSTERED'
                                AND [indexes].[is_primary_key] = 0
                                AND [indexes].[is_disabled] = 0
                         INNER JOIN [sys].[schemas]
                         ON     [objects].[schema_id] = [schemas].[schema_id]
                                AND [schemas].[name] = @Schema
                        ) AS [indexes]
                CROSS APPLY [sys].[dm_db_index_physical_stats](DB_ID(),
                                                              [indexes].[object_id],
                                                              [indexes].[index_id],
                                                              NULL, N'LIMITED')
                LEFT JOIN (
                           SELECT   [object_id]
                                   ,[index_id]
                           FROM     [sys].[partitions]
                           GROUP BY [object_id]
                                   ,[index_id]
                           HAVING   MAX([partition_number]) > 1
                          ) AS [PartitionedIndex]
                ON      [indexes].[object_id] = [PartitionedIndex].[object_id]
                        AND [indexes].[index_id] = [PartitionedIndex].[index_id]
                WHERE   @Rebuild = 1
                        AND [dm_db_index_physical_stats].[avg_fragmentation_in_percent] >= @ReorganiseThreshold
                        AND [dm_db_index_physical_stats].[page_count] >= @PageCountThreshold
                UNION ALL
                SELECT  @Schema AS [Schema]
                       ,[objects].[name] AS [Table]
                       ,[indexes].[name] AS [IndexName]
                       ,N'REBUILD' AS [Toggle]
                       ,N'ALL' AS [Partition]
                FROM    [sys].[indexes]
                INNER JOIN [sys].[objects]
                ON      [indexes].[object_id] = [objects].[object_id]
                        AND [objects].[name] = COALESCE(@Table,
                                                        [objects].[name])
                        AND [indexes].[type_desc] = N'NONCLUSTERED'
                        AND [indexes].[is_primary_key] = 0
                        AND [indexes].[is_disabled] = 1
                        AND @Rebuild = 1
                INNER JOIN [sys].[schemas]
                ON      [objects].[schema_id] = [schemas].[schema_id]
                        AND [schemas].[name] = @Schema
                UNION ALL
                SELECT  @Schema AS [Schema]
                       ,[objects].[name] AS [Table]
                       ,[indexes].[name] AS [IndexName]
                       ,N'DISABLE' AS [Toggle]
                       ,NULL AS [Partition]
                FROM    [sys].[indexes]
                INNER JOIN [sys].[objects]
                ON      [indexes].[object_id] = [objects].[object_id]
                        AND [objects].[name] = COALESCE(@Table,
                                                        [objects].[name])
                        AND [indexes].[type_desc] = N'NONCLUSTERED'
                        AND [indexes].[is_primary_key] = 0
                        AND [indexes].[is_disabled] = 0
                        AND @Rebuild = 0
                INNER JOIN [sys].[schemas]
                ON      [objects].[schema_id] = [schemas].[schema_id]
                        AND [schemas].[name] = @Schema;
		
		--	Prevent further looping
                SET @DeadlockRetryAttempts = 0;
            END TRY
            BEGIN CATCH
		
                IF ERROR_NUMBER() = 1205
                    AND @DeadlockRetryAttempts > 0			
			--	Retry on deadlock
                    SET @DeadlockRetryAttempts -= 1;		
                ELSE
                    THROW;		
            END CATCH;
        END;

    SET @SQL = N'DECLARE @Message NVARCHAR(512); ';
    SELECT  @SQL += N'
	BEGIN TRY		
		ALTER INDEX ' + [#Indexes].[IndexName] + N' ON ' + [#Indexes].[Schema]
            + N'.' + [#Indexes].[Table] + N' ' + [#Indexes].[Toggle] + N''
            + COALESCE(N' PARTITION = ' + [#Indexes].[Partition], N'')
            + N'; 		
	END TRY
	BEGIN CATCH
		SET @Message = LEFT(ERROR_MESSAGE(), 512);		
		--	Fail silently
		PRINT @Message;
	END CATCH ' + NCHAR(13)
    FROM    [#Indexes];

    EXEC [sys].[sp_executesql] @SQL;

    EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = @ProcessStepText, @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0;