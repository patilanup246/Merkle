create function [Production].[individual_transactions_lxm]
    (@mnths integer)
returns table
as

return
select sub.individualid, count(*) as Transactions
from (
         select a.individualid, a.bookingreference
         from Staging.STG_SalesTransaction a
         where a.SalesTransactionDate > dateadd(mm, -@mnths, getdate())
         group by a.individualid, a.BookingReference
     ) sub
group by sub.individualid