
CREATE PROCEDURE [PreProcessing].[CBE_TicketValidity_Insert]
(
    @userid         INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

 --   DECLARE @informationsourceid    INTEGER
	--DECLARE @now                    DATETIME

	--DECLARE @spname                 NVARCHAR(256)
	--DECLARE @logmessage             NVARCHAR(MAX)
	--DECLARE @recordcount            INTEGER       = 0
	--DECLARE @successcountimport     INTEGER       = 0
	--DECLARE @errorcountimport       INTEGER       = 0
	--DECLARE @logtimingidnew         INTEGER

	--SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

 --   SELECT @now = GETDATE()


 --   --Get configuration settings

	--SELECT @informationsourceid = InformationSourceID
 --   FROM [Reference].[InformationSource]
 --   WHERE Name = 'CBE'

	--IF @informationsourceid IS NULL
 --   BEGIN
	--    SET @logmessage = 'No or invalid information source: ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') 
	    
	--    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	--                                          @logsource       = @spname,
	--		    							  @logmessage      = @logmessage,
	--			    						  @logmessagelevel = 'ERROR',
	--					    				  @messagetypecd   = 'Invalid Lookup'
 --       RETURN
 --   END	

	----Log start time--

	--EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	--                                     @logsource      = @spname,
	--									 @logtimingidnew = @logtimingidnew OUTPUT

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

 --   --Updates to existing Ticket Validity
 --   UPDATE [Reference].[TicketValidity]
 --   SET [Name] = b.Description
 --      ,[Description] = b.Description
 --     ,[LastModifiedDate] = GETDATE()
 --     ,[LastModifiedBy] = @userid
 --     ,[ArchivedInd] = CASE WHEN b.Is_Active = 0 THEN 1 ELSE 0 END
 --     ,[InformationSourceID] = @informationsourceid
 --     ,[Code] = b.Code
 --     ,[OutboundValidity] = [Outbound_Validity]
 --     ,[ReturnValidity] = [Return_Validity]
 --     ,[StartDate] = [Start_Date]
 --     ,[EndDate] = [End_Date]
 --     ,[ReturnAfter] = [Return_After]
 --     ,[IsBreakOutbound] = [Is_Break_Outbound]
 --     ,[IsBreakReturn] = [Is_Break_Return]
 --     ,[OutboundDescription] = [Outbound_Description]
 --     ,[ReturnDescription] = [Return_Description]
 --     ,[SourceModifiedDate] = [Date_Modified]
 --   FROM [Reference].[TicketValidity] a
	--INNER JOIN [PreProcessing].[CBE_TicketValidity] b ON a.Code = b.Code
 --   WHERE b.ProcessedInd = 0
	--AND   b.DataImportDetailID = @dataimportdetailid
	
	----Set ProcessedInd = 1 on CBE_TicketValidity for those updated

 --   UPDATE a
	--SET [ProcessedInd] = 1
	--   ,[LastModifiedDateETL] = GETDATE()
 --   FROM [PreProcessing].[CBE_TicketValidity] a
	--INNER JOIN [Reference].[TicketValidity] b ON a.Code = b.Code
	--WHERE a.ProcessedInd = 0
	--AND   a.DataImportDetailID = @dataimportdetailid

	----Add new Ticket Validities

	--;WITH CTE_CBE_TicketValidity AS (
 --           SELECT [CBE_TicketValidityID]
 --                 ,[ID]
 --                 ,[Code]
 --                 ,[Outbound_Validity]
 --                 ,[Return_Validity]
 --                 ,[Start_Date]
 --                 ,[End_Date]
 --                 ,[Return_After]
 --                 ,[Is_Break_Outbound]
 --                 ,[Is_Break_Return]
 --                 ,[Description]
 --                 ,[Outbound_Description]
 --                 ,[Return_Description]
 --                 ,[Date_Created]
 --                 ,[Date_Modified]
 --                 ,[Is_Active]
 --                 ,[CreatedDateETL]
 --                 ,[LastModifiedDateETL]
 --                 ,[ProcessedInd]
 --                 ,[DataImportDetailID]
 --		          ,ROW_NUMBER() OVER (partition by [Code]
 --                                     ORDER BY Date_Modified DESC
	--								          ,CBE_TicketValidityID DESC) RANKING
 --                 FROM [PreProcessing].[CBE_TicketValidity]
	--			  WHERE  DataImportDetailID = @dataimportdetailid
	--              AND    ProcessedInd = 0)

 --   INSERT INTO [Reference].[TicketValidity]
 --          ([Name]
 --          ,[Description]
 --          ,[CreatedDate]
 --          ,[CreatedBy]
 --          ,[LastModifiedDate]
 --          ,[LastModifiedBy]
 --          ,[ArchivedInd]
 --          ,[InformationSourceID]
 --          ,[Code]
 --          ,[OutboundValidity]
 --          ,[ReturnValidity]
 --          ,[StartDate]
 --          ,[EndDate]
 --          ,[ReturnAfter]
 --          ,[IsBreakOutbound]
 --          ,[IsBreakReturn]
 --          ,[OutboundDescription]
 --          ,[ReturnDescription]
 --          ,[SourceCreatedDate]
 --          ,[SourceModifiedDate]
 --          ,[ExtReference])
 --   SELECT a.Description
	--      ,a.Description
	--	  ,GETDATE()
	--	  ,@userid
	--	  ,GETDATE()
	--	  ,@userid
	--	  ,CASE WHEN a.Is_Active = 0 THEN 1 ELSE 0 END
	--	  ,@informationsourceid
	--	  ,a.Code
	--	  ,a.[Outbound_Validity]
 --         ,a.[Return_Validity]
 --         ,a.[Start_Date]
 --         ,a.[End_Date]
 --         ,a.[Return_After]
 --         ,a.[Is_Break_Outbound]
 --         ,a.[Is_Break_Return]
 --         ,a.[Outbound_Description]
 --         ,a.[Return_Description]
 --         ,a.[Date_Created]
 --         ,a.[Date_Modified]
	--	  ,CAST(a.ID AS NVARCHAR(256))
 --   FROM CTE_CBE_TicketValidity a
	--LEFT JOIN [Reference].[TicketValidity] b ON a.Code = b.Code
	--WHERE b.TicketValidityID IS NULL
	--AND   a.RANKING = 1

	----Set ProcessedInd = 1 on CBE_TicketValidity for those added

	--UPDATE a
	--SET [ProcessedInd] = 1
	--   ,[LastModifiedDateETL] = GETDATE()
 --   FROM [PreProcessing].[CBE_TicketValidity] a
	--INNER JOIN [Reference].[TicketValidity] b ON a.Code = b.Code
	--WHERE a.ProcessedInd = 0
	--AND   a.DataImportDetailID = @dataimportdetailid

	----Log processing information

 --   SELECT @now = GETDATE()

	--SELECT @successcountimport = COUNT(1)
 --   FROM   [PreProcessing].[CBE_TicketValidity]
	--WHERE  ProcessedInd = 1
	--AND    DataImportDetailID = @dataimportdetailid

	--SELECT @errorcountimport = COUNT(1)
	--FROM  [PreProcessing].[CBE_TicketValidity]
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

	--EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	--                                     @logsource      = @spname,
	--									 @logtimingid    = @logtimingidnew,
	--									 @recordcount    = @recordcount,
	--									 @logtimingidnew = @logtimingidnew OUTPUT    
	RETURN
END