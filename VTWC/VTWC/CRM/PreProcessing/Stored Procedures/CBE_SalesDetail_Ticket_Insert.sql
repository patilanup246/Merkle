CREATE PROCEDURE [PreProcessing].[CBE_SalesDetail_Ticket_Insert]
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

	--Returns with Outbound Dates and Return Dates

	;WITH CTE_Tickets_Returns AS (
                  SELECT TOP 999999999
						 a.[CBE_TicketID]
                        ,a.[FF_ID]
                        ,a.[ST_ID]
                        ,a.[PF_ID]
                        ,a.[JRND_ID]
                        ,a.[Date_Created]
                        ,a.[Date_Modified]
                        ,a.[TKT_ID]
                        ,a.[FTOT]
                        ,a.[Start_Date]
                        ,a.[Validity_End_Date]
                        ,a.[Ticket_Category]
                        ,a.[Origin_NLC]
                        ,a.[Destination_NLC]
                        ,a.[Is_Cross_London]
                        ,a.[Restriction_Code]
                        ,a.[Is_Carnet]
                        ,a.[Fare_Type]
                        ,a.[Railcard_Code]
                        ,a.[Fulfilment_Type]
                        ,a.[Number_Of_Passengers]
                        ,a.[Departure_DateTime_Outbound]
                        ,b.[Departure_DateTime_Return]
                        ,a.[Arrival_DateTime_Outbound]
                        ,b.[Arrival_DateTime_Return]
                        ,a.[Net_Value]
                        ,a.[Fare]
                        ,a.[Quantity]
				        ,ROW_NUMBER() OVER (partition by a.[FF_ID]
						                                ,a.[ST_ID]
							                            ,a.[PF_ID]
														,a.[TKT_ID]
														 ORDER BY a.[Date_Modified] DESC
														         ,a.[CBE_TicketID] DESC) RANKING
                  FROM [PreProcessing].[CBE_Ticket] a WITH (NOLOCK)
				  INNER JOIN [Reference].[Product] prod WITH (NOLOCK) ON a.FTOT = prod.FTOT
				                                      AND prod.InformationSourceID = @informationsourceid
													  AND prod.ReturnInd = 1
													  AND prod.ArchivedInd = 0
				  INNER JOIN [PreProcessing].[CBE_Ticket] b WITH (NOLOCK) ON a.ST_ID = b.ST_ID
				                                             AND a.FTOT = b.FTOT
				                                             AND a.FF_ID = b.FF_ID
															 AND a.PF_ID = b.PF_ID
															 AND a.TKT_ID = b.TKT_ID
															 AND b.[Departure_DateTime_Return] IS NOT NULL
															 AND b.[Arrival_DateTime_Return]   IS NOT NULL
				  WHERE  a.[Departure_DateTime_Outbound] IS NOT NULL
				  AND    a.[Arrival_DateTime_Outbound]   IS NOT NULL
				  AND    a.[Fare_Type] = 'P2P'
				  AND    a.DataImportDetailID = @dataimportdetailid
	              AND    a.ProcessedInd = 0)

	--Add to Sales Detail

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
		   ,[Quantity]
		   ,[UnitPrice]
           ,[SalesAmount]
           ,[IsTrainTicketInd]
           ,[RailcardTypeID]
           ,[ExtReference]
           ,[InformationSourceID]
		   ,[FulfilmentMethodID]
           ,[TransactionStatusID]
		   ,[OutTravelDate]
		   ,[ReturnTravelDate]
		   ,[CustomerID]
		   ,[ValidityStartDate]
		   ,[ValidityEndDate]
		   ,[FareTypeCd]
		   ,[FareCategoryCd]
		   ,[TicketRestrictionID])
	SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
	       ,a.SalesTransactionID
	       ,c.ProductID
	       ,b.Quantity
	       ,b.Fare
		   ,b.Net_Value
		   ,c.IsRailTicketInd AS IsTrainTicketInd
	       ,d.RailcardTypeID
	       ,'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
           ',ST_ID='   + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
		   ',PF_ID='   + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') +
	       ',TKT_ID='  + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL')
		   ,@informationsourceid
           ,f.FulfilmentMethodID
		   ,NULL
	       ,CAST(b.Departure_DateTime_Outbound AS DATE)
	       ,CAST(b.Departure_DateTime_Return AS DATE)
		   ,a.CustomerID
		   ,b.Start_Date
		   ,b.Validity_End_Date
		   ,b.Fare_Type
		   ,b.Ticket_Category
		   ,h.TicketRestrictionID
    FROM Staging.STG_SalesTransaction a
    INNER JOIN CTE_Tickets_Returns        b WITH (NOLOCK) ON a.ExtReference = CAST(b.ST_ID AS NVARCHAR(256))
                                              AND a.InformationSourceID = @informationsourceid
    INNER JOIN Reference.Product          c WITH (NOLOCK) ON b.FTOT = c.FTOT
	                                          AND c.InformationSourceID = @informationsourceid
											  AND a.SalesTransactionDate BETWEEN c.StartDate AND c.EndDate
											  AND c.ArchivedInd = 0
	LEFT JOIN Reference.RailcardType      d WITH (NOLOCK) ON b.Railcard_Code = d.ExtReference
	                                            AND a.SalesTransactionDate BETWEEN d.StartDate AND d.EndDate
												AND d.InformationSourceID = @informationsourceid
												AND d.ArchivedInd = 0
    LEFT JOIN Reference.FulfilmentMethod  f WITH (NOLOCK) ON b.Fulfilment_Type = f.ExtReference
                                              AND  f.InformationSourceID = @informationsourceid
											  AND  a.SalesTransactionDate BETWEEN f.ValidityStartDate AND f.ValidityEndDate
    LEFT JOIN [Staging].[STG_SalesDetail] g WITH (NOLOCK) ON 'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                               ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
											   ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') + 
	                                           ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') = g.ExtReference
                                              AND g.InformationSourceID = @informationsourceid
    LEFT JOIN Reference.TicketRestriction h WITH (NOLOCK) ON b.Restriction_Code = h.Code
	                                          AND a.SalesTransactionDate BETWEEN h.ValidityStartDate AND h.ValidityEndDate
											  AND h.InformationSourceID = @informationsourceid
											  AND h.ArchivedInd = 0
    WHERE g.SalesDetailID IS NULL
	AND   b.Net_Value IS NOT NULL
	AND   b.RANKING = 1  

    --Update processed records

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_SalesDetail] a
	INNER JOIN [PreProcessing].[CBE_Ticket] b ON 'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                                 ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
											     ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') + 
											     ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') = a.ExtReference
	                                             AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	--Returns with Outbound Dates but no Return Dates

	;WITH CTE_Tickets_Returns AS (
                  SELECT TOP 999999999
						 a.[CBE_TicketID]
                        ,a.[FF_ID]
                        ,a.[ST_ID]
                        ,a.[PF_ID]
                        ,a.[JRND_ID]
                        ,a.[Date_Created]
                        ,a.[Date_Modified]
                        ,a.[TKT_ID]
                        ,a.[FTOT]
                        ,a.[Start_Date]
                        ,a.[Validity_End_Date]
                        ,a.[Ticket_Category]
                        ,a.[Origin_NLC]
                        ,a.[Destination_NLC]
                        ,a.[Is_Cross_London]
                        ,a.[Restriction_Code]
                        ,a.[Is_Carnet]
                        ,a.[Fare_Type]
                        ,a.[Railcard_Code]
                        ,a.[Fulfilment_Type]
                        ,a.[Number_Of_Passengers]
                        ,a.[Departure_DateTime_Outbound]
                        ,b.[Departure_DateTime_Return]
                        ,a.[Arrival_DateTime_Outbound]
                        ,b.[Arrival_DateTime_Return]
                        ,a.[Net_Value]
                        ,a.[Fare]
                        ,a.[Quantity]
				        ,ROW_NUMBER() OVER (partition by a.[FF_ID]
						                                ,a.[ST_ID]
							                            ,a.[PF_ID]
														,a.[TKT_ID]
														 ORDER BY a.[Date_Modified] DESC
														         ,a.[CBE_TicketID] DESC) RANKING
                  FROM   [PreProcessing].[CBE_Ticket] a WITH (NOLOCK)
				  INNER JOIN [Staging].[STG_SalesTransaction] c WITH (NOLOCK) ON CAST(a.ST_ID AS nvarchar(256)) = c.ExtReference
				                                                 AND c.InformationSourceID = @informationsourceid
				  INNER JOIN [Reference].[Product] prod WITH (NOLOCK) ON a.FTOT = prod.FTOT
				                                      AND prod.InformationSourceID = @informationsourceid
													  AND prod.ReturnInd = 1
													  AND prod.ArchivedInd = 0
				  INNER JOIN [PreProcessing].[CBE_Ticket] b WITH (NOLOCK) ON a.ST_ID = b.ST_ID
				                                             AND a.FTOT = b.FTOT
				                                             AND a.FF_ID = b.FF_ID
															 AND a.PF_ID = b.PF_ID
															 AND a.TKT_ID = b.TKT_ID
															 AND b.[Departure_DateTime_Return]   IS NULL
															 AND b.[Arrival_DateTime_Return]     IS NULL
															 AND b.[Departure_DateTime_Outbound] IS NULL
				                                             AND b.[Arrival_DateTime_Outbound]   IS NULL
				  WHERE  1=1
				  AND    a.[Departure_DateTime_Outbound] IS NOT NULL
				  AND    a.[Arrival_DateTime_Outbound]   IS NOT NULL
				  AND    a.[Fare_Type] = 'P2P'
				  AND    a.DataImportDetailID = @dataimportdetailid
	              AND    a.ProcessedInd = 0)

	--Add to Sales Detail

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
		   ,[Quantity]
		   ,[UnitPrice]
           ,[SalesAmount]
           ,[IsTrainTicketInd]
           ,[RailcardTypeID]
           ,[ExtReference]
           ,[InformationSourceID]
		   ,[FulfilmentMethodID]
           ,[TransactionStatusID]
		   ,[OutTravelDate]
		   ,[ReturnTravelDate]
		   ,[CustomerID]
		   ,[ValidityStartDate]
		   ,[ValidityEndDate]
		   ,[FareTypeCd]
		   ,[FareCategoryCd]
		   ,[TicketRestrictionID])
	SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
	       ,a.SalesTransactionID
	       ,c.ProductID
	       ,b.Quantity
	       ,b.Fare
		   ,b.Net_Value
		   ,c.IsRailTicketInd AS IsTrainTicketInd
	       ,d.RailcardTypeID
	       ,'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
           ',ST_ID='   + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
		   ',PF_ID='   + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') +
	       ',TKT_ID='  + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL')
		   ,@informationsourceid
           ,f.FulfilmentMethodID
		   ,NULL
	       ,CAST(b.Departure_DateTime_Outbound AS DATE)
	       ,CAST(b.Departure_DateTime_Return AS DATE)
		   ,a.CustomerID
		   ,b.Start_Date
		   ,b.Validity_End_Date
		   ,b.Fare_Type
		   ,b.Ticket_Category
		   ,h.TicketRestrictionID
    FROM Staging.STG_SalesTransaction a WITH (NOLOCK)
    INNER JOIN CTE_Tickets_Returns            b WITH (NOLOCK) ON a.ExtReference = CAST(b.ST_ID AS NVARCHAR(256))
                                              AND a.InformationSourceID = @informationsourceid
    INNER JOIN Reference.Product          c WITH (NOLOCK) ON b.FTOT = c.FTOT
	                                          AND c.InformationSourceID = @informationsourceid
											  AND a.SalesTransactionDate BETWEEN c.StartDate AND c.EndDate
											  AND c.ArchivedInd = 0
	LEFT JOIN Reference.RailcardType      d WITH (NOLOCK) ON b.Railcard_Code = d.ExtReference
	                                          AND a.SalesTransactionDate BETWEEN d.StartDate AND d.EndDate
											  AND d.InformationSourceID = @informationsourceid
											  AND d.ArchivedInd = 0
    LEFT JOIN Reference.FulfilmentMethod  f WITH (NOLOCK) ON b.Fulfilment_Type = f.ExtReference
                                              AND  f.InformationSourceID = @informationsourceid
											  AND  a.SalesTransactionDate BETWEEN f.ValidityStartDate AND f.ValidityEndDate
    LEFT JOIN [Staging].[STG_SalesDetail] g WITH (NOLOCK) ON 'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                               ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
											   ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') + 
	                                           ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') = g.ExtReference
                                              AND g.InformationSourceID = @informationsourceid
    LEFT JOIN Reference.TicketRestriction h WITH (NOLOCK) ON b.Restriction_Code = h.Code
	                                          AND a.SalesTransactionDate BETWEEN h.ValidityStartDate AND h.ValidityEndDate
											  AND h.InformationSourceID = @informationsourceid
											  AND h.ArchivedInd = 0
    WHERE g.SalesDetailID IS NULL
	AND   b.Net_Value IS NOT NULL
	AND   b.RANKING = 1  

    --Update processed records

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_SalesDetail] a
	INNER JOIN [PreProcessing].[CBE_Ticket] b ON 'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                                 ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
											     ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') + 
											     ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') = a.ExtReference
	                                             AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

    --Returns without outbound and return times

	;WITH CTE_Tickets_Returns AS (
                  SELECT TOP 999999999
						 a.[CBE_TicketID]
                        ,a.[FF_ID]
                        ,a.[ST_ID]
                        ,a.[PF_ID]
                        ,a.[JRND_ID]
                        ,a.[Date_Created]
                        ,a.[Date_Modified]
                        ,a.[TKT_ID]
                        ,a.[FTOT]
                        ,a.[Start_Date]
                        ,a.[Validity_End_Date]
                        ,a.[Ticket_Category]
                        ,a.[Origin_NLC]
                        ,a.[Destination_NLC]
                        ,a.[Is_Cross_London]
                        ,a.[Restriction_Code]
                        ,a.[Is_Carnet]
                        ,a.[Fare_Type]
                        ,a.[Railcard_Code]
                        ,a.[Fulfilment_Type]
                        ,a.[Number_Of_Passengers]
                        ,a.[Departure_DateTime_Outbound]
                        ,b.[Departure_DateTime_Return]
                        ,a.[Arrival_DateTime_Outbound]
                        ,b.[Arrival_DateTime_Return]
                        ,a.[Net_Value]
                        ,a.[Fare]
                        ,a.[Quantity]
				        ,ROW_NUMBER() OVER (partition by a.[FF_ID]
						                                ,a.[ST_ID]
							                            ,a.[PF_ID]
														,a.[TKT_ID]
														 ORDER BY a.[Date_Modified] DESC
														         ,a.[CBE_TicketID] DESC) RANKING
                  FROM   [PreProcessing].[CBE_Ticket] a WITH (NOLOCK)
				  INNER JOIN [Staging].[STG_SalesTransaction] c WITH (NOLOCK) ON CAST(a.ST_ID AS nvarchar(256)) = c.ExtReference
				                                                 AND c.InformationSourceID = @informationsourceid
				  INNER JOIN [Reference].[Product] prod WITH (NOLOCK) ON a.FTOT = prod.FTOT
				                                      AND prod.InformationSourceID = @informationsourceid
													  AND prod.ReturnInd = 1
													  AND prod.ArchivedInd = 0
                  LEFT JOIN [PreProcessing].[CBE_Ticket] b WITH (NOLOCK) ON    a.ST_ID = b.ST_ID
				                                             AND a.FTOT = b.FTOT
				                                             AND a.FF_ID = b.FF_ID
															 AND a.PF_ID = b.PF_ID
															 AND a.TKT_ID = b.TKT_ID
				  WHERE  a.[Departure_DateTime_Outbound] IS NULL
				  AND    a.[Arrival_DateTime_Outbound]   IS NULL
				  AND    a.[Departure_DateTime_Return]   IS NULL
				  AND    a.[Arrival_DateTime_Return]     IS NULL
                  AND    a.Fare_Type ='P2P'
                  AND    b.Ticket_Category IS NULL
				  AND    a.DataImportDetailID = @dataimportdetailid
				  AND    a.ProcessedInd = 0)

	--Add to Sales Detail

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
		   ,[Quantity]
		   ,[UnitPrice]
           ,[SalesAmount]
           ,[IsTrainTicketInd]
           ,[RailcardTypeID]
           ,[ExtReference]
           ,[InformationSourceID]
		   ,[FulfilmentMethodID]
           ,[TransactionStatusID]
		   ,[OutTravelDate]
		   ,[ReturnTravelDate]
		   ,[CustomerID]
		   ,[ValidityStartDate]
		   ,[ValidityEndDate]
		   ,[FareTypeCd]
		   ,[FareCategoryCd]
		   ,[TicketRestrictionID])
	SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
	       ,a.SalesTransactionID
	       ,c.ProductID
	       ,b.Quantity
	       ,b.Fare
		   ,b.Net_Value
		   ,c.IsRailTicketInd AS IsTrainTicketInd
	       ,d.RailcardTypeID
	       ,'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
           ',ST_ID='   + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
		   ',PF_ID='   + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') +
	       ',TKT_ID='  + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL')
		   ,@informationsourceid
           ,f.FulfilmentMethodID
		   ,NULL
	       ,CAST(b.Departure_DateTime_Outbound AS DATE)
	       ,CAST(b.Departure_DateTime_Return AS DATE)
		   ,a.CustomerID
		   ,b.Start_Date
		   ,b.Validity_End_Date
		   ,b.Fare_Type
		   ,b.Ticket_Category
		   ,h.TicketRestrictionID
    FROM Staging.STG_SalesTransaction a WITH (NOLOCK)
    INNER JOIN CTE_Tickets_Returns        b WITH (NOLOCK) ON a.ExtReference = CAST(b.ST_ID AS NVARCHAR(256))
                                              AND a.InformationSourceID = @informationsourceid
    INNER JOIN Reference.Product          c WITH (NOLOCK) ON b.FTOT = c.FTOT
	                                          AND c.InformationSourceID = @informationsourceid
											  AND a.SalesTransactionDate BETWEEN c.StartDate AND c.EndDate
											  AND c.ArchivedInd = 0
	LEFT JOIN Reference.RailcardType      d WITH (NOLOCK) ON b.Railcard_Code = d.ExtReference
	                                          AND a.SalesTransactionDate BETWEEN d.StartDate AND d.EndDate
											  AND d.InformationSourceID = @informationsourceid
											  AND d.ArchivedInd = 0
    LEFT JOIN Reference.FulfilmentMethod  f WITH (NOLOCK) ON b.Fulfilment_Type = f.ExtReference
                                              AND  f.InformationSourceID = @informationsourceid
											  AND  a.SalesTransactionDate BETWEEN f.ValidityStartDate AND f.ValidityEndDate
    LEFT JOIN [Staging].[STG_SalesDetail] g WITH (NOLOCK) ON 'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                               ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
											   ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') + 
	                                           ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') = g.ExtReference
                                              AND g.InformationSourceID = @informationsourceid
    LEFT JOIN Reference.TicketRestriction h WITH (NOLOCK) ON b.Restriction_Code = h.Code
	                                          AND a.SalesTransactionDate BETWEEN h.ValidityStartDate AND h.ValidityEndDate
											  AND h.InformationSourceID = @informationsourceid
											  AND h.ArchivedInd = 0

    WHERE g.SalesDetailID IS NULL
	AND   b.Net_Value IS NOT NULL
	AND   b.RANKING = 1  

    --Update processed records

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_SalesDetail] a
	INNER JOIN [PreProcessing].[CBE_Ticket] b ON 'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                                 ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
											     ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') + 
											     ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') = a.ExtReference
	                                             AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

    --Now for remaining tickets

	;WITH CTE_CBE_Tickets AS (
                  SELECT TOP 999999999
						 [CBE_TicketID]
                        ,[FF_ID]
                        ,[ST_ID]
                        ,[PF_ID]
                        ,[JRND_ID]
                        ,[Date_Created]
                        ,[Date_Modified]
                        ,[TKT_ID]
                        ,[FTOT]
                        ,[Start_Date]
                        ,[Validity_End_Date]
                        ,[Ticket_Category]
                        ,[Origin_NLC]
                        ,[Destination_NLC]
                        ,[Is_Cross_London]
                        ,[Restriction_Code]
                        ,[Is_Carnet]
                        ,[Fare_Type]
                        ,[Railcard_Code]
                        ,[Fulfilment_Type]
                        ,[Number_Of_Passengers]
                        ,[Departure_DateTime_Outbound]
                        ,[Departure_DateTime_Return]
                        ,[Arrival_DateTime_Outbound]
                        ,[Arrival_DateTime_Return]
                        ,[Net_Value]
                        ,[Fare]
                        ,[Quantity]
				        ,ROW_NUMBER() OVER (partition by [FF_ID]
						                                ,[ST_ID]
							                            ,[PF_ID]
														,[JRND_ID]
														,[TKT_ID]
														,[FTOT]
														 ORDER BY [Date_Modified] DESC
														         ,[CBE_TicketID] DESC) RANKING
                  FROM   [PreProcessing].[CBE_Ticket] WITH (NOLOCK)
				  WHERE  DataImportDetailID = @dataimportdetailid
	              AND    ProcessedInd = 0)

	--Add to Sales Detail

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
		   ,[Quantity]
		   ,[UnitPrice]
           ,[SalesAmount]
           ,[IsTrainTicketInd]
           ,[RailcardTypeID]
           ,[ExtReference]
           ,[InformationSourceID]
		   ,[FulfilmentMethodID]
           ,[TransactionStatusID]
		   ,[OutTravelDate]
		   ,[ReturnTravelDate]
		   ,[CustomerID]
		   ,[ValidityStartDate]
		   ,[ValidityEndDate]
           ,[FareTypeCd]
		   ,[FareCategoryCd]
		   ,[TicketRestrictionID])
	SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
	       ,a.SalesTransactionID
	       ,c.ProductID
	       ,b.Quantity
	       ,b.Fare
		   ,b.Net_Value
		   ,c.IsRailTicketInd AS IsTrainTicketInd
	       ,d.RailcardTypeID
	       ,'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
           ',ST_ID='   + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
		   ',PF_ID='   + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') +
	       ',TKT_ID='  + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL')
		   ,@informationsourceid
           ,f.FulfilmentMethodID
		   ,NULL -- e.[TransactionStatusID]
	       ,CAST(b.Departure_DateTime_Outbound AS DATE)
	       ,CAST(b.Departure_DateTime_Return AS DATE)
		   ,a.CustomerID
		   ,b.Start_Date
		   ,b.Validity_End_Date
           ,b.Fare_Type
		   ,b.Ticket_Category
		   ,h.TicketRestrictionID
    FROM Staging.STG_SalesTransaction a WITH (NOLOCK)
    INNER JOIN CTE_CBE_Tickets            b WITH (NOLOCK) ON a.ExtReference  = CAST(b.ST_ID AS NVARCHAR(256))
                                              AND a.InformationSourceID = @informationsourceid
    INNER JOIN Reference.Product          c WITH (NOLOCK) ON b.FTOT = c.FTOT
	                                          AND c.InformationSourceID = @informationsourceid
											  AND a.SalesTransactionDate BETWEEN c.StartDate AND c.EndDate
											  AND c.ArchivedInd = 0
	LEFT JOIN Reference.RailcardType      d WITH (NOLOCK) ON b.Railcard_Code = d.ExtReference
	                                          AND a.SalesTransactionDate BETWEEN d.StartDate AND d.EndDate
											  AND d.InformationSourceID = @informationsourceid
											  AND d.ArchivedInd = 0
    LEFT JOIN Reference.FulfilmentMethod  f WITH (NOLOCK) ON b.Fulfilment_Type = f.ExtReference
                                              AND  f.InformationSourceID = @informationsourceid
											  AND  a.SalesTransactionDate BETWEEN f.ValidityStartDate AND f.ValidityEndDate
    LEFT JOIN [Staging].[STG_SalesDetail] g WITH (NOLOCK) ON 'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                               ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
											   ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') + 
	                                           ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') = g.ExtReference
                                              AND g.InformationSourceID = @informationsourceid
    LEFT JOIN Reference.TicketRestriction h ON b.Restriction_Code = h.Code
	                                          AND a.SalesTransactionDate BETWEEN h.ValidityStartDate AND h.ValidityEndDate
											  AND h.InformationSourceID = @informationsourceid
											  AND h.ArchivedInd = 0
	WHERE g.SalesDetailID IS NULL
	AND   b.Net_Value IS NOT NULL
	AND   b.RANKING = 1

    --Update processed records

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Staging].[STG_SalesDetail] a
	INNER JOIN [PreProcessing].[CBE_Ticket] b ON 'FF_ID='   + ISNULL(CAST(b.FF_ID AS NVARCHAR(256)),'NULL') + 
                                                 ',ST_ID='  + ISNULL(CAST(b.ST_ID AS NVARCHAR(256)),'NULL') + 
											     ',PF_ID='  + ISNULL(CAST(b.PF_ID AS NVARCHAR(256)),'NULL') + 
											     ',TKT_ID=' + ISNULL(CAST(b.TKT_ID AS NVARCHAR(256)),'NULL') = a.ExtReference
	                                             AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

    --logging
	
	SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_Ticket
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_Ticket
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