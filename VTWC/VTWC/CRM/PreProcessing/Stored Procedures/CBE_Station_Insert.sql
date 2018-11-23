CREATE PROCEDURE [PreProcessing].[CBE_Station_Insert]
(
    @userid         INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @now                   DATETIME

	DECLARE @spname                NVARCHAR(256)
	DECLARE @recordcount           INTEGER       = 0
	DECLARE @successcountimport    INTEGER       = 0
	DECLARE @errorcountimport      INTEGER       = 0
	DECLARE @logtimingidnew        INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    SELECT @now = GETDATE()

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

    --Updates to existing Locations

/** NEED TO CONFIRM MATCHING INFORMATION FROM MSD/CBE/ATOC to ensure name matching is not affected by using CBE Names
	UPDATE a
	SET [Name]                   = b.Name
       ,[TIPLOC]                 = b.[TIPLOC]
       ,[CRSCode]                = b.[CRS]
       ,[NLCPlusbus]             = b.[Plusbus_NLC]
       ,[PTECode]                = b.[PTE_Code]
       ,[IsPlusbusInd]           = b.[Is_Plusbus]
       ,[IsGroupStationInd]      = b.[Is_GroupStation]
       ,[LondonZoneNumber]       = b.[London_Zone_Number]
       ,[PartOfAllZones]         = b.[Part_Of_All_Zones]
       ,[IDMSDisplayName]        = b.[IDMS_Display_Name]
       ,[IDMSPrintingName]       = b.[IDMS_Printing_Name]
       ,[IsIDMSAttendedTISInd]   = b.[IDMS_Attended_TIS]
       ,[IsIDMSUnattendedTISInd] = b.[IDMS_Unattended_TIS]
       ,[IDMSAdviceMessage]      = b.[IDMS_Advice_Message]
	   ,[SourceModifiedDate]     = b.[Date_Modified]
	   ,[LastModifiedDate]       = GETDATE()
    FROM Reference.Location a
	INNER JOIN Processing.CBE_Station b ON a.[NLCCode] = b.[NLC]
	WHERE b.[NLC] IS NOT NULL
	AND   b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	UPDATE a
	SET [Name]                   = b.Name
       ,[TIPLOC]                 = b.[TIPLOC]
       ,[NLCPlusbus]             = b.[Plusbus_NLC]
       ,[PTECode]                = b.[PTE_Code]
       ,[IsPlusbusInd]           = b.[Is_Plusbus]
       ,[IsGroupStationInd]      = b.[Is_GroupStation]
       ,[LondonZoneNumber]       = b.[London_Zone_Number]
       ,[PartOfAllZones]         = b.[Part_Of_All_Zones]
       ,[IDMSDisplayName]        = b.[IDMS_Display_Name]
       ,[IDMSPrintingName]       = b.[IDMS_Printing_Name]
       ,[IsIDMSAttendedTISInd]   = b.[IDMS_Attended_TIS]
       ,[IsIDMSUnattendedTISInd] = b.[IDMS_Unattended_TIS]
       ,[IDMSAdviceMessage]      = b.[IDMS_Advice_Message]
	   ,[SourceModifiedDate]     = b.[Date_Modified]
	   ,[LastModifiedDate]       = GETDATE()
    FROM Reference.Location a
	INNER JOIN Processing.CBE_Station b ON a.[CRSCode] = b.[CRS]
	WHERE b.[NLC] IS NULL
	AND   b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

***/

	--Set ProcessedInd = 1 on CBE_Station for those updated

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM Reference.Location a
	INNER JOIN Processing.CBE_Station b ON a.[NLCCode] = b.[NLC]
	WHERE b.[NLC] IS NOT NULL
	AND   b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM Reference.Location a
	INNER JOIN Processing.CBE_Station b ON a.[CRSCode] = b.[CRS]
	WHERE b.[NLC] IS NULL
	AND   b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	--Add new Products

    INSERT INTO [Reference].[Location]
           ([Name]
           ,[TIPLOC]
           ,[NLCCode]
           ,[CRSCode]
           ,[NLCPlusbus]
           ,[PTECode]
           ,[IsPlusbusInd]
           ,[IsGroupStationInd]
           ,[LondonZoneNumber]
           ,[PartOfAllZones]
           ,[IDMSDisplayName]
           ,[IDMSPrintingName]
           ,[IsIDMSAttendedTISInd]
           ,[IsIDMSUnattendedTISInd]
           ,[IDMSAdviceMessage]
           ,[ExtReference]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[CreatedDate]
           ,[LastModifiedDate])
     SELECT a.[Name]
           ,a.[TIPLOC]
           ,a.[NLC]
           ,a.[CRS]
           ,a.[Plusbus_NLC]
           ,a.[PTE_Code]
           ,a.[Is_Plusbus]
           ,a.[Is_GroupStation]
           ,a.[London_Zone_Number]
           ,a.[Part_Of_All_Zones]
           ,a.[IDMS_Display_Name]
           ,a.[IDMS_Printing_Name]
           ,a.[IDMS_Attended_TIS]
           ,a.[IDMS_Unattended_TIS]
           ,a.[IDMS_Advice_Message]
           ,CAST(a.[ID] AS NVARCHAR(256))
           ,a.[Date_Created]
           ,a.[Date_Modified]
           ,GETDATE()
           ,GETDATE()
    FROM Processing.CBE_Station a
	LEFT JOIN Reference.Location b ON a.[NLC] = b.[NLCCode] AND a.[NLC] IS NOT NULL
	WHERE b.[NLCCode] IS NULL
	AND   a.[DataImportDetailID] = @dataimportdetailid
	AND   a.[ProcessedInd] = 0

	INSERT INTO [Reference].[Location]
           ([Name]
           ,[TIPLOC]
           ,[NLCCode]
           ,[CRSCode]
           ,[NLCPlusbus]
           ,[PTECode]
           ,[IsPlusbusInd]
           ,[IsGroupStationInd]
           ,[LondonZoneNumber]
           ,[PartOfAllZones]
           ,[IDMSDisplayName]
           ,[IDMSPrintingName]
           ,[IsIDMSAttendedTISInd]
           ,[IsIDMSUnattendedTISInd]
           ,[IDMSAdviceMessage]
           ,[ExtReference]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[CreatedDate]
           ,[LastModifiedDate])
     SELECT a.[Name]
           ,a.[TIPLOC]
           ,a.[NLC]
           ,a.[CRS]
           ,a.[Plusbus_NLC]
           ,a.[PTE_Code]
           ,a.[Is_Plusbus]
           ,a.[Is_GroupStation]
           ,a.[London_Zone_Number]
           ,a.[Part_Of_All_Zones]
           ,a.[IDMS_Display_Name]
           ,a.[IDMS_Printing_Name]
           ,a.[IDMS_Attended_TIS]
           ,a.[IDMS_Unattended_TIS]
           ,a.[IDMS_Advice_Message]
           ,CAST(a.[ID] AS NVARCHAR(256))
           ,a.[Date_Created]
           ,a.[Date_Modified]
           ,GETDATE()
           ,GETDATE()
    FROM Processing.CBE_Station a
	LEFT JOIN Reference.Location b ON a.[CRS] = b.[CRSCode] AND a.[NLC] IS NULL
	WHERE b.[CRSCode] IS NULL
	AND   a.[DataImportDetailID] = @dataimportdetailid
	AND   a.[ProcessedInd] = 0


	--Set ProcessedInd = 1 on CBE_Station for those added

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM Reference.Location a
	INNER JOIN Processing.CBE_Station b ON a.[NLCCode] = b.[NLC]
	WHERE b.[NLC] IS NOT NULL
	AND   b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM Reference.Location a
	INNER JOIN Processing.CBE_Station b ON a.[CRSCode] = b.[CRS]
	WHERE b.[NLC] IS NULL
	AND   b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0


	--Log processing information

    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[MSD_Product]
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM  [PreProcessing].[MSD_Product]
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

	EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
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
END