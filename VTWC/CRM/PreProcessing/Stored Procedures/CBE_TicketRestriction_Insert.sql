CREATE PROCEDURE [PreProcessing].[CBE_TicketRestriction_Insert]
(
    @userid         INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	DECLARE @maxvalidityend         DATETIME

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
	--                                            @starttimeextract      = NULL,
	--                                            @endtimeextract        = NULL,
	--                                            @starttimeimport       = @now,
	--                                            @endtimeimport         = NULL,
	--                                            @totalcountimport      = NULL,
	--                                            @successcountimport    = NULL,
	--                                            @errorcountimport      = NULL

 --   --Get configuration settings

 --   SELECT @informationsourceid = InformationSourceID
 --   FROM [Reference].[InformationSource]
 --   WHERE Name = 'CBE'

	--SELECT @maxvalidityend = CAST([Reference].[Configuration_GetSetting] ('Operations','Maximum Validity End Date') AS DATETIME)

	--IF @informationsourceid IS NULL OR @maxvalidityend IS NULL
	--BEGIN
	--    SET @logmessage = 'No or invalid @informationsourceid or @maxvalidityend; ' +
	--	                  '@informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') + 
	--					  '@maxvalidityend = '      + ISNULL(CAST(@maxvalidityend AS NVARCHAR(256)),'NULL') 
		
	--	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--	                                      @logsource       = @spname,
	--										  @logmessage      = @logmessage,
	--										  @logmessagelevel = 'ERROR',
	--										  @messagetypecd   = 'Invalid Lookup'

 --       RETURN
 --   END

 --   --Create temporary table to avoid multiple CTE being created for each step

	--;WITH CTE_TicketRestriction AS (
	--              SELECT a.[ID]
 --                       ,a.[Code]
 --                       ,a.[Outbound_Description]
 --                       ,a.[Return_Description]
 --                       ,a.[Date_Created]
 --                       ,a.[Date_Modified]
 --                       ,a.[Is_Active]
 --                       ,a.[NRES_Name]
 --                       ,a.[NRES_Outward_Direction]
 --                       ,a.[NRES_Return_Direction]
 --                       ,a.[NRES_Outward_Status]
 --                       ,a.[NRES_Return_Status]
 --                       ,a.[NRES_Restriction_Type]
 --                       ,a.[NRES_Detail_Page_Link]
 --                       ,a.[NRES_Restriction_Identifier]
 --                       ,a.[NRES_Easement_Info]
 --                       ,a.[NRES_Applicable_Days_Info]
 --                       ,a.[NRES_Notes]
 --                       ,a.[NRES_Seasonal_Variations_Info]
 --                       ,ROW_NUMBER() OVER (partition by [Code] ORDER BY a.[Date_Modified] DESC
	--					                                                ,a.[CreatedDateETL] DESC) RANKING
 --                 FROM   [PreProcessing].[CBE_TicketRestriction] a
	--			  WHERE  a.DataImportDetailID = @dataimportdetailid
	--              AND    a.ProcessedInd = 0)

 --   SELECT *
	--INTO #tmp_TicketRestriction
	--FROM CTE_TicketRestriction
	--WHERE RANKING = 1

 --   --Ticket Restrictions in [Reference].[TicketRestriction] but not in ##tmp_TicketRestriction are to be treated as expired references

	--UPDATE a
	--SET  ValidityEndDate        = GETDATE()
	--    ,ArchivedInd            = 1
	--	,LastModifiedDate       = GETDATE()
	--	,LastModifiedBy         = @userid
 --   FROM [Reference].[TicketRestriction] a
	--LEFT JOIN #tmp_TicketRestriction     b ON a.Code = b.Code
	--WHERE a.InformationSourceID = @informationsourceid
	--AND   a.ArchivedInd = 0
	--AND   b.Code IS NULL

 --   --Updates to existing Ticket Restrictions

	--UPDATE a
 --   SET [LastModifiedDate]             = GETDATE()
 --      ,[LastModifiedBy]               = @userid
 --      ,[ArchivedInd]                  = CASE WHEN b.Is_Active = 0 THEN 1 ELSE 0 END
 --      ,[OutboundDescription]          = b.[Outbound_Description]
 --      ,[ReturnDescription]            = b.[Return_Description]
 --      ,[SourceCreatedDate]            = b.[Date_Created]
 --      ,[SourceModifiedDate]           = b.[Date_Modified]
 --      ,[NRESName]                     = b.[NRES_Name]
 --      ,[NRESOutward_Direction]        = b.[NRES_Outward_Direction]
 --      ,[NRESReturn_Direction]         = b.[NRES_Return_Direction]
 --      ,[NRESOutward_Status]           = b.[NRES_Outward_Status]
 --      ,[NRESReturn_Status]            = b.[NRES_Return_Status]
 --      ,[NRESRestriction_Type]         = b.[NRES_Restriction_Type]
 --      ,[NRESDetail_Page_Link]         = b.[NRES_Detail_Page_Link]
 --      ,[NRESRestriction_Identifier]   = b.[NRES_Restriction_Identifier]
 --      ,[NRESEasement_Info]            = b.[NRES_Easement_Info]
 --      ,[NRESApplicable_Days_Info]     = b.[NRES_Applicable_Days_Info]
 --      ,[NRESNotes]                    = b.[NRES_Notes]
 --      ,[NRESSeasonal_Variations_Info] = b.[NRES_Seasonal_Variations_Info]
 --   FROM [Reference].[TicketRestriction] a
	--INNER JOIN #tmp_TicketRestriction b ON a.Code = b.Code
	--                                       AND a.InformationSourceID = @informationsourceid
	--									   AND a.ArchivedInd = 0

	----Set ProcessedInd = 1 on CBE_TicketRestriction for those updated
	
	--UPDATE a
 --   SET    [LastModifiedDateETL] = GETDATE()
 --         ,[ProcessedInd] = 1
 --         ,[DataImportDetailID] = @dataimportdetailid
 --   FROM   [PreProcessing].[CBE_TicketRestriction] a
	--INNER JOIN [Reference].[TicketRestriction]     b ON  a.Code                = b.Code
	--										         AND b.InformationSourceID = @informationsourceid
 --   WHERE a.DataImportDetailID = @dataimportdetailid
	--AND   a.ProcessedInd = 0

	----Add new Ticket Restrictions
	
	--INSERT INTO [Reference].[TicketRestriction]
 --          ([Name]
 --          ,[Description]
 --          ,[CreatedDate]
 --          ,[CreatedBy]
 --          ,[LastModifiedDate]
 --          ,[LastModifiedBy]
 --          ,[ArchivedInd]
 --          ,[InformationSourceID]
 --          ,[Code]
 --          ,[OutboundDescription]
 --          ,[ReturnDescription]
 --          ,[SourceCreatedDate]
 --          ,[SourceModifiedDate]
 --          ,[NRESName]
 --          ,[NRESOutward_Direction]
 --          ,[NRESReturn_Direction]
 --          ,[NRESOutward_Status]
 --          ,[NRESReturn_Status]
 --          ,[NRESRestriction_Type]
 --          ,[NRESDetail_Page_Link]
 --          ,[NRESRestriction_Identifier]
 --          ,[NRESEasement_Info]
 --          ,[NRESApplicable_Days_Info]
 --          ,[NRESNotes]
 --          ,[NRESSeasonal_Variations_Info]
 --          ,[ExtReference]
	--	   ,[ValidityStartDate]
	--	   ,[ValidityEndDate])
 --   SELECT NULL
 --         ,NULL	
	--      ,GETDATE()
	--	  ,@userid
	--	  ,GETDATE()
	--	  ,@userid
	--      ,CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	--	  ,@informationsourceid
	--	  ,a.[Code]
 --         ,a.[Outbound_Description]
 --         ,a.[Return_Description]
 --         ,a.[Date_Created]
 --         ,a.[Date_Modified]
 --         ,a.[NRES_Name]
 --         ,a.[NRES_Outward_Direction]
 --         ,a.[NRES_Return_Direction]
 --         ,a.[NRES_Outward_Status]
 --         ,a.[NRES_Return_Status]
 --         ,a.[NRES_Restriction_Type]
 --         ,a.[NRES_Detail_Page_Link]
 --         ,a.[NRES_Restriction_Identifier]
 --         ,a.[NRES_Easement_Info]
 --         ,a.[NRES_Applicable_Days_Info]
 --         ,a.[NRES_Notes]
 --         ,a.[NRES_Seasonal_Variations_Info]
	--	  ,CAST(a.[ID] AS NVARCHAR(256))
 --         ,GETDATE()
	--	  ,CASE WHEN a.Is_Active = 1 THEN GETDATE() ELSE @maxvalidityend END 
 --   FROM #tmp_TicketRestriction a
	--LEFT JOIN [Reference].[TicketRestriction] b ON a.Code = b.Code
	--                                               AND b.InformationSourceID = @informationsourceid
	--									           AND b.ArchivedInd         = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	--WHERE b.Code IS NULL
 --   AND   a.Is_Active = 1

	----Set ProcessedInd = 1 on CBE_TicketRestriction for those added

	--UPDATE a
 --   SET    [LastModifiedDateETL] = GETDATE()
 --         ,[ProcessedInd] = 1
 --         ,[DataImportDetailID] = @dataimportdetailid
 --   FROM   [PreProcessing].[CBE_TicketRestriction] a
	--INNER JOIN [Reference].[TicketRestriction]     b ON  a.Code                = b.Code
	--										         AND b.InformationSourceID = @informationsourceid

 --   WHERE a.DataImportDetailID = @dataimportdetailid
	--AND   a.ProcessedInd = 0

	----Log processing information

 --   SELECT @now = GETDATE()

	--SELECT @successcountimport = COUNT(1)
 --   FROM   [PreProcessing].[CBE_TicketRestriction]
	--WHERE  ProcessedInd = 1
	--AND    DataImportDetailID = @dataimportdetailid

	--SELECT @errorcountimport = COUNT(1)
	--FROM  [PreProcessing].[CBE_TicketRestriction]
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