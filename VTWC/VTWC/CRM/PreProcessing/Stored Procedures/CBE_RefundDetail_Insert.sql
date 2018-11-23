CREATE PROCEDURE [PreProcessing].[CBE_RefundDetail_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER

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
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL
												
    --Get configuration settings

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'CBE'

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL')
		
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

	--Use CTE to avoid duplicates in the data from CBE

	;WITH CTE_CBE_RefundDetails AS (
	              SELECT TOP 999999999
						 [CBE_RefundDetailID]
                        ,[ID]
                        ,[RFND_ID]
                        ,[RCOD_ID]
                        ,[Ticket_Number]
                        ,[Origin_NLC]
                        ,[Destination_NLC]
                        ,[Route_Code]
                        ,[UTS_Zone]
                        ,[Primary_TOC]
                        ,[Is_Adult]
                        ,[FTOT]
                        ,[Ticket_Type_Description]
                        ,[Ticket_Category]
                        ,[Ticket_Restriction_Code]
                        ,[Ticket_Origin_NLC]
                        ,[Ticket_Destination_Nlc]
                        ,[Departure_Datetime]
                        ,[Season_Start_Date]
                        ,[Season_Validity]
                        ,[Fare]
                        ,[MOP_Indicator]
                        ,[Issuing_NLC]
                        ,[Window_Number]
                        ,[Mods_Number_Name]
                        ,[Reason_For_Refund]
                        ,[Refund_Category]
                        ,[Stdr_Date]
                        ,[Stdr_Direction]
                        ,[Refund_Type_Code]
                        ,[Season_Refund_From]
                        ,[Number_Of_Days]
                        ,[Refund_Value]
                        ,[Refund_Status]
                        ,[Reason_Code]
                        ,[Adjustment_Value]
                        ,[Refund_Amount]
                        ,[Is_Plusbus_Origin]
                        ,[Plusbus_Station_NLC]
                        ,[Plusbus_NLC]
                        ,[Is_Travelcard]
                        ,[Is_Season]
                        ,[Reissue_Type]
                        ,[Date_Created]
                        ,[Date_Modified]
                        ,[Is_Active]
                        ,[Is_Carpark]
                        ,[Refund_Assessment_Status]
                        ,[Pass_Fare_ID]
						,ROW_NUMBER() OVER (partition by [ID]
						                                ,[RFND_ID]
														,[RCOD_ID]
														,[Pass_Fare_ID]
														 ORDER BY [Date_Modified] DESC
														         ,[CBE_RefundDetailID] DESC) RANKING
                  FROM   [PreProcessing].[CBE_RefundDetail] WITH (NOLOCK)
				  WHERE  DataImportDetailID = @dataimportdetailid
	              AND    ProcessedInd = 0)


    --Start Processing

    INSERT INTO [Staging].[STG_RefundDetail]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[InformationSourceID]
           ,[CustomerID]
           ,[SalesTransactionID]
           ,[SalesDetailID]
           ,[RefundID]
           ,[ProductID]
           ,[TicketNumber]
           ,[RefundAmount]
           ,[RefundValue]
           ,[RefundReasonCodeID]
           ,[RefundTypeID]
           ,[RefundCategoryCd]
           ,[IsSeasonInd]
           ,[SeasonStartDate]
           ,[SeasonValidity]
           ,[SeasonRefundFrom]
           ,[NumberOfDays]
           ,[RefundStatusCd]
           ,[AdjustmentAmount]
           ,[IsPlusbusOriginInd]
           ,[IsTravelcardInd]
           ,[IsCarParkInd]
           ,[LocationIDOrigin]
           ,[LocationIDDestination]
           ,[LocationIDOriginTicket]
           ,[LocationIDDestinationTicket]
           ,[SalesTransactionDeplayRepayDate]
           ,[SalesTransactionDeplayRepayDirection]
           ,[ReissueTypeCd]
           ,[RefundReason]
           ,[RefundAssessmentStatusCd]
           ,[LocationIDPlusbusStation]
           ,[LocationIDPlusbus]
           ,[RouteCode]
           ,[UTSZone]
           ,[TOCIDPrimary]
           ,[IsAdultInd]
           ,[TicketRestrictionCode]
           ,[DepartureDatetime]
           ,[FareAmount]
           ,[ExtReference])
    SELECT  GETDATE()
           ,@userid
		   ,GETDATE()
		   ,@userid
		   ,0
		   ,a.[Date_Created]
           ,a.[Date_Modified]
		   ,@informationsourceid
		   ,c.CustomerID
		   ,c.SalesTransactionID
		   ,d.SalesDetailID
		   ,b.RefundID
		   ,e.ProductID
		   ,a.[Ticket_Number]
		   ,a.[Refund_Amount]
		   ,a.Refund_Value
		   ,f.RefundReasonCodeID
		   ,g.RefundTypeID
		   ,a.[Refund_Category]
		   ,a.[Is_Season]
		   ,a.[Season_Start_Date]
		   ,a.[Season_Validity]
		   ,a.[Season_Refund_From]
		   ,a.[Number_Of_Days]
		   ,a.[Refund_Status]
		   ,a.[Adjustment_Value]
		   ,a.[Is_Plusbus_Origin]
		   ,a.[Is_Travelcard]
		   ,a.[Is_Carpark]
		   ,h.LocationID
		   ,i.LocationID
		   ,j.LocationID
		   ,k.LocationID
		   ,a.[Stdr_Date]
		   ,a.[Stdr_Direction]
		   ,a.[Reissue_Type]
		   ,a.[Reason_For_Refund]
		   ,a.[Refund_Assessment_Status]
		   ,l.LocationID
		   ,m.LocationID
		   ,a.[Route_Code]
		   ,a.[UTS_Zone]
		   ,n.TOCID
		   ,a.[Is_Adult]
		   ,a.[Ticket_Restriction_Code]
		   ,a.Departure_Datetime
           ,a.[Fare]
		   ,'ID='          + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
           ',RFND_ID='     + ISNULL(CAST(a.RFND_ID AS NVARCHAR(256)),'NULL') + 
		   ',RCOD_ID='     + ISNULL(CAST(a.RCOD_ID AS NVARCHAR(256)),'NULL') + 
		   ',Pass_Fare_ID=' + ISNULL(CAST(a.Pass_Fare_ID AS NVARCHAR(256)),'NULL')
    FROM CTE_CBE_RefundDetails a WITH (NOLOCK)
	INNER JOIN [Staging].[STG_Refund]            b WITH (NOLOCK) ON SUBSTRING(b.ExtReference,CHARINDEX('ID',b.ExtReference,1)+LEN('ID='),
                                                        CHARINDEX('ST_ID',b.ExtReference,1)-CHARINDEX('ID',b.ExtReference,1)-LEN(',ID='))
												     = CAST(a.[RFND_ID] AS nvarchar(256))
                                                 AND b.InformationSourceID = @informationsourceid
	INNER JOIN [Staging].[STG_SalesTransaction]  c WITH (NOLOCK) ON b.SalesTransactionID = c.SalesTransactionID
	INNER JOIN [Staging].[STG_SalesDetail]       d WITH (NOLOCK) ON d.SalesTransactionID = c.SalesTransactionID
	                                              AND SUBSTRING(d.ExtReference,CHARINDEX('PF_ID',d.ExtReference,1)+LEN('PF_ID='),
                                                         CHARINDEX('TKT_ID',d.ExtReference,1)-CHARINDEX('PF_ID',d.ExtReference,1)-LEN(',PF_ID='))
												     = CAST(a.[Pass_Fare_ID] AS nvarchar(256))
												  AND  d.InformationSourceID = @informationsourceid
    INNER JOIN [Reference].[Product]             e WITH (NOLOCK) ON e.FTOT = a.FTOT
	                                              AND e.InformationSourceID = @informationsourceid
												  AND e.ArchivedInd = 0
	LEFT JOIN  [Reference].[RefundReasonCode]    f WITH (NOLOCK) ON a.[Reason_For_Refund] = d.ExtReference
	                                              AND f.InformationSourceID = @informationsourceid
												  AND b.RefundDate BETWEEN f.ValidityStartDate AND f.ValidityEndDate
    LEFT JOIN  [Reference].[RefundType]          g WITH (NOLOCK) ON a.Refund_Type_Code    = g.ExtReference
	                                              AND g.InformationSourceID = @informationsourceid
												  AND b.RefundDate BETWEEN g.ValidityStartDate AND g.ValidityEndDate
    LEFT JOIN  [Reference].[Location_NLCCode_VW] h WITH (NOLOCK) ON h.NLCCode   = a.Origin_NLC
	LEFT JOIN  [Reference].[Location_NLCCode_VW] i WITH (NOLOCK) ON i.NLCCode   = a.Destination_NLC
	LEFT JOIN  [Reference].[Location_NLCCode_VW] j WITH (NOLOCK) ON j.NLCCode   = a.Ticket_Origin_NLC
	LEFT JOIN  [Reference].[Location_NLCCode_VW] k WITH (NOLOCK) ON k.NLCCode   = a.Ticket_Destination_NLC
	LEFT JOIN  [Reference].[Location_NLCCode_VW] l WITH (NOLOCK) ON l.NLCCode   = a.Plusbus_Station_NLC
	LEFT JOIN  [Reference].[Location_NLCCode_VW] m WITH (NOLOCK) ON m.NLCCode   = a.Plusbus_NLC
	LEFT JOIN  [Reference].[TOC]                 n WITH (NOLOCK) ON n.ShortCode = a.Primary_TOC
	LEFT JOIN  [Staging].[STG_RefundDetail]      o WITH (NOLOCK) ON 'ID='           + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
                                                      ',RFND_ID='     + ISNULL(CAST(a.RFND_ID AS NVARCHAR(256)),'NULL') + 
		                                              ',RCOD_ID='     + ISNULL(CAST(a.RCOD_ID AS NVARCHAR(256)),'NULL') + 
		                                              ',Pass_Fare_ID=' + ISNULL(CAST(a.Pass_Fare_ID AS NVARCHAR(256)),'NULL')
                                                     = o.ExtReference
                                                  AND o.InformationSourceID = @informationsourceid
	WHERE o.RefundDetailID IS NULL
	AND   a.RANKING = 1
	
	--Update process records

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_RefundDetail] a
	INNER JOIN [PreProcessing].[CBE_RefundDetail] b ON 'ID='           + ISNULL(CAST(b.ID AS NVARCHAR(256)),'NULL') + 
                                                      ',RFND_ID='      + ISNULL(CAST(b.RFND_ID AS NVARCHAR(256)),'NULL') + 
		                                              ',RCOD_ID='      + ISNULL(CAST(b.RCOD_ID AS NVARCHAR(256)),'NULL') + 
		                                              ',Pass_Fare_ID=' + ISNULL(CAST(b.Pass_Fare_ID AS NVARCHAR(256)),'NULL')
                                                     = a.ExtReference
                                                  AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[CBE_RefundDetail] WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[CBE_RefundDetail] WITH (NOLOCK)
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