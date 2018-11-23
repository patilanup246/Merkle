SELECT *
FROM dbo.STATIONS 
WHERE CODE = 'yrk'
WHERE CODE<>GROUP_STATION 

SELECT *
FROM PreProcessing.TOCPLUS_Journey 

select *
from sys.procedures 
order by create_date desc 

SELECT *
FROM Staging.STG_SalesDetail 

select *
from PreProcessing.TOCPLUS_Journey
where tcstransactionid = 2383069686
--where tcsbookingid = 846100736

select *
from PreProcessing.TOCPLUS_Supplements
where TCSTransactionId = 2383069686
--where TCSBookingID = 846100736

SELECT *
FROM PreProcessing.TOCPLUS_Transaction
where TCSTransactionId = 2383069686

SELECT *
FROM PreProcessing.TOCPLUS_Bookings
WHERE purchaseid = 461881504

SELECT *
FROM PreProcessing.TOCPLUS_Journey
WHERE purchaseid = 461881504

SELECT *
FROM PreProcessing.TOCPLUS_JourneyLegs
WHERE journeyid = 461888241

SELECT *
FROM PreProcessing.TOCPLUS_Supplements
where TCSTransactionId = 2383069686