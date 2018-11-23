CREATE PROCEDURE [PreProcessing].[CBE_Supplement_Insert]
(
    @userid         INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	
	DECLARE @now                    DATETIME
	DECLARE @spname                 NVARCHAR(256)
	DECLARE @logmessage             NVARCHAR(MAX)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @successcountimport     INTEGER       = 0
	DECLARE @errorcountimport       INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    SELECT @now = GETDATE()

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

 --   EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	--                                            @dataimportdetailid    = @dataimportdetailid,
	--                                            @operationalstatusname = 'Processing',
	--                                            --@starttimeextract      = NULL,
	--                                            --@endtimeextract        = NULL,
	--                                            @starttimeimport       = @now,
	--                                            @endtimeimport         = NULL,
	--                                            @totalcountimport      = NULL,
	--                                            @successcountimport    = NULL,
	--                                            @errorcountimport      = NULL

 --   --Get configuration settings

 --   SELECT @informationsourceid = InformationSourceID
 --   FROM [Reference].[InformationSource]
 --   WHERE Name = 'CBE'

	--IF @informationsourceid IS NULL
	--BEGIN
	--    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL')
		
	--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--	                                      @logsource       = @spname,
	--										  @logmessage      = @logmessage,
	--										  @logmessagelevel = 'ERROR',
	--										  @messagetypecd   = 'Invalid Lookup'

 --       RETURN
 --   END
   
 --   --Updates to existing Products

	--UPDATE [Reference].[Product]
 --   SET    [Name]                        = b.Short_Description
 --         ,[Description]                 = b.Description
	--	  ,[ShortDescription]            = b.Short_Description
 --         ,[LastModifiedDate]            = GETDATE()
 --         ,[LastModifiedBy]              = @userid
	--	  ,[ArchivedInd]                = CASE WHEN b.Is_Active = 1 THEN 0 ELSE 1 END
 --         ,[SourceModifiedDate]         = b.[Date_Modified] 
 --         ,[IsRailTicketInd]            = 0
 --         ,[SundryCode]                 = b.[Sundry_Code]
	--	  ,[CapriCode]                  = b.[Capri_Code]
	--	  ,[ProductCategoryID]          = c.[ProductCategoryID]
	--	  ,[MinGroup]                   = b.[Min_Group]
	--	  ,[MaxGroup]                   = b.[Max_Group]
	--	  ,[MaxNumber]                  = b.[Max_Number]
	--	  ,[TicketClassID]              = d.[TicketClassID]
	--	  ,[StartDate]                  = b.[Start_Date]
	--	  ,[EndDate]                    = b.[End_Date]
 --   FROM [Reference].[Product] a
	--INNER JOIN [PreProcessing].[CBE_Supplement] b ON a.[SupplementCode] = b.[Supplement_Code]
	--                                              AND a.[SourceCreatedDate] = b.[Date_Created]
	--LEFT JOIN [Reference].[ProductCategory]     c ON c.ExtReference = b.Category
	--LEFT JOIN [Reference].[TicketClass]         d ON d.ExtReference = CAST(b.Class AS NVARCHAR(256))
	--WHERE b.DataImportDetailID  = @dataimportdetailid
	--AND   b.ProcessedInd = 0
	--AND   a.InformationSourceID = @informationsourceid

	----Set ProcessedInd = 1 on CBE_Supplement for those updated

	--UPDATE a
	--SET    ProcessedInd = 1
	--      ,[LastModifiedDateETL] = GETDATE()
	--FROM  [PreProcessing].[CBE_Supplement] a
	--INNER JOIN [Reference].[Product]       b ON a.[Supplement_Code] = b.[SupplementCode]
	--                                        AND a.[Date_Created]    = b.[SourceCreatedDate]
	--WHERE a.ProcessedInd = 0
	--AND   a.DataImportDetailID = @dataimportdetailid
	--AND   b.InformationSourceID = @informationsourceid
	
	----Add new Products
	
	--;WITH CTE_CBE_Supplement AS (
	--        SELECT [CBE_SupplementID]
 --                 ,[ID]
 --                 ,[Supplement_Code]
 --                 ,[Sundry_Code]
 --                 ,[Capri_Code]
 --                 ,[Description]
 --                 ,[Category]
 --                 ,[Short_Description]
 --                 ,[Min_Group]
 --                 ,[Max_Group]
 --                 ,[Max_Number]
 --                 ,[Class]
 --                 ,[Start_Date]
 --                 ,[End_Date]
 --                 ,[Date_Created]
 --                 ,[Date_Modified]
 --                 ,[Is_Active]
 --                 ,[Price]
 --                 ,[CreatedDateETL]
 --                 ,[LastModifiedDateETL]
 --                 ,[ProcessedInd]
 --                 ,[DataImportDetailID]
 --                 ,ROW_NUMBER() OVER (partition by [Supplement_Code]
	--		                                      ,[Sundry_Code]
	--										      ,[Capri_Code]
 --                                     ORDER BY Is_Active DESC
	--								          ,Date_Modified DESC
	--								          ,[CBE_SupplementID] DESC) RANKING
 --         FROM [PreProcessing].[CBE_Supplement]
	--	  WHERE  DataImportDetailID = @dataimportdetailid
	--      AND    ProcessedInd = 0)

	--INSERT INTO [Reference].[Product]
 --          ([Name]
 --          ,[Description]
	--	   ,[ShortDescription]
 --          ,[CreatedDate]
 --          ,[CreatedBy]
 --          ,[LastModifiedDate]
 --          ,[LastModifiedBy]
 --          ,[ArchivedInd]
	--	   ,[SupplementCode]
	--	   ,[SundryCode]
 --          ,[CapriCode]
 --          ,[ProductCategoryID]
	--	   ,[MinGroup]
	--	   ,[MaxGroup]
	--	   ,[MaxNumber]
	--	   ,[TicketClassID]
 --          ,[StartDate]
 --          ,[EndDate]
 --          ,[SourceCreatedDate]
 --          ,[SourceModifiedDate]
 --          ,[IsRailTicketInd]
 --          ,[ExtReference]
	--	   ,[InformationSourceID])
 --   SELECT  a.Short_Description
	--       ,a.Description
 --          ,a.Short_Description
	--	   ,GETDATE()
	--	   ,@userid
	--	   ,GETDATE()
	--	   ,@userid
	--	   ,CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	--       ,a.[Supplement_Code]
 --          ,a.[Sundry_Code]
	--	   ,a.[Capri_Code]
	--	   ,c.ProductCategoryID
	--	   ,a.[Min_Group]
	--	   ,a.[Max_Group]
	--	   ,a.[Max_Number]
	--	   ,b.[TicketClassID]
 --          ,a.[Start_Date]
 --          ,a.[End_Date]
 --          ,a.[Date_Created]
 --          ,a.[Date_Modified]
	--	   ,0
 --          ,CAST(a.[ID] AS NVARCHAR(256))
	--	   ,@informationsourceid
	--FROM CTE_CBE_Supplement       a
	--LEFT JOIN [Reference].[TicketClass]         b ON b.ExtReference = CAST(a.Class AS NVARCHAR(256))
	--LEFT JOIN [Reference].[ProductCategory]     c ON c.ExtReference = CAST(a.Category AS NVARCHAR(256))
	--LEFT JOIN [Reference].[Product]             e ON  e.[SupplementCode] = a.[Supplement_Code]
	--                                              AND e.[SourceCreatedDate] = a.[Date_Created]
	--											  AND e.InformationSourceID = @informationsourceid
	--											  AND e.IsRailTicketInd = 0
	--WHERE e.ProductID IS NULL
	--AND   a.RANKING = 1

	----Set ProcessedInd = 1 on CBE_Supplement for those added

	--UPDATE a
	--SET    ProcessedInd = 1
	--      ,[LastModifiedDateETL] = GETDATE()
	--FROM [PreProcessing].[CBE_Supplement] a
	--INNER JOIN [Reference].[Product]      b ON a.[Supplement_Code] = b.[SupplementCode]
	--                                       AND a.[Date_Created]   = b.[SourceCreatedDate]
	--WHERE a.ProcessedInd = 0
	--AND   a.DataImportDetailID = @dataimportdetailid
	--AND   b.InformationSourceID = @informationsourceid

	----Log processing information

 --   SELECT @now = GETDATE()

	--SELECT @successcountimport = COUNT(1)
 --   FROM   [PreProcessing].[CBE_Supplement]
	--WHERE  ProcessedInd = 1
	--AND    DataImportDetailID = @dataimportdetailid

	--SELECT @errorcountimport = COUNT(1)
	--FROM  [PreProcessing].[CBE_Supplement]
	--WHERE  ProcessedInd = 0
	--AND    DataImportDetailID = @dataimportdetailid

	--SELECT @recordcount = @successcountimport + @errorcountimport

	--EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	--                                            @dataimportdetailid    = @dataimportdetailid,
	--                                            @operationalstatusname = 'Completed',
	--                                            @starttimeextract      = NULL,
	--                                            @endtimeextract        = NULL,
	--                                            @starttimeimport       = NULL,
	--                                            @endtimeimport         = @now,
	--                                            @totalcountimport      = @recordcount,
	--                                            @successcountimport    = @successcountimport,
	--                                            @errorcountimport      = @errorcountimport

	----Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT    
	RETURN
END