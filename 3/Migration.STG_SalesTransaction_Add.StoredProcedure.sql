USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_SalesTransaction_Add]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_SalesTransaction_Add]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

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
    WHERE Name = [Reference].[Configuration_GetSetting] ('Migration','MSD Source')

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END

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
           ,[InformationSourceID])
    SELECT  NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,a.CreatedOn
		   ,a.ModifiedOn
           ,a.out_orderplacedate
           ,a.TotalAmount
           ,NULL
           ,c.RetailChannelID
           ,NULL
           ,b.CustomerID
           ,NULL
           ,CAST(a.SalesOrderId AS NVARCHAR(256))
           ,@informationsourceid
    FROM   Migration.MSD_SalesOrder a
	       INNER JOIN Staging.STG_KeyMapping  b ON a.ContactId = b.MSDID
		   LEFT  JOIN Reference.RetailChannel c ON a.[out_bookingmethod] = c.Name
	WHERE  b.CustomerID IS NOT NULL

	SELECT @recordcount = @@ROWCOUNT

	UPDATE a
    SET DateLastPurchase = b.LatestDate
    FROM [Staging].[STG_Customer] a
    INNER JOIN (SELECT CustomerID,
                       MAX([SalesTransactionDate]) AS LatestDate
                FROM   [Staging].[STG_SalesTransaction]
			    GROUP  BY CustomerID) b
            ON  a.CustomerID = b.CustomerID
 
    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END









GO
