DECLARE @InformationSourceID INT, @TransactionStatusID INT 

SELECT @InformationSourceID = InformationSourceID
FROM Reference.InformationSource 
WHERE [Name] = 'TrainLine'

SELECT @TransactionStatusID = TransactionStatusID
FROM Reference.TransactionStatus
WHERE [Name] = 'TrainLine' 

SELECT B.transactiondate AS createdDate
	   ,CASE WHEN B.amendedind <> 'N' THEN B.amendeddate ELSE NULL END AS LastModifiedDate
	   ,0 AS ArchiveInd
	   ,ST.SalesTransactionID
	   ,B.noofitems AS Quantity
	   ,B.purchasevalue AS SalesAmount
	   ,CASE WHEN B.purchasecode = '' THEN 1 ELSE 0 END AS IsTrainTicketInd
	   ,B.purchaseid AS ExtReference 
	   ,@InformationSourceID AS InformationSourceID
	   ,@TransactionStatusID AS TransactionStatusID
	   ,B.refundind
	   ,B.refunddate 
	   ,B.businessorleisure 
FROM PreProcessing.TOCPLUS_Bookings AS B
LEFT JOIN Staging.STG_SalesTransaction AS ST
	ON B.tcstransactionid = ST.ExtReference 
--INNER JOIN Staging.STG_Customer AS C
--	ON B.tcscustomerid = C.