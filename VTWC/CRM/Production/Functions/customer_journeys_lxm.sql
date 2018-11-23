CREATE function [Production].[customer_journeys_lxm]
    (@mnths integer)
returns table
as

return
select sub.customerid, count(*) as Journeys
from (
     select a.customerid, b.OutTravelDate
     from crm.Staging.STG_SalesTransaction a
         inner join (
                     select salestransactionid, outtraveldate
                     from   crm.staging.stg_salesdetail c
                     where  c.istrainticketind = 1 and c.outtraveldate > dateadd(mm, -@mnths, getdate())
                     group by salestransactionid, outtraveldate
                    ) b on a.salestransactionid = b.salestransactionid
         group by a.CustomerID, b.OutTravelDate
     ) sub
group by sub.CustomerID