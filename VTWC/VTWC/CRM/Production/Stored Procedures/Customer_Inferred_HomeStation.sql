CREATE PROCEDURE [Production].[Customer_Inferred_HomeStation]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select customerid, Origin_Station, trips, locationId
into #tmp_loc
from (
    select customerid, origin_station, Trips, loc.LocationID ,DENSE_RANK() OVER (PARTITION BY customerid ORDER BY Trips DESC, Min_Date asc) as rank
    from (
        select CustomerID, Origin_Station, count(1) as Trips, min(SalesTransactionDate) as Min_Date
        from (
            SELECT a.CustomerID                                                 AS CustomerID,
                   a.SalesTransactionID                                                  AS SalesTransactionID,
                   convert(date, CRM.Staging.GetUKTime(c.DepartureDateTime))             AS TravelDate,
                   CASE WHEN f.Name ='London Terminals' THEN 'EUS'
                        WHEN f.name = 'LONDON ST PANCRAS' THEN 'EUS'
                        --WHEN f.Name ='Wakefield Stns' THEN 'WKF'
                        --WHEN f.Name ='GLASGOW CEN/QST' THEN 'GLC'
                        --WHEN f.Name ='NEWARK STATIONS' THEN 'NNG'
                        --WHEN f.Name ='BRADFORD YK STNS' THEN 'BDQ'
                        --WHEN f.Name ='METRO T&W ZONE A' THEN 'NCL'
                        WHEN f.Name like '%LONDN' THEN 'EUS' ELSE f.CRSCode END          AS Origin_Station,
                   f.CRSCode                                                             AS Origin_CRSCode,
                   f.name                                                                AS Origin_Station_Name,
                   cast(SalesTransactionDate as date) as SalesTransactionDate,
                   c.IsReturnInd,
                   c.IsReturnInferredInd
            FROM CRM.Staging.STG_Journey c
                 INNER JOIN CRM.Staging.STG_SalesDetail b         ON c.SalesDetailID = b.SalesDetailID AND IsTrainTicketInd = 1
                 INNER JOIN CRM.Staging.STG_SalesTransaction a    ON a.SalesTransactionID = b.SalesTransactionID
                 INNER JOIN CRM.Reference.Location f              ON f.LocationID = c.LocationIDOrigin
            where datediff(month, cast(SalesTransactionDate as date), cast(getdate() as date)) <= 12
                  and c.IsOutBoundInd = 1 and c.IsReturnInd = 0 and c.IsReturnInferredInd = 0
            ) st
        where Origin_Station is not null
        group by CustomerID, Origin_Station
    ) data left join CRM.Reference.Location loc on data.Origin_Station = loc.CRSCode
) ranked
where rank = 1

update cus
set cus.LocationIDHomeInferred = tmp.locationid
from CRM.Production.Customer cus inner join #tmp_loc tmp on cus.CustomerID = tmp.customerid

end