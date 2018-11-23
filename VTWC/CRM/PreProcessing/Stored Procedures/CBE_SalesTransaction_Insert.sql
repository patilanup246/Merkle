
CREATE PROCEDURE [PreProcessing].[CBE_SalesTransaction_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid      INTEGER

	DECLARE @now                      DATETIME
	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)
	DECLARE @successcountimport       INTEGER = 0
	DECLARE @errorcountimport         INTEGER = 0

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
	    SET @logmessage = 'No or invalid information source: ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') 
	    
	    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	                                          @logsource       = @spname,
			    							  @logmessage      = @logmessage,
				    						  @logmessagelevel = 'ERROR',
						    				  @messagetypecd   = 'Invalid Lookup'
        RETURN
    END	

	--CBE allows mulitple loyalty schemes per provider to support validation. Create temp table to manage support this

	SELECT a.LoyaltyProgrammeTypeID
		  ,b.Value AS SchemeName
	INTO #tmp_LoyaltyProgrammeType
    FROM Reference.LoyaltyProgrammeType a
    CROSS APPLY [Staging].[SplitStringToTable] (a.ExtReference,',') AS b

    --Update fulfilement date for existing sales transaction records and set processedind = 1 for these matches in CBE_SalesTransaction
	--Use CTE to avoid duplicates in the data from CBE

	;WITH CBE_SalesTransactions AS (
                  SELECT TOP 999999999
						 a.CBE_SalesTransactionID
                        ,a.[ID]
                        ,a.[CD_ID]
                        ,a.[Date_Created]
                        ,a.[Date_Modified]
                        ,a.[Retail_Channel_Code]
                        ,a.[Transaction_Date_Time]
                        ,a.[Sales_Amount]
                        ,a.[Selling_NLC]
                        ,a.[Loyalty_Card_Number]
                        ,a.[Scheme_Name]
                        ,a.[TOD_Reference]
                        ,a.[Fulfilment_Type]
                        ,a.[Number_of_Adults]
                        ,a.[Number_of_Children]
                        ,a.[Date_Created_Fulfilment]
                        ,a.[SalesAmountNotRail]
                        ,a.[SalesAmountRail]
                        ,a.[Sales_Transaction_Number]
                        ,a.[Booking_Source]
                        ,a.[CreatedDateETL]
	                    ,ROW_NUMBER() OVER (partition by [ID] ORDER BY a.[Date_Modified] DESC
						                                             , a.[CreatedDateETL] DESC) RANKING
                 FROM  [PreProcessing].[CBE_SalesTransaction] a WITH (NOLOCK)
				 INNER JOIN [Staging].[STG_SalesTransaction]  b WITH (NOLOCK) ON  b.ExtReference = CAST(a.ID AS NVARCHAR(256))
				                                                AND b.InformationSourceID = @informationsourceid
				 WHERE  a.DataImportDetailID = @dataimportdetailid
	             AND    a.ProcessedInd = 0)

	UPDATE a
	SET    FulfilmentDate     = b.Date_Created_Fulfilment
	      ,FulfilmentMethodID = c.FulfilmentMethodID
	      ,LastModifiedDate   = GETDATE()
    FROM Staging.STG_SalesTransaction a
	INNER JOIN  CBE_SalesTransactions      b ON  a.ExtReference        = CAST(b.ID AS NVARCHAR(256))
	                                         AND a.InformationSourceID = @informationsourceid
	INNER JOIN  Reference.FulfilmentMethod c ON  c.ExtReference        = b.Fulfilment_Type
											 AND c.InformationSourceID = @informationsourceid
											 AND a.SalesTransactionDate BETWEEN c.ValidityStartDate AND c.ValidityEndDate
   
	UPDATE b
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM Staging.STG_SalesTransaction a
	INNER JOIN  PreProcessing.CBE_SalesTransaction b ON a.ExtReference = CAST(b.ID AS NVARCHAR(256))
	                                                 AND a.InformationSourceID = @informationsourceid
													 AND b.DataImportDetailID = @dataimportdetailid
													 AND b.ProcessedInd = 0
	SELECT @recordcount = @@ROWCOUNT

	--Add new sales transaction records where processed = 0
	--Use CTE to elminiate multiple records for the same transaction; use the last one provided from CBE

	;WITH CTE_CBE_SalesTransaction AS (
                  SELECT TOP 999999999
						 CBE_SalesTransactionID
                        ,[ID]
                        ,[CD_ID]
                        ,[Date_Created]
                        ,[Date_Modified]
                        ,[Retail_Channel_Code]
                        ,[Transaction_Date_Time]
                        ,[Sales_Amount]
                        ,[Selling_NLC]
                        ,[Loyalty_Card_Number]
                        ,[Scheme_Name]
                        ,[TOD_Reference]
                        ,[Fulfilment_Type]
                        ,[Number_of_Adults]
                        ,[Number_of_Children]
                        ,[Date_Created_Fulfilment]
                        ,[SalesAmountNotRail]
                        ,[SalesAmountRail]
                        ,[Sales_Transaction_Number]
                        ,[Booking_Source]
                        ,[CreatedDateETL]
	                    ,ROW_NUMBER() OVER (partition by [ID] ORDER BY [Date_Modified] DESC, [CreatedDateETL] DESC) RANKING
                 FROM  [PreProcessing].[CBE_SalesTransaction] WITH (NOLOCK)
				 WHERE  DataImportDetailID = @dataimportdetailid
	             AND    ProcessedInd = 0)

    INSERT INTO [Staging].[STG_SalesTransaction]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
		   ,[SourceCreatedDate]
		   ,[SourceModifiedDate]
           ,[SalesTransactionDate]
           ,[SalesAmountTotal]
           ,[LoyaltyReference]
           ,[RetailChannelID]
           ,[LocationID]
           ,[CustomerID]
           ,[IndividualID]
           ,[ExtReference]
           ,[InformationSourceID]
		   ,[BookingReference]
		   ,[FulfilmentMethodID]
		   ,[NumberofAdults]
		   ,[NumberofChildren]
		   ,[FulfilmentDate]
		   ,[SalesAmountNotRail]
		   ,[SalesAmountRail]
		   ,[BookingReferenceLong]
		   ,[BookingSourceCd]
		   ,[LoyaltySchemeName]
		   ,[LoyaltyProgrammeTypeID]
		   ,[SalesTransactionNumber])
    SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,a.[Date_Created]
		   ,a.[Date_Modified]
           ,a.[Transaction_Date_Time]
           ,a.[Sales_Amount]
           ,a.[Loyalty_Card_Number]
           ,c.RetailChannelID
           ,f.LocationID
           ,b.CustomerID
           ,NULL
           ,CAST(a.ID AS NVARCHAR(256))
           ,@informationsourceid
		   ,a.[TOD_Reference]
		   ,d.[FulfilmentMethodID]
		   ,a.[Number_of_Adults]
		   ,a.[Number_of_Children]
		   ,a.[Date_Created_Fulfilment]
		   ,a.[SalesAmountNotRail]
		   ,a.[SalesAmountRail]
		   ,NULL
		   ,a.[Booking_Source]
		   ,a.[Scheme_Name]
		   ,g.[LoyaltyProgrammeTypeID]
		   ,a.[Sales_Transaction_Number]
    FROM   CTE_CBE_SalesTransaction a WITH (NOLOCK)
	       INNER JOIN Staging.STG_KeyMapping         b WITH (NOLOCK) ON  a.[CD_ID] = b.[CBECustomerID]
		   	                                           AND b.CustomerID IS NOT NULL
		   INNER JOIN Staging.STG_Customer           h WITH (NOLOCK) ON  h.[CustomerID] = b.[CustomerID]
		                                               AND h.IsPersonInd = 1
		   LEFT  JOIN Reference.RetailChannel        c WITH (NOLOCK) ON  a.[Retail_Channel_Code] = c.[Code]
		                                               AND a.Transaction_Date_Time BETWEEN c.ValidityStartDate AND c.ValidityEndDate
													   AND c.InformationSourceID = @informationsourceid
		   LEFT  JOIN Reference.FulfilmentMethod     d WITH (NOLOCK) ON  a.[Fulfilment_Type] = d.[ExtReference]
													   AND d.InformationSourceID = @informationsourceid
													   AND a.Transaction_Date_Time BETWEEN d.ValidityStartDate AND d.ValidityEndDate
		   LEFT  JOIN Reference.Location_NLCCode_VW  f WITH (NOLOCK) ON  a.[Selling_NLC] = f.NLCCode
		   LEFT  JOIN #tmp_LoyaltyProgrammeType      g WITH (NOLOCK) ON  g.SchemeName = a.[Scheme_Name]
		   LEFT  JOIN Staging.STG_SalesTransaction   e WITH (NOLOCK) ON  e.ExtReference = CAST(a.ID AS NVARCHAR(256))

	WHERE  a.RANKING = 1
	AND    e.ExtReference IS NULL

	--Update CBE_SalesTransaction, set processedind = 1

	UPDATE b
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM Staging.STG_SalesTransaction a
	INNER JOIN  PreProcessing.CBE_SalesTransaction b ON a.ExtReference = CAST(b.ID AS NVARCHAR(256))
	                                                 AND a.InformationSourceID = @informationsourceid
													 AND b.DataImportDetailID = @dataimportdetailid
													 AND b.ProcessedInd = 0

	SELECT @recordcount = @recordcount + @@ROWCOUNT

	--Set minimum sales transaction date for Date first purchase in STG_Customer

	UPDATE a
    SET DateFirstPurchase = b.LatestDate
	   ,LastModifiedDate  = GETDATE()
    FROM [Staging].[STG_Customer] a
    INNER JOIN (SELECT CustomerID,
                       MIN([SalesTransactionDate]) AS LatestDate
                FROM   [Staging].[STG_SalesTransaction]
			    GROUP  BY CustomerID) b
            ON  a.CustomerID = b.CustomerID
    WHERE a.DateFirstPurchase IS NULL

	--Set maximum sales transaction date for Date Last Purchased in STG_Customer

	UPDATE a
    SET DateLastPurchase = b.LatestDate
	   ,LastModifiedDate = GETDATE()
    FROM [Staging].[STG_Customer] a
    INNER JOIN (SELECT CustomerID,
                       MAX([SalesTransactionDate]) AS LatestDate
                FROM   [Staging].[STG_SalesTransaction]
			    GROUP  BY CustomerID) b
            ON  a.CustomerID = b.CustomerID
    WHERE a.DateLastPurchase<b.LatestDate

	--Run CVISalesTransaction proc to insert new Reason for Travel questions into Staging.STG_CVISalesTransaction Table
	
	EXEC [PreProcessing].[CBE_CVISalesTransaction_Insert] @dataimportdetailid = @dataimportdetailid
	
	--logging
	
	SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_SalesTransaction WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_SalesTransaction WITH (NOLOCK)
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid
	
	
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