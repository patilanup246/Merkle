CREATE PROCEDURE [PreProcessing].[CBE_SalesDetail_Supplement_Insert]
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
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL')
		
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

	--It is possible for CBE to send duplicate rows due to changes to other attributes not transferred to CBE within the same batch
	--window. Use CTE to avoid duplicates in the data from CBE

	;WITH CTE_CBE_SupplementSales AS (
	          SELECT TOP 999999999
					 [CBE_SupplementSaleID]
                    ,[ST_ID]
                    ,[FF_ID]
                    ,[TKT_ID]
                    ,[PF_ID]
                    ,[SU_ID]
                    ,[JRND_ID]
                    ,[Supplement_Code]
                    ,[Fare]
                    ,[Net_Value]
                    ,[Is_Active]
					,ROW_NUMBER() OVER (partition by [ST_ID]
					                                ,[FF_ID]
													,[TKT_ID]
													,[PF_ID]
													,[SU_ID]
													,[JRND_ID]
													,[Supplement_Code]
													ORDER BY [CBE_SupplementSaleID] DESC) RANKING
             FROM  [PreProcessing].[CBE_SupplementSale] WITH (NOLOCK)
             WHERE DataImportDetailID = @dataimportdetailid
	         AND   ProcessedInd = 0)


	--Start Processing

	INSERT INTO [Staging].[STG_SalesDetail]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SalesTransactionID]
           ,[ProductID]
		  -- ,[Quantity]
		   ,[UnitPrice]
           ,[SalesAmount]
           ,[IsTrainTicketInd]
           ,[ExtReference]
           ,[InformationSourceID]
		   ,[CustomerID])
		SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
	       ,a.SalesTransactionID
	       ,c.ProductID
	       ,b.Fare
		   ,b.Net_Value
		   ,c.IsRailTicketInd AS IsTrainTicketInd
	       ,'FF_ID='  + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
           ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') +
		   ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') +
	       ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') + 
		   ',JRND_ID='+ ISNULL(CAST(b.JRND_ID AS NVARCHAR(256)),'NULL') + 
		   ',SU_ID=' + ISNULL(CAST(b.SU_ID AS NVARCHAR(256)),'NULL')
		   ,@informationsourceid
		   ,a.CustomerID
    FROM [Staging].[STG_SalesTransaction] a WITH (NOLOCK)
    INNER JOIN CTE_CBE_SupplementSales    b WITH (NOLOCK) ON a.ExtReference = CAST(b.ST_ID AS NVARCHAR(256))
                                               AND a.InformationSourceID = @informationsourceid
    INNER JOIN [Reference].[Product]      c WITH (NOLOCK) ON b.Supplement_Code = c.SupplementCode
	                                           AND c.InformationSourceID = @informationsourceid
											   AND a.SalesTransactionDate BETWEEN c.StartDate AND c.EndDate
											   AND c.ArchivedInd = 0
	LEFT JOIN [Staging].[STG_SalesDetail] d WITH (NOLOCK) ON 'FF_ID='  + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                                      ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') +
		                                              ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') +
	                                                  ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') + 
		                                              ',JRND_ID='+ ISNULL(CAST(b.JRND_ID AS NVARCHAR(256)),'NULL') + 
		                                              ',SU_ID='  + ISNULL(CAST(b.SU_ID AS NVARCHAR(256)),'NULL') = d.ExtReference
                                               AND d.InformationSourceID = @informationsourceid
    WHERE d.SalesDetailID IS NULL
	AND   b.Net_Value IS NOT NULL
	AND   b.RANKING = 1

    --Update process recrds

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_SalesDetail] a
	INNER JOIN [PreProcessing].[CBE_SupplementSale] b ON  'FF_ID='  + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                                                  ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') +
		                                                          ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') +
	                                                              ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') + 
		                                                          ',JRND_ID='+ ISNULL(CAST(b.JRND_ID AS NVARCHAR(256)),'NULL') + 
		                                                          ',SU_ID='  + ISNULL(CAST(b.SU_ID AS NVARCHAR(256)),'NULL') = a.ExtReference
	                                          AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

    --logging
	
	SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[CBE_SupplementSale] WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[CBE_SupplementSale] WITH (NOLOCK)
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