CREATE PROCEDURE [PreProcessing].[CBE_TicketType_Insert]
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
 --   SET    [Name]                        = CASE WHEN b.IDMS_Display_Name IS NULL THEN b.Short_Description ELSE b.IDMS_Display_Name END
 --         ,[Description]                 = b.Description
	--	  ,[ShortDescription]            = b.Short_Description
 --         ,[LastModifiedDate]            = GETDATE()
 --         ,[LastModifiedBy]              = @userid
	--	  ,[ArchivedInd]                 = CASE WHEN b.Is_Active = 1 THEN 0 ELSE 1 END
 --         ,[TicketClassID]               = c.TicketClassID
 --         ,[TicketTypeID]                = d.TicketTypeID

	--	--  ,[TicketGroupID] = <TicketGroupID, int,>
 --       --  ,[TOCIDSpecific] = <TOCIDSpecific, int,>

 --         ,[ReturnInd]                   = CASE b.Ticket_Type WHEN	'R' THEN 1 ELSE 0 END

 --         ,[SourceModifiedDate]         = b.[Date_Modified] 
 --         ,[IsRailTicketInd]            = 1
 --         ,[LTOT]                       = b.LTOT
 --         ,[IsSeasonTicketInd]          = b.[Is_Season_Ticket]
 --         ,[SeasonType]                 = b.[Season_Type]
 --         ,[StartDate]                  = b.[Start_Date]
 --         ,[EndDate]                    = b.[End_Date]
 --         ,[TicketValidityID]           = e.TicketValidityID
 --         ,[UTSCode]                    = b.[UTS_Code]
 --         ,[Time_Restriction]           = b.[Time_Restriction]
 --         ,[RSPAdvice]                  = b.[RSP_Advice]
 --         ,[IDMSDisplayName]            = b.[IDMS_Display_Name]
 --         ,[IDMSPrintingName]           = b.[IDMS_Printing_Name]
 --         ,[IsIDMSAttendedTISInd]       = b.[IDMS_Attended_TIS]
 --         ,[IsIDMSUnattendedTISInd]     = b.[IDMS_Unattended_TIS]
 --         ,[IDMSAdviceMessage]          = b.[IDMS_Advice_Message]
 --         ,[Format]                     = b.[Format]
 --         ,[IsNRESApplicableAllTOCsInd] = b.[NRES_Applicable_All_TOCs]
 --         ,[NRESFareCategory]           = b.[NRES_Fare_Category]
 --         ,[IsNRESIncludesGroupSaveInd] = b.[NRES_Includes_GroupSave]
 --         ,[NRESName]                   = b.[NRES_Name]
 --         ,[NRESDescription]            = b.[NRES_Description]
 --         ,[NRESBreaksJourney]          = b.[NRES_Breaks_Journey]
 --         ,[NRESConditionsInfo]         = b.[NRES_Conditions_Info]
 --         ,[NRESAvailabilityInfo]       = b.[NRES_Availability_Info]
 --         ,[NRESRetailingInfo]          = b.[NRES_Retailing_Info]
 --         ,[NRESBookingDeadlinesInfo]   = b.[NRES_Booking_Deadlines_Info]
 --         ,[NRESChangesTRVLPlansInfo]   = b.[NRES_Changes_TRVL_Plans_Info]
 --         ,[NRESRefundsInfo]            = b.[NRES_Refunds_Info]
 --         ,[NRESDiscountsInfo]          = b.[NRES_Discounts_Info]
 --   FROM [Reference].[Product] a
	--INNER JOIN [PreProcessing].[CBE_TicketType] b ON a.FTOT = b.FTOT
	--                                              AND a.LTOT = b.LTOT
	--											  AND a.SourceCreatedDate = b.[Date_Created]
	--LEFT JOIN [Reference].[TicketClass]         c ON c.ExtReference = CAST(b.Ticket_Class AS NVARCHAR(256))
	--LEFT JOIN [Reference].[TicketType]          d ON d.ExtReference = CAST(b.Ticket_Type AS NVARCHAR(256))
 --   LEFT JOIN [Reference].[TicketValidity]      e ON b.[Ticket_Validity_Code] = e.Code
	--WHERE b.DataImportDetailID  = @dataimportdetailid
	--AND   b.ProcessedInd = 0
	--AND   a.InformationSourceID = @informationsourceid

	----Set ProcessedInd = 1 on CBE_TicketType for those updated

	--UPDATE a
	--SET    ProcessedInd = 1
	--      ,[LastModifiedDateETL] = GETDATE()
	--FROM  [PreProcessing].[CBE_TicketType] a
	--INNER JOIN [Reference].[Product] b ON a.FTOT = b.FTOT
	--                                   AND a.LTOT = b.LTOT
	--WHERE a.ProcessedInd = 0
	--AND   a.DataImportDetailID = @dataimportdetailid
	--AND   b.InformationSourceID = @informationsourceid
	
	----Add new Products

 --   ;WITH CTE_CBE_TicketType AS (
 --        SELECT TOP 999999999
	--			[CBE_TicketTypeID]
 --              ,[ID]
 --              ,[FTOT]
 --              ,[Description]
 --              ,[LTOT]
 --              ,[Is_Season_Ticket]
 --              ,[Ticket_Class]
 --              ,[Ticket_Type]
 --              ,[Reservation_Code]
 --              ,[Ticket_Validity_Code]
 --              ,[UTS_Code]
 --              ,[Is_CCST]
 --              ,[Is_Smart]
 --              ,[Is_Self_Print]
 --              ,[Is_TOD]
 --              ,[Is_Mobile]
 --              ,[Is_RCH_To]
 --              ,[Is_RCH_TVM]
 --              ,[Is_RCH_Mobile]
 --              ,[Is_RCH_Web]
 --              ,[Is_RCH_Attended_Kiosk]
 --              ,[Is_RCH_Self_Service_Kiosk]
 --              ,[Time_Restriction]
 --              ,[Season_Type]
 --              ,[Short_Description]
 --              ,[RSP_Advice]
 --              ,[IDMS_Display_Name]
 --              ,[IDMS_Printing_Name]
 --              ,[IDMS_Attended_TIS]
 --              ,[IDMS_Unattended_TIS]
 --              ,[IDMS_Advice_Message]
 --              ,[Start_Date]
 --              ,[End_Date]
 --              ,[Date_Created]
 --              ,[Date_Modified]
 --              ,[Is_Active]
 --              ,[Format]
 --              ,[NRES_Applicable_All_TOCs]
 --              ,[NRES_Fare_Category]
 --              ,[NRES_Includes_GroupSave]
 --              ,[NRES_Name]
 --              ,[NRES_Description]
 --              ,[NRES_Breaks_Journey]
 --              ,[NRES_Conditions_Info]
 --              ,[NRES_Availability_Info]
 --              ,[NRES_Retailing_Info]
 --              ,[NRES_Booking_Deadlines_Info]
 --              ,[NRES_Changes_TRVL_Plans_Info]
 --              ,[NRES_Refunds_Info]
 --              ,[NRES_Discounts_Info]
 --              ,[CreatedDateETL]
 --              ,[LastModifiedDateETL]
 --              ,[ProcessedInd]
 --              ,[DataImportDetailID]
 --              ,ROW_NUMBER() OVER (partition by [FTOT]
	--		                                   ,[LTOT]
 --                                     ORDER BY Is_Active
	--								          ,Date_Modified DESC
	--								          ,[CBE_TicketTypeID] DESC) RANKING
 --         FROM [PreProcessing].[CBE_TicketType]
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
 --          ,[ProductGroupID]
 --          ,[TicketTypeCode]
 --          ,[TicketClassID]
 --          ,[TicketTypeID]
 --          ,[TicketGroupID]
 --          ,[TOCIDSpecific]
 --          ,[ReturnInd]
 --          ,[LongDescription]
 --          ,[SourceCreatedDate]
 --          ,[SourceModifiedDate]
 --          ,[IsRailTicketInd]
 --          ,[FTOT]
 --          ,[LTOT]
 --          ,[IsSeasonTicketInd]
 --          ,[SeasonType]
 --          ,[StartDate]
 --          ,[EndDate]
 --          ,[TicketValidityID]
 --          ,[UTSCode]
 --          ,[Time_Restriction]
 --          ,[RSPAdvice]
 --          ,[IDMSDisplayName]
 --          ,[IDMSPrintingName]
 --          ,[IsIDMSAttendedTISInd]
 --          ,[IsIDMSUnattendedTISInd]
 --          ,[IDMSAdviceMessage]
 --          ,[Format]
 --          ,[IsNRESApplicableAllTOCsInd]
 --          ,[NRESFareCategory]
 --          ,[IsNRESIncludesGroupSaveInd]
 --          ,[NRESName]
 --          ,[NRESDescription]
 --          ,[NRESBreaksJourney]
 --          ,[NRESConditionsInfo]
 --          ,[NRESAvailabilityInfo]
 --          ,[NRESRetailingInfo]
 --          ,[NRESBookingDeadlinesInfo]
 --          ,[NRESChangesTRVLPlansInfo]
 --          ,[NRESRefundsInfo]
 --          ,[NRESDiscountsInfo]
 --          ,[ExtReference]
	--	   ,[InformationSourceID])
 --   SELECT  CASE WHEN a.IDMS_Display_Name IS NULL THEN a.Short_Description ELSE a.IDMS_Display_Name END
	--       ,a.Description
 --          ,a.Short_Description
	--	   ,GETDATE()
	--	   ,@userid
	--	   ,GETDATE()
	--	   ,@userid
	--	   ,CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	--	   ,NULL
	--	   ,a.FTOT
	--	   ,b.TicketClassID
	--	   ,c.TicketTypeID
	--	   ,NULL
	--	   ,NULL
	--	   ,CASE a.Ticket_Type WHEN	'R' THEN 1 ELSE 0 END
	--	   ,a.[IDMS_Printing_Name]
 --          ,a.[Date_Created]
 --          ,a.[Date_Modified]
	--	   ,1
	--       ,a.FTOT
 --          ,a.LTOT
	--       ,a.Is_Season_Ticket
 --          ,a.Season_Type
 --          ,a.Start_Date
 --          ,a.End_Date
	--	   ,d.TicketValidityID
 --          ,a.UTS_Code
	--	   ,a.Time_Restriction
	--	   ,a.RSP_Advice
	--	   ,a.IDMS_Display_Name
 --          ,a.IDMS_Printing_Name
 --          ,a.IDMS_Attended_TIS
 --          ,a.IDMS_Unattended_TIS
 --          ,a.IDMS_Advice_Message
	--	   ,a.Format
 --          ,a.NRES_Applicable_All_TOCs
 --          ,a.NRES_Fare_Category
 --          ,a.NRES_Includes_GroupSave
 --          ,a.NRES_Name
 --          ,a.NRES_Description
 --          ,a.NRES_Breaks_Journey
 --          ,a.NRES_Conditions_Info
 --          ,a.NRES_Availability_Info
 --          ,a.NRES_Retailing_Info
 --          ,a.NRES_Booking_Deadlines_Info
 --          ,a.NRES_Changes_TRVL_Plans_Info
 --          ,a.NRES_Refunds_Info
 --          ,a.NRES_Discounts_Info
 --          ,CAST(a.[ID] AS NVARCHAR(256))
	--	   ,@informationsourceid
	--FROM CTE_CBE_TicketType                     a
	--LEFT JOIN [Reference].[TicketClass]         b ON b.ExtReference = CAST(a.Ticket_Class AS NVARCHAR(256))
	--LEFT JOIN [Reference].[TicketType]          c ON c.ExtReference = CAST(a.Ticket_Type AS NVARCHAR(256))
 --   LEFT JOIN [Reference].[TicketValidity]      d ON a.[Ticket_Validity_Code] = d.Code
	--LEFT JOIN [Reference].[Product]             e ON a.FTOT = e.TicketTypeCode
	--                                              AND e.ArchivedInd = 0
	--											  AND e.InformationSourceID = @informationsourceid
	--WHERE e.ProductID IS NULL
 --   AND   a.Ranking = 1

	----Set ProcessedInd = 1 on CBE_TicketType for those added

	--UPDATE a
	--SET    ProcessedInd = 1
	--      ,[LastModifiedDateETL] = GETDATE()
	--FROM [PreProcessing].[CBE_TicketType] a
	--INNER JOIN [Reference].[Product] b ON a.FTOT = b.FTOT
	--                                   AND a.LTOT = b.LTOT
	--WHERE a.ProcessedInd = 0
	--AND   a.DataImportDetailID = @dataimportdetailid
	--AND   b.InformationSourceID = @informationsourceid

	----Log processing information

 --   SELECT @now = GETDATE()

	--SELECT @successcountimport = COUNT(1)
 --   FROM   [PreProcessing].[CBE_TicketType]
	--WHERE  ProcessedInd = 1
	--AND    DataImportDetailID = @dataimportdetailid

	--SELECT @errorcountimport = COUNT(1)
	--FROM  [PreProcessing].[CBE_TicketType]
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