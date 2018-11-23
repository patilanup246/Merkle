CREATE function [Production].[customer_spend_lxm]
    (@mnths integer)
returns table
as
return
    select a.customerid, sum(a.salesamountTotal) as total_spend
    from Staging.STG_SalesTransaction a
    where a.SalesTransactionDate > dateadd(mm, -@mnths, getdate())
    group by a.customerid