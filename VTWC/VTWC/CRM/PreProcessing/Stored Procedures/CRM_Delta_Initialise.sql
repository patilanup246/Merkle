

CREATE PROCEDURE [PreProcessing].[CRM_Delta_Initialise]
(
	@userid                INTEGER = 0,
    @dataimporttype        NVARCHAR(256)
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @dataimportdetailid     INTEGER
	DECLARE @destinationtable       NVARCHAR(256)
	DECLARE @sourcetable            NVARCHAR(256)
    DECLARE @parmlist               NVARCHAR(MAX)
	DECLARE @localcopyind           BIT
	DECLARE @fieldlist              NVARCHAR(MAX)
	DECLARE @sql                    NVARCHAR(MAX)

	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0
	DECLARE @dataimporttypeid       INTEGER
	DECLARE @dataimportlogid        INTEGER
	DECLARE @operationalstatusid    INTEGER
	DECLARE @recordcount            INTEGER
	DECLARE @spname                 NVARCHAR(256)
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)
	DECLARE @params					NVARCHAR(MAX)
	DECLARE @count					INTEGER
	DECLARE @ROWCOUNT				INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	 EXEC [Operations].[LogTiming_Record] @userid         = 0 ,
	                                      @logsource      = @spname,
					  					  @logtimingidnew = @logtimingidnew OUTPUT
										 
 --   --Initiate import logging details

 --   SELECT @operationalstatusid = OperationalStatusID
	--FROM   Reference.OperationalStatus
	--WHERE  Name = 'Retrieving'

	
	--SELECT @dataimporttypeid = DataImportTypeID
	--FROM   [Reference].[DataImportType]
	--WHERE  Name = @dataimporttype 

	--EXEC @dataimportlogid = [Operations].[DataImportLog_Add] @userid           = 0,
	--                                                         @dataimporttypeid = @dataimporttypeid

	--IF @dataimportlogid < 0
	--BEGIN

	--	SET @logmessage = 'No Dataimportlogid returned'  
	    
	--    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--                                          @logsource       = @spname,
	--		    							  @logmessage      = @logmessage,
	--			    						  @logmessagelevel = 'ERROR',
	--					    				  @messagetypecd   = NULL
	--    RETURN
	--END

 --   UPDATE Operations.DataImportLog
	--SET   OperationalStatusID = @operationalstatusid
	--WHERE DataImportLogID   = @dataimportlogid
	--AND   DataImportTypeID  = @dataimporttypeid
 
 --   IF NOT EXISTS (SELECT 1
	--               FROM  Operations.DataImportDetail
 --                  WHERE DataImportLogID = @dataimportlogid)
 --   BEGIN
	--    SET @logmessage = 'No or invalid data import log reference.' + ISNULL(CAST(@dataimportdetailid AS NVARCHAR(256)),'NULL') 
	    
	--    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--                                          @logsource       = @spname,
	--		    							  @logmessage      = @logmessage,
	--			    						  @logmessagelevel = 'ERROR',
	--					    				  @messagetypecd   = NULL
 --       RETURN
 --   END	

	--DECLARE DataImportDetail CURSOR READ_ONLY
	--FOR
 --       SELECT a.DataImportDetailID
	--	      ,a.DestinationTable
	--		  ,b.LocalCopyInd
 --       FROM   Operations.DataImportDetail a
	--	INNER JOIN Reference.DataImportDefinition b ON a.DataImportDefinitionID = b.DataImportDefinitionID
 --       WHERE  a.DataImportLogID = @dataimportlogid
 
 --       OPEN   DataImportDetail     

	--    FETCH NEXT FROM DataImportDetail
	--	    INTO @dataimportdetailid
	--		    ,@destinationtable
	--			,@localcopyind

 --   	WHILE @@FETCH_STATUS = 0
	--	BEGIN
	--        IF EXISTS (SELECT *
 --                      FROM SYS.SYNONYMS
	--	               WHERE COALESCE(PARSENAME(base_object_name,2),SCHEMA_NAME(SCHEMA_ID())) = 'PreProcessing'
	--				   AND   (COALESCE(PARSENAME(base_object_name,1),SCHEMA_NAME(SCHEMA_ID())) =  @destinationtable)
	--				    OR COALESCE(PARSENAME(base_object_name,1),SCHEMA_NAME(SCHEMA_ID())) =  @destinationtable + '_Local' )
 --           BEGIN
	--		    IF @localcopyind = 1
	--		    BEGIN 
	--		    /*** These tables are to be copied to the local database server for performance reasons ***/

 --                   /*** Check the local table exists ***/
				  
	--			    IF EXISTS (SELECT 1 
 --                              FROM INFORMATION_SCHEMA.TABLES
	--	                       WHERE TABLE_SCHEMA = 'PreProcessing'
	--			               AND   TABLE_NAME   = @destinationtable + '_Local')
 --                   BEGIN
			
	--					SELECT @sourcetable = '[' + [Reference].[Configuration_GetSetting] ('CBE Staging','CBE Staging Link Name') + '].' +
 --                                             '[' + [Reference].[Configuration_GetSetting] ('CBE Staging','CBE Staging DB Name') +
	--										   '].PreProcessing.' + @destinationtable

 --    				    SET @sql = 'UPDATE '+ @sourcetable + ' ' +
 --                                  'SET    DataImportDetailID = ' + CAST(@dataimportdetailid AS NVARCHAR(256)) + ' ' +
	--                               'WHERE  DataImportDetailID IS NULL'

	--		            EXEC sp_executesql @stmt = @sql

	--		           /*** Copy data from CBE-staging to CEM preprocessing Local table ***/

	--				    SET @fieldlist = NULL

 --                       SELECT @fieldlist = COALESCE(@fieldlist + ', ','')  + '[' + Column_Name + ']'
 --                       FROM information_schema.columns 
 --                       WHERE TABLE_SCHEMA = 'PreProcessing'
 --                       AND   TABLE_NAME = @destinationtable + '_Local'

	--			        SET @sql = 'INSERT INTO Preprocessing.' + @destinationtable + '_Local (' +
 --                                   @fieldlist + ') ' + 
 --                                  'SELECT ' + @fieldlist + ' FROM ' + 
	--							    @sourcetable + ' ' +
 --                                  'WHERE Dataimportdetailid = ' + CAST(@dataimportdetailid AS NVARCHAR(256))

	--		            EXEC sp_executesql @stmt = @sql

	--		            /*** Get counts from CEM Preprocessing Local table ***/

	--		            SET @parmlist = '@recordcount INTEGER OUTPUT'

	--			        SET @sql = 'SELECT @recordcount = COUNT(1) ' +
	--					     	   'FROM PreProcessing.' + @destinationtable + '_Local' + ' ' +
	--							   'WHERE Dataimportdetailid = ' + CAST(@dataimportdetailid AS NVARCHAR(256))

	--			        EXEC sp_executesql @stmt         = @sql
	--		                              ,@params       = @parmlist
	--					 				  ,@recordcount  = @recordcount OUTPUT
		
	--			        SELECT @now = GETDATE()

	--				    IF @recordcount = 0
	--				    BEGIN
	--				        EXEC Operations.DataImportDetail_Update @userid                = @userid,
	--                                                                @dataimportdetailid    = @dataimportdetailid,
	--                                                                @operationalstatusname = 'Completed',
	--                                                                @starttimeextract      = NULL,
	--                                                                @endtimeextract        = NULL,
	--                                                                @starttimeimport       = @now,
	--                                                                @endtimeimport         = @now,
	--                                                                @totalcountimport      = 0,
	--                                                                @successcountimport    = 0,
	--                                                                @errorcountimport      = 0
                     
	--				    END
	--				    ELSE
	--				    BEGIN
	--				        EXEC Operations.DataImportDetail_Update @userid                = @userid,
	--                                                                @dataimportdetailid    = @dataimportdetailid,
	--                                                                @operationalstatusname = 'Pending',
	--                                                                @starttimeextract      = NULL,
	--                                                                @endtimeextract        = NULL,
	--                                                                @starttimeimport       = @now,
	--                                                                @endtimeimport         = @now,
	--                                                                @totalcountimport      = @recordcount,
	--                                                                @successcountimport    = NULL,
	--                                                                @errorcountimport      = NULL
	--			        END
 --                   END
 --               END
	--			ELSE
	--			BEGIN
	--		        SET @sql = 'UPDATE [PreProcessing].' + @destinationtable + ' ' +
 --                              'SET    DataImportDetailID = ' + CAST(@dataimportdetailid AS NVARCHAR(256)) + ' ' +
	--		                   'WHERE  DataImportDetailID IS NULL'

	--	            EXEC sp_executesql @stmt = @sql
	--           END
	--		END
	--		ELSE
	--		BEGIN
	--			SET @logmessage = 'Invalid PreProcessing table reference.' + ISNULL(@destinationtable,'NULL') 
	    
	--            EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--                                                  @logsource       = @spname,
	--		    		        					  @logmessage      = @logmessage,
	--			    			        			  @logmessagelevel = 'ERROR',
	--					    			         	  @messagetypecd   = 'Invalid Lookup'    
 --           END

 --           FETCH NEXT FROM DataImportDetail
	--	        INTO @dataimportdetailid
	--		        ,@destinationtable
	--				,@localcopyind

 --       END

	--	CLOSE DataImportDetail

 --   DEALLOCATE DataImportDetail

    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END