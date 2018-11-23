CREATE PROCEDURE [PreProcessing].[CBE_SalesTransaction_TVM_Insert]
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
	DECLARE @recordcount              INTEGER = 0
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

	--Create temporary table with location information to aid performance

    SELECT [LocationID]
          ,[LocationIDParent]
          ,[Name]
          ,[Description]
          ,[TIPLOC]
          ,[NLCCode]
          ,[CRSCode]
          ,[CATEType]
          ,[3AlphaCode]
          ,[3AlphaCodeSub]
          ,[Longitude]
          ,[Latitude]
          ,[Northing]
          ,[Easting]
          ,[ChangeTime]
          ,[DescriptionATOC]
          ,[DescriptionATOC_ATB]
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
          ,[LastModifiedDate]
      INTO #tmp_NLCCode_LU
      FROM [Reference].[Location_NLCCode_VW]


	--CBE allows mulitple loyalty schemes per provider to support validation. Create temp table to manage support this

	SELECT a.LoyaltyProgrammeTypeID
		  ,b.Value AS SchemeName
	INTO #tmp_LoyaltyProgrammeType
    FROM Reference.LoyaltyProgrammeType a
    CROSS APPLY [Staging].[SplitStringToTable] (a.ExtReference,',') AS b

    --Only interested in TVM transactions and where there is a loyalty reference. Create temp table as need
	--to add new Loyalty Cards and add the transaction

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
	             AND    ProcessedInd = 0
				 AND    Retail_Channel_Code = 'TVM'
				 AND    Loyalty_Card_Number IS NOT NULL)

    SELECT CBE_SalesTransactionID
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
    INTO #tmp_TVM_SalesTransactions
	FROM CTE_CBE_SalesTransaction
	WHERE RANKING = 1

	--Add new Loyalty Card references

	;WITH CTE_LoyaltyAccounts AS (
    SELECT a.Scheme_Name
          ,a.Loyalty_Card_Number
          ,a.Date_Created
          ,a.Date_Modified
          ,ROW_NUMBER() OVER (partition by a.Loyalty_Card_Number order by a.Date_Created) Ranking
    FROM #tmp_TVM_SalesTransactions a WITH (NOLOCK)
	INNER JOIN #tmp_LoyaltyProgrammeType       b WITH (NOLOCK) ON b.SchemeName                = a.Scheme_Name
	LEFT JOIN  [Staging].[STG_LoyaltyAccount]  c WITH (NOLOCK) ON c.LoyaltyReference          = a.[Loyalty_Card_Number]
	                                               AND c.LoyaltyProgrammeTypeID = b.LoyaltyProgrammeTypeID
	WHERE c.LoyaltyAccountID IS NULL)

	INSERT INTO [Staging].[STG_LoyaltyAccount]
          ([Name]
          ,[Description]
          ,[CreatedDate]
          ,[CreatedBy]
          ,[LastModifiedDate]
          ,[LastModifiedBy]
          ,[ArchivedInd]
          ,[LoyaltyProgrammeTypeID]
          ,[LoyaltyReference]
          ,[InformationSourceID]
          ,[SourceCreatedDate]
          ,[SourceModifiedDate])
   	SELECT NULL
          ,NULL
          ,GETDATE()
          ,@userid
          ,GETDATE()
          ,@userid
          ,0
		  ,b.LoyaltyProgrammeTypeID
		  ,Loyalty_Card_Number
		  ,@informationsourceid
		  ,Date_Created
		  ,Date_Modified
    FROM CTE_LoyaltyAccounts a WITH (NOLOCK)
	INNER JOIN #tmp_LoyaltyProgrammeType b WITH (NOLOCK) ON a.Scheme_Name = b.[SchemeName]
	WHERE a.Ranking = 1

	--Add new transactions for non-person customers, i.e. IsPersonInd = 0

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
    FROM   #tmp_TVM_SalesTransactions a WITH (NOLOCK)
	       INNER JOIN Staging.STG_KeyMapping         b WITH (NOLOCK) ON a.[CD_ID] = b.[CBECustomerID]
		                                               AND b.CustomerID IS NOT NULL
		   INNER JOIN Staging.STG_Customer           h WITH (NOLOCK) ON h.[CustomerID] = b.[CustomerID]
		                                               AND h.IsPersonInd = 0
		   LEFT  JOIN Reference.RetailChannel        c WITH (NOLOCK) ON a.[Retail_Channel_Code] = c.[Code]
		                                               AND a.[Transaction_Date_Time] BETWEEN c.ValidityStartDate AND ValidityEndDate
													   AND c.InformationSourceID = @informationsourceid
		   LEFT  JOIN Reference.FulfilmentMethod     d WITH (NOLOCK) ON a.[Fulfilment_Type] = d.[ExtReference]
													   AND d.InformationSourceID = @informationsourceid
													   AND a.[Date_Created_Fulfilment] BETWEEN d.ValidityStartDate AND d.ValidityEndDate
		   LEFT  JOIN Staging.STG_SalesTransaction   e WITH (NOLOCK) ON CAST(a.ID AS NVARCHAR(256)) = e.ExtReference
		   LEFT  JOIN #tmp_NLCCode_LU                f WITH (NOLOCK) ON a.[Selling_NLC] = f.NLCCode
		   LEFT  JOIN #tmp_LoyaltyProgrammeType      g WITH (NOLOCK) ON g.SchemeName = a.[Scheme_Name]
	WHERE  e.ExtReference IS NULL

	--Update CBE_SalesTransaction, set processedind = 1

	UPDATE a
	SET  ProcessedInd = 1
	    ,LastModifiedDateETL = GETDATE()
	FROM PreProcessing.CBE_SalesTransaction a
	INNER JOIN Staging.STG_KeyMapping  b ON a.[CD_ID] = b.[CBECustomerID]
	INNER JOIN Staging.STG_SalesTransaction  c ON CAST(a.ID AS NVARCHAR(256)) = c.ExtReference
	AND   a.DataImportDetailID = @dataimportdetailid
	AND    a.ProcessedInd = 0

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

	SELECT @recordcount =  @successcountimport + @errorcountimport

	
	
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