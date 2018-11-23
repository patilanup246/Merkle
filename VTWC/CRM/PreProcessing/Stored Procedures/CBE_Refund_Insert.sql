

CREATE PROCEDURE [PreProcessing].[CBE_Refund_Insert]
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

	;WITH CTE_CBE_Refunds AS (
	              SELECT TOP 999999999
						 [CBE_RefundID]
                        ,[ID]
                        ,[ST_ID]
                        ,[Refund_Number]
                        ,[Retail_Channel_Code]
                        ,[Refund_Date]
                        ,[Reason_For_Refund]
                        ,[Refund_Decision_Code]
                        ,[Admin_Charge]
                        ,[Admin_Charge_Net_Value]
                        ,[Admin_Charge_Tax_Code]
                        ,[Admin_Charge_Tax_Rate]
                        ,[Admin_Charge_Tax_Amount]
                        ,[Refund_Amount]
                        ,[Net_Value]
                        ,[Tax_Code]
                        ,[Tax_Rate]
                        ,[Tax_Amount]
                        ,[Is_Foreign]
                        ,[Tickets_Cancelled_Date]
                        ,[Date_Created]
                        ,[Date_Modified]
                        ,[Is_Active]
                        ,[Current_Stat_ID]
                        ,[TOD_Reference]
						,ROW_NUMBER() OVER (partition by [ID]
														 ORDER BY [Date_Modified] DESC
														         ,[CBE_RefundID] DESC) RANKING
                  FROM   [PreProcessing].[CBE_Refund] WITH (NOLOCK)
				  WHERE  DataImportDetailID = @dataimportdetailid
	              AND    ProcessedInd = 0)


    --Start Processing

    INSERT INTO [Staging].[STG_Refund]
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
           ,[RefundNumber]
           ,[RetailChannelID]
           ,[RefundDate]
           ,[RefundReasonCodeID]
           ,[RefundDecisionCodeID]
           ,[RefundAmount]
           ,[NetAmount]
           ,[TaxCd]
           ,[TaxRate]
           ,[TaxAmout]
           ,[AdminChargeAmount]
           ,[AdminChargeNetAmount]
           ,[AdminChargeTaxCd]
           ,[AdminChargeTaxRate]
		   ,[AdminChargeTaxAmount]
           ,[IsForeignInd]
           ,[TicketsCancelledDate]
           ,[BookingReference]
           ,[ExtReference])
    SELECT  GETDATE()
           ,@userid
		   ,GETDATE()
		   ,@userid
		   ,0

		   ,[Date_Created]
           ,[Date_Modified]
		   ,@informationsourceid
		   ,b.CustomerID
		   ,b.SalesTransactionID
		   ,a.[Refund_Number]
		   ,c.RetailChannelID
		   ,a.[Refund_Date]
		   ,d.RefundReasonCodeID
		   ,e.RefundDecisionCodeID
		   ,a.[Refund_Amount]
		   ,a.[Net_Value]
		   ,a.[Tax_Code]
		   ,a.[Tax_Rate]
		   ,a.[Tax_Amount]
		   ,a.[Admin_Charge]
		   ,a.[Admin_Charge_Net_Value]
		   ,a.[Admin_Charge_Tax_Code]
		   ,a.[Admin_Charge_Tax_Rate]
		   ,a.[Admin_Charge_Tax_Amount]
		   ,a.[Is_Foreign]
		   ,a.[Tickets_Cancelled_Date]
		   ,a.[TOD_Reference]
		   ,'ID='    + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
           ',ST_ID=' + ISNULL(CAST(a.ST_ID AS NVARCHAR(256)),'NULL')
    FROM CTE_CBE_Refunds a WITH (NOLOCK)
	INNER JOIN [Staging].[STG_SalesTransaction] b WITH (NOLOCK) ON CAST(a.ST_ID AS NVARCHAR(256)) = b.ExtReference
	LEFT JOIN [Reference].[RetailChannel]       c WITH (NOLOCK) ON a.[Retail_Channel_Code]  = c.Code
	                                                 AND b.SalesTransactionDate BETWEEN c.ValidityStartDate AND c.ValidityEndDate
													 AND c.InformationSourceID = @informationsourceid
	LEFT JOIN [Reference].[RefundReasonCode]    d WITH (NOLOCK) ON a.[Reason_For_Refund]    = d.ExtReference
	                                             AND d.InformationSourceID    = @informationsourceid
												 AND a.Refund_Date BETWEEN d.ValidityStartDate AND d.ValidityEndDate
    LEFT JOIN [Reference].[RefundDecisionCode]  e WITH (NOLOCK) ON a.[Refund_Decision_Code] = e.ExtReference
	                                              AND a.Refund_Date BETWEEN e.ValidityStartDate AND e.ValidityEndDate
	                                             AND e.InformationSourceID    = @informationsourceid
  	LEFT JOIN [Staging].[STG_Refund]            f WITH (NOLOCK) ON 'ID='     + ISNULL(CAST(a.ID AS NVARCHAR(256)),'NULL') + 
                                                     ',ST_ID=' + ISNULL(CAST(a.ST_ID AS NVARCHAR(256)),'NULL')
											         = f.ExtReference
                                                  AND f.InformationSourceID = @informationsourceid
	WHERE f.RefundID IS NULL
	AND   a.RANKING = 1
	
	--Update process recrds

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_Refund] a
	INNER JOIN [PreProcessing].[CBE_Refund] b ON 'ID='     + ISNULL(CAST(b.ID AS NVARCHAR(256)),'NULL') + 
                                                 ',ST_ID=' + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL')
											     = a.ExtReference
	                                          AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[CBE_Refund] WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[CBE_Refund] WITH (NOLOCK)
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