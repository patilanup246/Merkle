DECLARE @InformationSourceID INT, @DataImportDetailID INT = 724

DECLARE @Now DATETIME = GETDATE()

SELECT @InformationSourceID = InformationSourceID
FROM Reference.InformationSource
WHERE Name = 'TrainLine'


IF OBJECT_ID(N'tempdb..#RefundType') IS NOT NULL
DROP TABLE #RefundType
SELECT RefundType AS [Name], @InformationSourceID AS InformationSourceID
INTO #RefundType
FROM PreProcessing.TOCPLUS_Refunds
WHERE DataImportDetailID = @DataImportDetailID
GROUP BY RefundType


EXEC [Reference].[RefundType_Upsert]

IF OBJECT_ID(N'tempdb..#RefundReason') IS NOT NULL
DROP TABLE #RefundReason
SELECT RefundReason AS [Code], RefundReasonDesc AS [Name], @InformationSourceID AS InformationSourceID
INTO #RefundReason
FROM PreProcessing.TOCPLUS_Refunds
WHERE DataImportDetailID = @DataImportDetailID
GROUP BY RefundReason, RefundReasonDesc

EXEC [Reference].[RefundReason_Upsert]

IF OBJECT_ID(N'tempdb..#RailRefunds') IS NOT NULL
DROP TABLE #RailRefunds
SELECT SD.CustomerID, SD.SalesTransactionID, R.ArRefArrivalId AS RefundNumber
		,RT.RefundTypeID, R.Percentage, R.GrossRefund, R.AdminFee, R.RefundAmount
		,R.DatamartCreateDate, R.DatamartUpdateDate, R.RequestedDate, R.RefundedIssuedDate
		,RRC.RefundReasonCodeID
INTO #RailRefunds
FROM Staging.STG_SalesDetail AS SD
INNER JOIN Staging.STG_Journey AS J
	ON SD.SalesDetailID = J.SalesDetailID
INNER JOIN (SELECT   ROW_NUMBER() OVER (PARTITION BY TCSBookingID, ArRefArrivalID ORDER BY TOCRefundsID DESC) AS RANKING 
					,*
			FROM PreProcessing.TOCPLUS_Refunds 
			WHERE  DataImportDetailID = @dataimportdetailid
			AND    ProcessedInd = 0
			) AS R
	ON J.BookingID = R.TcsBookingID 
LEFT JOIN Reference.RefundType AS RT
	ON R.RefundType = RT.Name 
LEFT JOIN Reference.RefundReasonCode AS RRC 
	ON R.RefundReason = RRC.Code 
WHERE RANKING=1


