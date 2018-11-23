/*===========================================================================================
Purpose:		PreProcessing.uspSSISInsertRailblazersEvolvi
Notes:			Procedure to load Railblazers (Evolvi) file into PreProcessing.RailBlazers_Data table
Parameters:		@Parameter - The parameter name
				@Description - The sdescription 
				@Datatype - The datatype - Date (YYYYMMDD), Datetime (YYYYMMDD HH:MM), Int, Numeric, Text
				@RowChangeReason - Was this row last changed by the [E]TL process [T]ouchpoint, [M] Manual
				@RowChangeOperator - shows SYSTEM_USER if not specified            
Created			2018-08-08 Juanjo Diaz (jdiaz@merkleinc.com)
Modified:
=================================================================================================*/
CREATE PROCEDURE PreProcessing.uspSSISInsertRailblazersEvolvi 
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER,
	@importfilename        NVARCHAR(256)
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	DECLARE @maxvalidityend         DATETIME

	DECLARE @now                    DATETIME
	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)
	DECLARE @successcountimport    INTEGER       = 0
	DECLARE @errorcountimport      INTEGER       = 0

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	SELECT @now = GETDATE()

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
												@importfilename        = @importfilename,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

    --Get configuration settings

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Evolvi'

	/***********************************/

	
	/***********************************/

	SELECT @recordcount = @successcountimport + @errorcountimport

	
    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	                                            @starttimeimport       = NULL,
	                                            @endtimeimport         = @now,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = @successcountimport,
	                                            @errorcountimport      = @errorcountimport


    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END;