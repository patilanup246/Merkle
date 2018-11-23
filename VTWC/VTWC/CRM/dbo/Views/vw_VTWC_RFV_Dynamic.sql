
create   view vw_VTWC_RFV_Dynamic AS
SELECT
TCSCustomerID
, FirstRegDate
, FirstTransactionDT
, LastTransactionDT
, ctTransactions
, ct0_12m, ct12_24m, ct24_36m --DEBUG
, sumRevenue
, case 
	when Recency='R' then Recency+'-'+Value
	else Recency+'-'+Value+'-'+Frequency 
  end AS RFV
FROM 
(
	SELECT
	TCSCustomerID
	, FirstRegDate
	, FirstTransactionDT
	, LastTransactionDT
	, ctTransactions
	, ct0_12m, ct12_24m, ct24_36m -- DEBUG
	, sumRevenue
	, Recency
	, CASE
		WHEN Recency = 'H' AND val0_12m > 1000 THEN 'H'
		WHEN Recency = 'H' AND val0_12m BETWEEN 250 AND 1000 THEN 'M'
		WHEN Recency = 'H' AND val0_12m <= 250 THEN 'L'

		WHEN Recency = 'M' AND val12_24m > 1000 THEN 'H'
		WHEN Recency = 'M' AND val12_24m BETWEEN 250 AND 1000 THEN 'M'
		WHEN Recency = 'M' AND val12_24m <= 250 THEN 'L'

		WHEN Recency = 'L' AND val24_36m > 1000 THEN 'H'
		WHEN Recency = 'L' AND val24_36m BETWEEN 250 AND 1000 THEN 'M'
		WHEN Recency = 'L' AND val24_36m <= 250 THEN 'L'

		WHEN Recency = 'R' AND FirstRegDate >= DATEADD(year,-1,CONVERT(date,GETDATE())) THEN 'H'
		WHEN Recency = 'R' AND FirstRegDate BETWEEN DATEADD(year,-2,CONVERT(date,GETDATE())) AND DATEADD(year,-1,CONVERT(date,GETDATE())) THEN 'M'
		WHEN Recency = 'R' AND FirstRegDate BETWEEN DATEADD(year,-3,CONVERT(date,GETDATE())) AND DATEADD(year,-2,CONVERT(date,GETDATE())) THEN 'L'
		ELSE 'VL'
		END AS Value

	, CASE
		WHEN Recency = 'H' AND ct0_12m > 10 THEN 'E'--'EST'
		WHEN Recency = 'H' AND ct0_12m BETWEEN 5 AND 10 THEN 'F'--'FAM'
		WHEN Recency = 'H' AND ct0_12m BETWEEN 2 AND 4 THEN 'T'--'TEN'
		WHEN Recency = 'H' AND ct0_12m < 2 THEN 'S' --'SOL'

		WHEN Recency = 'M' AND ct12_24m > 10 THEN 'E' --'EST'
		WHEN Recency = 'M' AND ct12_24m BETWEEN 5 AND 10 THEN 'F' --'FAM'
		WHEN Recency = 'M' AND ct12_24m BETWEEN 2 AND 4 THEN 'T' --'TEN'
		WHEN Recency = 'M' AND ct12_24m < 2 THEN 'S' --'SOL'

		WHEN Recency = 'L' AND ct24_36m > 10 THEN 'E' --'EST'
		WHEN Recency = 'L' AND ct24_36m BETWEEN 5 AND 10 THEN 'F' --'FAM'
		WHEN Recency = 'L' AND ct24_36m BETWEEN 2 AND 4 THEN 'T' --'TEN'
		WHEN Recency = 'L' AND ct24_36m < 2 THEN 'S' --'SOL'
		ELSE 'R' --'REG'
		END AS Frequency

	FROM (
			SELECT --top 100
			c.TCSCustomerID
			, MAX(CONVERT(date,c.FirstRegDate,103)) AS FirstRegDate
			, ISNULL(MIN(TransactionDate),'') AS FirstTransactionDT
			, ISNULL(MAX(TransactionDate),'') AS LastTransactionDT
			, ISNULL(COUNT(TransactionDate),0) AS ctTransactions
			, SUM(ISNULL(PurchaseValue,0)) AS sumRevenue
			, CASE 
				WHEN MAX(TransactionDate) >= DATEADD(year,-1,CONVERT(date,GETDATE())) THEN 'H' --Live
				WHEN MAX(TransactionDate) BETWEEN DATEADD(year,-2,CONVERT(date,GETDATE())) AND DATEADD(year,-1,CONVERT(date,GETDATE())) THEN 'M' -- Lapsed
				WHEN MAX(TransactionDate) BETWEEN DATEADD(year,-3,CONVERT(date,GETDATE())) AND DATEADD(year,-2,CONVERT(date,GETDATE())) THEN 'L' -- Inactive
--				WHEN MAX(TransactionDate) < DATEADD(year,-2,CONVERT(date,GETDATE()))  THEN 'L' -- Inactive
				ELSE 'R' -- Registered
			END AS Recency
			, SUM(CASE WHEN TransactionDate >= DATEADD(year,-1,CONVERT(date,GETDATE())) THEN PurchaseValue ELSE 0 END) AS val0_12m
			, SUM(CASE WHEN TransactionDate BETWEEN DATEADD(year,-2,CONVERT(date,GETDATE())) AND DATEADD(year,-1,CONVERT(date,GETDATE())) THEN PurchaseValue ELSE 0 END) AS val12_24m
			, SUM(CASE WHEN TransactionDate BETWEEN DATEADD(year,-3,CONVERT(date,GETDATE())) AND DATEADD(year,-2,CONVERT(date,GETDATE())) THEN PurchaseValue ELSE 0 END) AS val24_36m
--			, SUM(CASE WHEN TransactionDate < DATEADD(year,-2,CONVERT(date,GETDATE()))  THEN PurchaseValue ELSE 0 END) AS val24_36m

			, SUM(CASE WHEN TransactionDate >= DATEADD(year,-1,CONVERT(date,GETDATE())) THEN 1 ELSE 0 END) AS ct0_12m
			, SUM(CASE WHEN TransactionDate BETWEEN DATEADD(year,-2,CONVERT(date,GETDATE())) AND DATEADD(year,-1,CONVERT(date,GETDATE())) THEN 1 ELSE 0 END) AS ct12_24m
			, SUM(CASE WHEN TransactionDate BETWEEN DATEADD(year,-3,CONVERT(date,GETDATE())) AND DATEADD(year,-2,CONVERT(date,GETDATE())) THEN 1 ELSE 0 END) AS ct24_36m
--			, SUM(CASE WHEN TransactionDate < DATEADD(year,-2,CONVERT(date,GETDATE()))  THEN 1 ELSE 0 END) AS ct24_36m

			FROM
			[PreProcessing].[TOCPLUS_Customer] c with(nolock)
			LEFT JOIN [PreProcessing].[TOCPLUS_Bookings] b with(nolock) ON c.TCSCustomerID = b.TCSCustomerID 
														--AND b.PurchaseValue > 0
														AND c.FirstRegDate IS NOT NULL
														-- PCF ticket types..?
														--AND b.noofitems > 0 -- SPF:Exclude refunded ???
			GROUP BY
			c.TCSCustomerID
	) r
)t
;