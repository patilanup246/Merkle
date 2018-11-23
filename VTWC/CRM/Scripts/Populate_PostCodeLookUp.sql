IF OBJECT_ID('tempdb..#VTStations', 'U') IS NOT NULL   DROP TABLE #VTStations;  

Select Name        as StationName 
       ,Latitude   as StationLatitude 
       ,Longitude  as StationLongitude 
	   ,LocationID
into #VTStations 
from Reference.Location
where LocationID in ( /* VT Station Locations */
	158 , 232 , 236 , 263 ,	491 , 570 , 503 , 665 ,	681 , 895 , 1005 , 1093 ,	1226 , 1301 , 1480 , 
	1535 ,	1561 , 1699 , 1536 , 1563 ,	958 , 1780 , 1835 , 1916 ,	1917 , 2001 , 2089 , 2073 ,	2137 , 
	2121 , 2219 , 2263 , 2266 , 2428 , 2380 , 2459 ,	2661 , 2618 , 2943 , 2764 ,
	2809 , 2856 , 2964 , 2941 ,	1810, 2513, 2885, 1713, 2529)

IF OBJECT_ID('tempdb..#Coordinates', 'U') IS NOT NULL   DROP TABLE #Coordinates;  

-- Haversine curved line distance, converted to KM
Select   a.PostCodeDistrict 
		,111.045*DEGREES(ACOS(COS(RADIANS(a.Latitude)) * COS(RADIANS(b.StationLatitude)) * 
				 COS(RADIANS(a.Longitude) - RADIANS(b.StationLongitude)) + 
				 SIN(RADIANS(a.Latitude)) * SIN(RADIANS(b.StationLatitude)))) as [KM Distance]
		,b.LocationID
		,b.StationName 
		,a.Latitude  as PostCodeLatitude 
		,a.Longitude as PostCodeLongitude 
		,b.StationLatitude 
		,b.StationLongitude 
into	#Coordinates  
from    Reference.PostCodes    a 
cross join #VTStations   b 

IF OBJECT_ID('tempdb..#Nearest', 'U') IS NOT NULL   DROP TABLE #Nearest;  
-- Take the nearest station by distance in KM
Select * 
into #Nearest 
from ( 
       Select *  
              ,row_number() over(partition by PostCodeDistrict order by [KM Distance]) as RowNum 
       from #Coordinates ) a 
where RowNum = 1 

-- DEBUG
--Select * from #Nearest 
--where PostCodeDistrict like 'B24' 
--or PostCodeDistrict like 'LS2'
--or PostCodeDistrict like 'EH3'  
--or PostCodeDistrict like 'E1W' 
--or PostCodeDistrict like 'BS1' 
--or PostCodeDistrict like 'SY5' 
--or PostCodeDistrict like 'WV7' 
--or PostCodeDistrict like 'NR3' 
--or PostCodeDistrict like 'CF3' 
--or PostCodeDistrict like 'WF1' 
--or PostCodeDistrict like 'SR1' 
--or PostCodeDistrict like 'L1' 
--or PostCodeDistrict like 'DD1' 
--or PostCodeDistrict like 'WA1' 
--or PostCodeDistrict like 'NG1' 
--order by 1

-- ************************
-- Populate Reference table
-- ************************
truncate table [Reference].[LocationPostCodeLookUp]
INSERT INTO [Reference].[LocationPostCodeLookUp]
           ([PostCodeDistrict]
           ,[KMtoNeaarestStation]
           ,[LocationID]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd])
Select a.PostCodeDistrict, b.[KM Distance] [KMtoNearestStation], LocationID,
GETDATE(), 1, GETDATE(), 1, 0
FROM Reference.PostCodes a
inner join #Nearest b on a.PostCodeDistrict=b.PostCodeDistrict

--select count(1) [Matches]
----c.CustomerID, c.NearestStation, b.KMtoNeaarestStation, b.PostCodeDistrict, d.CRSCode, d.Name
--from Staging.STG_Customer c
--inner join Staging.STG_Address a on a.customerid=c.customerid and a.addresstypeid=6 and a.primaryind=1
--inner join Reference.LocationPostCodeLookUp b on b.PostCodeDistrict=
--substring(a.postalcode, 1, case when charindex(' ', a.postalcode)>0 then charindex(' ', a.postalcode)-1 else len(a.postalcode) end)
--inner join Reference.Location d on d.LocationID=b.LocationID
--where c.NearestStation<>d.CRSCode and rtrim(ltrim(c.nearestStation))<>''

--select count(1) [Non Match]
----c.CustomerID, c.NearestStation, b.KMtoNeaarestStation, b.PostCodeDistrict, d.CRSCode, d.Name
--from Staging.STG_Customer c
--inner join Staging.STG_Address a on a.customerid=c.customerid and a.addresstypeid=6 and a.primaryind=1
--inner join Reference.LocationPostCodeLookUp b on b.PostCodeDistrict=
--substring(a.postalcode, 1, case when charindex(' ', a.postalcode)>0 then charindex(' ', a.postalcode)-1 else len(a.postalcode) end)
--inner join Reference.Location d on d.LocationID=b.LocationID
--where c.NearestStation=d.CRSCode and rtrim(ltrim(c.nearestStation))<>''
