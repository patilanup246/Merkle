/*===========================================================================================
Name:			uspUtilityDisableEnableForeignKeys
Purpose:		Sets all Foreign Keys referencing table to NOCHECK or CHECK.
Parameters:		@ReferencedTableName - The name of the table that is referenced in a FK. Usually the dimension.
                                       @ReferencedTableName can be a pattern if required 
                                       (e.g. "Dim%" to disable all FKs to dimension tables... if you really wanted to to)
				@Action - What action to take: NOCHECK (disable), CHECK (re-enable), DROP
				@DebugPrint - Displays debug information to the message pane.
				@DebugExecute - When =1 code will not be executed, just printed to screen.
				@DebugRecordSet - When implmented, used to control displaying debug recordset information
				                  to screen, or storing debug recordsets to global temp tables.
				
Notes:			If this proc called in code to re-enable FKs after a deletion, consider adding another call to this
                in the CATCH BLOCK to make sure FKs are always re-established.
			
Created:		2011-10-26	Philip Robinson
Modified:		2011-11-04  Philip Robinson Amending so CHECK which will re-apply the check constraint with the WITH CHECK operator.
                2013-05-16  Rich Hemmings   Added ON DELETE and ON UPDATE options
                2013-06-05  Rich Hemmings   Post-Peer review with Phil of the change above and unit tested. Added in mechanism to keep existing 
                                            configuration if NOCHANGE (default action) is specified

Peer Review:	2013-06-05  Philip Robinson
Call script:	EXEC uspUtilityDisableEnableForeignKeys @ReferencedTableName='DimBrand'
                                                        , @Action='CHECK'
                                                        , @OnUpdateAction='NO ACTION'
                                                        , @OnDeleteAction='CASCADE'
                                                        , @DebugPrint=1
                                                        , @DebugExecute=1
=================================================================================================*/
CREATE PROCEDURE [dbo].[uspUtilityDisableEnableForeignKeys]
				@ReferencedTableName sysname,
				@Action VARCHAR(20),        -- NOCHECK, CHECK, DELETE
				@OnDeleteAction VARCHAR(20) = 'NOCHANGE', -- NOCHANGE, NO ACTION, CASCADE, SET NULL, SET DEFAULT
				@OnUpdateAction VARCHAR(20) = 'NOCHANGE', -- NOCHANGE, NO ACTION, CASCADE, SET NULL, SET DEFAULT
				@DebugPrint tinyint = 0,
				@DebugExecute tinyint = 0,
				@DebugRecordSet tinyint = 0
				
--WITH EXECUTE AS OWNER
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY

    IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Starting FK processing for '+@ReferencedTableName

    -- Validation & Setup & Defaults
    ---------------------------------------------------------
    IF ISNULL(@Action,'') NOT IN ('CHECK','NOCHECK','DROP')
    BEGIN
        RAISERROR('@Action "%s" is not a valid option for this procedure. Use CHECK, NOCHECK or DROP', 16, 1, @Action)
    END
    
    IF ISNULL(@OnDeleteAction,'') NOT IN ('NOCHANGE','NO ACTION','CASCADE','SET NULL','SET DEFAULT')
    BEGIN
        RAISERROR('@OnDelete "%s" is not a valid option for this procedure. Use CHECK, NOCHANGE, NO ACTION, CASCADE, SET NULL or SET DEFAULT', 16, 1, @OnDeleteAction)
    END 

    IF ISNULL(@OnUpdateAction,'') NOT IN ('NOCHANGE','NO ACTION','CASCADE','SET NULL','SET DEFAULT')
    BEGIN
        RAISERROR('@OnUpdate "%s" is not a valid option for this procedure. Use CHECK, NOCHANGE, NO ACTION, CASCADE, SET NULL or SET DEFAULT', 16, 1, @OnUpdateAction)
    END     
    
    SET @DebugExecute = ISNULL(@DebugExecute,0)

    -- Process FK action for relevant table
    ---------------------------------------------------------
    DECLARE @sql varchar(8000)
            ,@FKTableName varchar(255)
            ,@FKParentTableName sysname
            ,@FKName sysname
            ,@FKColName sysname
            ,@RefColName sysname
            ,@ListOfFKCols varchar(100) = ''
            ,@ListOfRefCols varchar(100) = ''
            ,@CumulativeErrMsg varchar(8000)= ''
        
    DECLARE @SQLAction VARCHAR(20) = @Action
    
    DECLARE cFK CURSOR FOR
    SELECT DISTINCT OBJECT_NAME(s.parent_object_id)     AS fk_table
         , OBJECT_NAME(s.constraint_object_id)  AS fk_name
    FROM sys.foreign_key_columns s
    WHERE OBJECT_NAME(s.referenced_object_id) LIKE @ReferencedTableName
     	
    OPEN cFK
    FETCH NEXT FROM cFK INTO @FKTableName, @FKName
    WHILE @@FETCH_STATUS=0 
    BEGIN
        IF @Action <> 'CHECK' 
        BEGIN
            SET @sql='ALTER TABLE ['+@FKTableName+'] '+@SQLAction+' CONSTRAINT ['+@FKName+']'
        END
        ELSE
        BEGIN
            SELECT @FKParentTableName = OBJECT_NAME(f.referenced_object_id)
            FROM    sys.foreign_key_columns f 
            WHERE   f.constraint_object_id = OBJECT_ID(@FKName)

            SET @sql = 'IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N''[dbo].[' + @FKName + ']'') AND parent_object_id = OBJECT_ID(N''[dbo].[' + @FKTableName + ']''))
                        ALTER TABLE [dbo].[' + @FKTableName + '] DROP CONSTRAINT [' + @FKName + ']
                                                
                        ALTER TABLE [dbo].[' + @FKTableName + '] WITH CHECK ADD CONSTRAINT [' + @FKName + '] FOREIGN KEY('

            DECLARE cFKCols CURSOR FOR
            SELECT  p.name as FKcol
                    ,r.name as Refcol
            FROM    sys.foreign_key_columns f
            INNER JOIN  sys.columns p 
                ON p.column_id = f.parent_column_id
                AND p.[object_id] = f.parent_object_id
            INNER JOIN sys.columns r
                ON r.column_id = f.referenced_column_id
                AND r.[object_id] = f.referenced_object_id
            WHERE   f.constraint_object_id = OBJECT_ID(@FKName)

            OPEN cFKCols
            FETCH NEXT FROM cFKCols INTO @FKColName, @RefColName
            WHILE @@FETCH_STATUS=0 
            BEGIN
                SET @ListOfFKCols = ''  -- Make sure these strings are empty before proceding
                SET @ListOfRefCols = ''
                SET @ListOfFKCols = @ListOfFKCols + '[' + @FKColName + '],' 
                SET @ListOfRefCols = @ListOfRefCols + '[' + @RefColName + '],'
                FETCH NEXT FROM cFKCols INTO @FKColName, @RefColName
            END
            CLOSE cFKCols
            DEALLOCATE cFKCols	

            SET @ListOfFKCols = LEFT(@ListOfFKCols, LEN(@ListOfFKCols) -1)      -- remove the trailing comma in the lists
            SET @ListOfRefCols = LEFT(@ListOfRefCols, LEN(@ListOfRefCols) -1)

            SET @sql = @sql + @ListOfFKCols + ')
                        REFERENCES [dbo].[' + @FKParentTableName + '](' + @ListOfRefCols + ')'
                                    
            IF @OnDeleteAction = 'NOCHANGE' 
            BEGIN
                SELECT  @OnDeleteAction = 
                            (CASE WHEN delete_referential_action = 0 THEN 'NO ACTION'
                                  WHEN delete_referential_action = 1 THEN 'CASCADE'
                                  WHEN delete_referential_action = 2 THEN 'SET NULL'
                                  WHEN delete_referential_action = 3 THEN 'SET DEFAULT'
                             ELSE ''
                             END)
                FROM    sys.foreign_keys
                WHERE   [name] = @FKName
            END
            SET @sql = @sql + ' ON DELETE ' + @OnDeleteAction                 
            
            IF @OnUpdateAction = 'NOCHANGE' 
            BEGIN
                SELECT  @OnUpdateAction = 
                            (CASE WHEN update_referential_action = 0 THEN 'NO ACTION'
                                  WHEN update_referential_action = 1 THEN 'CASCADE'
                                  WHEN update_referential_action = 2 THEN 'SET NULL'
                                  WHEN update_referential_action = 3 THEN 'SET DEFAULT'
                             ELSE ''
                             END)
                FROM    sys.foreign_keys
                WHERE   [name] = @FKName
            END
            SET @sql = @sql + ' ON UPDATE ' + @OnUpdateAction 
            
            SET @sql = @sql + '
                        
                        ALTER TABLE [dbo].[' + @FKTableName + '] CHECK CONSTRAINT [' + @FKName + ']'
        END

        BEGIN TRY  	
        
            IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+'  '+@sql+' ...'
            IF @DebugExecute=1 PRINT @sql
            IF @DebugExecute=0 PRINT @sql EXEC(@sql)           

        END TRY
        BEGIN CATCH
            IF LEN(@CumulativeErrMsg)>0 SET @CumulativeErrMsg+=', '
            SET @CumulativeErrMsg+=@FKName
    	    
            IF @DebugPrint>0 PRINT ERROR_MESSAGE()
            IF @DebugPrint>0 PRINT '-- Error SQL:'+@sql
        END CATCH
       
        FETCH NEXT FROM cFK INTO @FKTableName, @FKName      
    END

    CLOSE cFK
    DEALLOCATE cFK	       
        
    -- Re-throw cumulative error string.
    IF LEN(@CumulativeErrMsg)>0
    BEGIN
        RAISERROR('Errors occurred taking action %s for Foreign Key(s): %s', 16,1,@SQLAction,@CumulativeErrMsg)
    END
    
    IF @DebugPrint>0 PRINT CONVERT(varchar(19), getdate(),121)+' Finished FK processing for '+@ReferencedTableName
    
END TRY
BEGIN CATCH
    IF @sql>''
    BEGIN
        PRINT '-- The following SQL may be the cause of the error'
        PRINT @sql	    
    END

	DECLARE @ErrorMessage VARCHAR(4000)= ERROR_MESSAGE()  ,
			@ErrorNumber INT = ERROR_NUMBER(),
			@ErrorSeverity INT= ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE(),
			@ErrorLine INT = ERROR_LINE(),
			@ErrorProcedure VARCHAR(126)= ISNULL(ERROR_PROCEDURE(), 'N/A');

	--Rethrow the error
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH

    -- make sure we have no persisted cursor.
    BEGIN TRY
        CLOSE cFK
        DEALLOCATE cFK	    
        CLOSE cFKCols
        DEALLOCATE cFKCols	 
    END TRY 
    BEGIN CATCH
        SET @sql=@sql -- must have 1 stmt in catch
    END CATCH	
END /*end proc*/