
/*===========================================================================================
Name:         dbo.fnGetTableRecordCount
Purpose:      Gets a count of rows in a table by reading dm tables for fast performance.
Parameters:   
Notes:        This is used is some procs that call inferred members for better performance.
History:      
Created:      2011-01-17 PhilipR 
Modified:     2011-08-18 Philip Robinson. Adding EXECUTE AS because function requires permission to sys views.
Call Script:  
=================================================================================================*/

CREATE FUNCTION dbo.fnGetTableRecordCount(@ObjectName sysname)

RETURNS INT
WITH EXECUTE AS OWNER

BEGIN

DECLARE @RowCount int

SELECT @RowCount =  row_count
FROM sys.dm_db_partition_stats
WHERE OBJECT_ID = OBJECT_ID(@ObjectName)
        AND index_id < 2

RETURN @RowCount

END