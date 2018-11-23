CREATE PROCEDURE [PreProcessing].[STG_SalesTransaction_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Delta - MSD'

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END

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
		   ,[BookingSourceCd])
    SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,Staging.SetUKTime(a.CreatedOn)
		   ,Staging.SetUKTime(a.ModifiedOn)
           ,Staging.SetUKTime(a.out_orderplacedate)
           ,a.out_totalbasketvalue
           ,NULL
           ,c.RetailChannelID
           ,NULL
           ,b.CustomerID
           ,NULL
           ,CAST(a.SalesOrderId AS NVARCHAR(256))
           ,@informationsourceid
		   ,SUBSTRING(a.Name,1,CHARINDEX('-',a.Name,1)-1)
		   ,d.FulfilmentMethodID
		   ,a.[out_numberadults]
		   ,a.[out_numberchildren]
		   ,Staging.SetUKTime(a.[out_orderfulfilmentdate])
		   ,a.[out_totalnonrailbasketvalue]
		   ,a.[out_totalrailbasketvalue]
		   ,a.Name
		   ,a.[out_bookingsourceId]
    FROM   PreProcessing.MSD_SalesOrder a
	       INNER JOIN Staging.STG_KeyMapping        b ON a.[ContactId] = b.[MSDID]
		   LEFT  JOIN Reference.RetailChannel       c ON a.[out_bookingmethod] = c.[Name]
		   LEFT  JOIN Reference.FulfilmentMethod    d ON a.[out_deliverymethod] = d.[ExtReference]
													AND  d.InformationSourceID = @informationsourceid
		   LEFT  JOIN Staging.STG_SalesTransaction  e ON CAST(a.SalesOrderId AS NVARCHAR(256)) = e.ExtReference
	WHERE  b.CustomerID IS NOT NULL
	AND    e.ExtReference IS NULL
	AND    a.DataImportDetailID = @dataimportdetailid



	UPDATE a
	SET  ProcessedInd = 1
	FROM PreProcessing.MSD_SalesOrder a
	INNER JOIN Staging.STG_KeyMapping  b ON a.[ContactId] = b.[MSDID]
	INNER JOIN Staging.STG_SalesTransaction  c ON CAST(a.SalesOrderId AS NVARCHAR(256)) = c.ExtReference
	AND   a.DataImportDetailID = @dataimportdetailid

	UPDATE a
    SET DateLastPurchase = b.LatestDate
    FROM [Staging].[STG_Customer] a
    INNER JOIN (SELECT CustomerID,
                       MAX([SalesTransactionDate]) AS LatestDate
                FROM   [Staging].[STG_SalesTransaction]
			    GROUP  BY CustomerID) b
            ON  a.CustomerID = b.CustomerID
 
  	
 	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.MSD_SalesOrder
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.MSD_SalesOrder
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