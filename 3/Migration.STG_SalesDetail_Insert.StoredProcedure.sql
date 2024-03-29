USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_SalesDetail_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_SalesDetail_Insert]
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
		   ,[ReturnTravelDate])
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
           ,a.SalesTransactionID
           ,c.ProductID
		   ,b.Quantity
		   ,b.PricePerUnit
           ,b.BaseAmount
           ,CASE c.ProductTypeCode WHEN 4 THEN 1 ELSE 0 END
           ,d.RailcardTypeID
           ,CAST(b.SalesOrderDetailID AS NVARCHAR(256))
           ,@informationsourceid
		   ,f.FulfilmentMethodID
           ,e.[TransactionStatusID]
		   ,b.out_traveldate
		   ,b.out_returndate
    FROM   [Staging].[STG_SalesTransaction] a
	INNER JOIN [Migration].[MSD_SalesOrderDetail] b ON a.[Extreference] = CAST(b.SalesOrderId AS NVARCHAR(256))
	INNER JOIN [Reference].[MSD_Product] c ON c.ProductIdMSD = b.ProductId
	LEFT  JOIN [Reference].[RailcardType] d On d.ExtReference = b.out_RailCardType
	LEFT JOIN [Reference].[TransactionStatus] e ON e.ExtReference = CAST(b.out_Status AS NVARCHAR(256))
	LEFT JOIN [Reference].[FulfilmentMethod] f ON f.ExtReference = b.out_deliverymethod

	SELECT @recordcount = @@ROWCOUNT

    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END

GO
