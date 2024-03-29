--1056404
IF OBJECT_ID(N'tempdb..#Merged_Customers') IS NOT NULL
DROP TABLE #Merged_Customers
SELECT CustomerID, COUNT(*) AS CNT
INTO #Merged_Customers
FROM Staging.STG_KeyMapping 
GROUP BY CustomerID
HAVING COUNT(*)>1

/*
--470141
SELECT COUNT(*)
FROM #Merged_Customers
*/

--1056404
IF OBJECT_ID(N'tempdb..#Merged_Customers_Source') IS NOT NULL
DROP TABLE #Merged_Customers_Source
SELECT C.CustomerID, KM.TCSCustomerID
INTO #Merged_Customers_Source
FROM Staging.STG_Customer AS C
INNER JOIN Staging.STG_KeyMapping AS KM
	ON C.CustomerID = KM.CustomerID
INNER JOIN #Merged_Customers AS MC
	ON C.CustomerID = MC.CustomerID
GROUP BY C.CustomerID, KM.TCSCustomerID

/*
--1057017
SELECT COUNT(DISTINCT TCSCustomerID)
FROM #Merged_Customers_Source
*/

--1193949
IF OBJECT_ID(N'tempdb..#Source_Customers') IS NOT NULL
DROP TABLE #Source_Customers
SELECT MCS.CustomerID, Staging.genUniqueKey(forename,'',surname,postcode,addressline1,addressline2) AS Namad, TC.*
INTO #Source_Customers
FROM PreProcessing.TOCPLUS_Customer AS TC
INNER JOIN #Merged_Customers_Source AS MCS
	ON TC.TCScustomerID = MCS.TCSCustomerID


/*
--1057017
SELECT COUNT(DISTINCT TCSCustomerID)
FROM #Source_Customers
*/


IF OBJECT_ID(N'tempdb..#EmailMatches') IS NOT NULL
DROP TABLE #EmailMatches
SELECT DISTINCT C1.*
INTO #EmailMatches
FROM #Source_Customers AS C1
INNER JOIN #Source_Customers AS C2	
	ON C1.CustomerID = C2.CustomerID
	AND C1.TCScustomerID <> C2.TCScustomerID
	AND C1.ParsedAddressEmail = C2.ParsedAddressEmail

/*
--386
SELECT COUNT(DISTINCT TCScustomerID) 
FROM #EmailMatches
*/

IF OBJECT_ID(N'tempdb..#ParsedAddressMobile') IS NOT NULL
DROP TABLE #ParsedAddressMobile
SELECT DISTINCT C1.*
INTO #ParsedAddressMobile
FROM #Source_Customers AS C1
INNER JOIN #Source_Customers AS C2	
	ON C1.CustomerID = C2.CustomerID
	AND C1.TCScustomerID <> C2.TCScustomerID
	AND C1.ParsedAddressMobile = C2.ParsedAddressMobile
	AND C1.ParsedAddressMobile <>''
	AND C2.ParsedAddressMobile <>''
WHERE NOT EXISTS (SELECT * FROM #EmailMatches AS E WHERE C1.CustomerID = E.CustomerID)

/*
--446928
SELECT COUNT(DISTINCT TCScustomerID)  AS COUNTS
FROM #ParsedAddressMobile

SELECT ParsedAddressMobile, COUNT(DISTINCT TCScustomerID)  AS COUNTS
FROM #ParsedAddressMobile
GROUP BY ParsedAddressMobile
HAVING COUNT(DISTINCT TCScustomerID)>2
ORDER BY 2 DESC 
*/

IF OBJECT_ID(N'tempdb..#ParsedAddressMobile1') IS NOT NULL
DROP TABLE #ParsedAddressMobile1
SELECT DISTINCT C1.*
INTO #ParsedAddressMobile1
FROM #Source_Customers AS C1
INNER JOIN #Source_Customers AS C2	
	ON C1.CustomerID = C2.CustomerID
	AND C1.TCScustomerID <> C2.TCScustomerID
	AND C1.ParsedAddressMobile1 = C2.ParsedAddressMobile1
	AND C1.ParsedAddressMobile1 <>''
	AND C2.ParsedAddressMobile1 <>''
WHERE NOT EXISTS (SELECT * FROM #ParsedAddressMobile AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #EmailMatches AS E WHERE C1.CustomerID = E.CustomerID)

/*
--22934
SELECT COUNT(DISTINCT TCScustomerID)  
FROM #ParsedAddressMobile1

SELECT ParsedAddressMobile1, COUNT(DISTINCT TCScustomerID)  AS COUNTS
FROM #ParsedAddressMobile1
GROUP BY ParsedAddressMobile1
ORDER BY 2 DESC 
*/

IF OBJECT_ID(N'tempdb..#ParsedAddressMobile2') IS NOT NULL
DROP TABLE #ParsedAddressMobile2
SELECT DISTINCT C1.*
INTO #ParsedAddressMobile2
FROM #Source_Customers AS C1
INNER JOIN #Source_Customers AS C2	
	ON C1.CustomerID = C2.CustomerID
	AND C1.TCScustomerID <> C2.TCScustomerID
	AND C1.ParsedAddressMobile2 = C2.ParsedAddressMobile2
	AND C1.ParsedAddressMobile2 <>''
	AND C2.ParsedAddressMobile2 <>''
WHERE NOT EXISTS (SELECT * FROM #ParsedAddressMobile1 AS E WHERE C1.CustomerID = E.CustomerID)
AND NOT EXISTS (SELECT * FROM #ParsedAddressMobile AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #EmailMatches AS E WHERE C1.CustomerID = E.CustomerID)

/*
--69
SELECT COUNT(DISTINCT TCScustomerID) 
FROM #ParsedAddressMobile2

SELECT ParsedAddressMobile2, COUNT(DISTINCT TCScustomerID)  AS COUNTS
FROM #ParsedAddressMobile2
GROUP BY ParsedAddressMobile2
ORDER BY 2 DESC 
*/

IF OBJECT_ID(N'tempdb..#Namad') IS NOT NULL
DROP TABLE #Namad
SELECT DISTINCT C1.*
INTO #Namad
FROM #Source_Customers AS C1
INNER JOIN #Source_Customers AS C2	
	ON C1.CustomerID = C2.CustomerID
	AND C1.TCScustomerID <> C2.TCScustomerID
	AND C1.Namad = C2.Namad
WHERE NOT EXISTS (SELECT * FROM #ParsedAddressMobile2 AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #ParsedAddressMobile1 AS E WHERE C1.CustomerID = E.CustomerID)
AND NOT EXISTS (SELECT * FROM #ParsedAddressMobile AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #EmailMatches AS E WHERE C1.CustomerID = E.CustomerID)
SELECT forename, surname, COUNT(DISTINCT TCScustomerID) AS Counts
FROM #Namad
where Namad like '%incomp%'
group by forename, surname
order by 3 desc

/*
--select 566750 + 19950
SELECT firs COUNT(DISTINCT TCScustomerID) 
FROM #Namad
where Namad like '%incomp%'

SELECT AddressLine1, PostCode, COUNT(DISTINCT TCScustomerID) 
FROM #Namad
GROUP BY AddressLine1 , PostCode
ORDER BY 3 DESC

SELECT Namad, COUNT(DISTINCT TCScustomerID) 
FROM #Namad
GROUP BY Namad 
ORDER BY 2 DESC
*/


SELECT *
FROM (
SELECT Namad, CustomerID, COUNT(DISTINCT TCSCustomerID) AS CNT
FROM #Namad
WHERE Namad NOT like '%incomp%'
group by  Namad, CustomerID) AS S1
WHERE CNT>3
ORDER BY CNT desc 

SELECT SUM(CNT)
FROM (
SELECT Namad, CustomerID, COUNT(DISTINCT TCSCustomerID) AS CNT
FROM #Namad
WHERE Namad NOT like '%incomp%'
group by  Namad, CustomerID) AS S1
WHERE CNT>3


SELECT SUM(CNT)
FROM (
SELECT Namad, CustomerID, COUNT(DISTINCT TCSCustomerID) AS CNT
FROM #Namad
WHERE Namad NOT like '%incomp%'
group by  Namad, CustomerID) AS S1
WHERE CNT<=3


--627009
IF OBJECT_ID(N'tempdb..#Namad_Matches') IS NOT NULL
DROP TABLE #Namad_Matches
SELECT DISTINCT C1.*
INTO #Namad_Matches
FROM #Source_Customers AS C1
INNER JOIN #Source_Customers AS C2	
	ON C1.CustomerID = C2.CustomerID
	AND C1.TCScustomerID <> C2.TCScustomerID
	--AND C1.forename = C2.forename
	--AND C1.surname = C2.surname
	--AND C1.addressline1 = C2.addressline1
	--AND C1.postcode = C2.postcode
WHERE NOT EXISTS (SELECT * FROM #ParsedAddressMobile2 AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #ParsedAddressMobile1 AS E WHERE C1.CustomerID = E.CustomerID)
AND NOT EXISTS (SELECT * FROM #ParsedAddressMobile AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #EmailMatches AS E WHERE C1.CustomerID = E.CustomerID)

/*
-- 567686
SELECT COUNT(DISTINCT TCScustomerID)
FROM #Namad_Matches
*/



IF OBJECT_ID(N'tempdb..#Namad_Incomplete_Address') IS NOT NULL
DROP TABLE #Namad_Incomplete_Address
SELECT DISTINCT C1.*
INTO #Namad_Incomplete_Address
FROM #Source_Customers AS C1
INNER JOIN #Source_Customers AS C2	
	ON C1.CustomerID = C2.CustomerID
	AND C1.TCScustomerID <> C2.TCScustomerID
	--AND C1.forename = C2.forename
	--AND C1.surname = C2.surname
	--AND C1.addressline1 = C2.addressline1
	--AND C1.postcode = C2.postcode
WHERE NOT EXISTS (SELECT * FROM #ParsedAddressMobile2 AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #ParsedAddressMobile1 AS E WHERE C1.CustomerID = E.CustomerID)
AND NOT EXISTS (SELECT * FROM #ParsedAddressMobile AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #EmailMatches AS E WHERE C1.CustomerID = E.CustomerID)
AND (C1.addressline1 LIKE '%INCOMP%' OR C1.addressline1 IS NULL OR C1.addressline1 = '')


/*
-- 96142 
SELECT COUNT(DISTINCT TCScustomerID)
FROM #Namad_Incomplete_Address
*/

IF OBJECT_ID(N'tempdb..#Namad_Exact_Matches') IS NOT NULL
DROP TABLE #Namad_Exact_Matches
SELECT DISTINCT C1.*
INTO #Namad_Exact_Matches
FROM #Source_Customers AS C1
INNER JOIN #Source_Customers AS C2	
	ON C1.CustomerID = C2.CustomerID
	AND C1.TCScustomerID <> C2.TCScustomerID
	AND C1.forename = C2.forename
	AND C1.surname = C2.surname
	AND C1.addressline1 = C2.addressline1
	AND C1.postcode = C2.postcode
WHERE NOT EXISTS (SELECT * FROM #ParsedAddressMobile2 AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #ParsedAddressMobile1 AS E WHERE C1.CustomerID = E.CustomerID)
AND NOT EXISTS (SELECT * FROM #ParsedAddressMobile AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #EmailMatches AS E WHERE C1.CustomerID = E.CustomerID)
AND C1.addressline1 NOT LIKE '%INCOMP%'
/*
-- 228226 
SELECT COUNT(DISTINCT TCScustomerID)
FROM #Namad_Exact_Matches

SELECT *
FROM #Namad_Exact_Matches
ORDER BY CustomerID

*/


IF OBJECT_ID(N'tempdb..#Namad_NonExact_Matches') IS NOT NULL
DROP TABLE #Namad_NonExact_Matches
SELECT *
INTO #Namad_NonExact_Matches
FROM #Namad AS N
WHERE NOT EXISTS (SELECT * FROM #Namad_Exact_Matches AS NEM WHERE N.TCScustomerID = NEM.TCScustomerID)
AND N.addressline1 NOT LIKE '%INCOMP%'
ORDER BY CustomerID

/*
-- 242418
SELECT COUNT(DISTINCT TCScustomerID)
FROM #Namad_NonExact_Matches
*/

SELECT *
FROM #Namad_NonExact_Matches S0
INNER JOIN (
SELECT Namad, CustomerID, COUNT(DISTINCT TCSCustomerID) AS CNT
FROM #Namad_NonExact_Matches
group by Namad, CustomerID
having COUNT(DISTINCT TCSCustomerID)<=3) AS S
	ON S0.CustomerID = S.CustomerID
ORDER BY S0.CustomerID




IF OBJECT_ID(N'tempdb..#Namad_Exact_Matches') IS NOT NULL
DROP TABLE #Namad_Exact_Matches
SELECT DISTINCT C1.*
INTO #Namad_Exact_Matches
FROM #Source_Customers AS C1
INNER JOIN #Source_Customers AS C2	
	ON C1.CustomerID = C2.CustomerID
	AND C1.TCScustomerID <> C2.TCScustomerID
	AND C1.forename = C2.forename
	AND C1.surname = C2.surname
	AND C1.addressline1 = C2.addressline1
	AND C1.postcode = C2.postcode
WHERE NOT EXISTS (SELECT * FROM #ParsedAddressMobile2 AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #ParsedAddressMobile1 AS E WHERE C1.CustomerID = E.CustomerID)
AND NOT EXISTS (SELECT * FROM #ParsedAddressMobile AS E WHERE C1.CustomerID = E.CustomerID)
AND  NOT EXISTS (SELECT * FROM #EmailMatches AS E WHERE C1.CustomerID = E.CustomerID)

SELECT addressline1, postcode, COUNT(TCSCustomerID) AS CNT
FROM #Namad
GROUP BY addressline1, postcode
ORDER BY 3 DESC

select count(*)
from Staging.STG_Customer
where Salutation = '' or Salutation is null

select count(*)
from Staging.STG_Customer
where DateOfBirth = '' or DateOfBirth is null

select count(distinct TCScustomerID)
from #Source_Customers
where len(surname)=1

select count(distinct TCScustomerID)
from #Source_Customers
where len(addressline1)=0

SELECT *
FROM PreProcessing.TOCPLUS_Customer
WHERE ProcessedInd = 0


SELECT TRY_CAST('01/01/0001 00:00:00' AS DATE)
