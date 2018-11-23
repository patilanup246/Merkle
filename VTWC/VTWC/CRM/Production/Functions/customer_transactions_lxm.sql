CREATE function [Production].[customer_transactions_lxm]
    (@mnths integer)
returns table
as

return
select sub.customerid, count(*) as Transactions
from (
         select a.customerid, a.bookingreference
         from Staging.STG_SalesTransaction a
         where a.SalesTransactionDate > dateadd(mm, -@mnths, getdate())
         group by a.customerid, a.BookingReference
     ) sub
group by sub.customerid