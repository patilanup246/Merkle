CREATE procedure [Staging].[STG_JA_Create_ReportTables]
as
BEGIN
select 1
    --if exists (select * from sys.objects where object_id = OBJECT_ID(N'staging.STG_JA_Raw_Sales') AND type in (N'U'))
    --    begin
    --        drop table staging.STG_JA_Raw_Sales;
    --    end;
    --if exists (select * from sys.objects where object_id = OBJECT_ID(N'staging.STG_JA_Sales_Paths') AND type in (N'U'))
    --    begin
    --        drop table staging.STG_JA_Sales_Paths;
    --    end;
    --if exists (select * from sys.objects where object_id = OBJECT_ID(N'staging.STG_JA_NoSales_Paths') AND type in (N'U'))
    --    begin
    --        drop table staging.STG_JA_NoSales_Paths;
    --    end;


    ---- CREATE TABLE WHICH INCLUDES NO SALES
    ---- Group Actions up into one per day (3 minutes to run)
    --with sales_data as (
    --select a.customerid,
    --       LEAD(a.action_datetime, 1, '2016-01-01') over (partition by a.customerid order by a.action_datetime desc) as From_Sale,
    --       a.action_datetime as To_Sale,
    --       a.action_type
    --from staging.STG_JA_TouchPoint_Tracking a
    --where a.action_type = 'Ticket Sale'
    --),

    --journey_data_grouped as (
    --select customerid,
    --       cast(action_datetime as date) as Action_date,
    --       action_type,
    --       max(action_datetime) as Action_datetime
    --from staging.STG_JA_TouchPoint_Tracking
    --group by
    --       customerid,
    --       cast(action_datetime as date),
    --       action_type
    --)

    --select a.customerid,
    --       a.action_datetime,
    --       a.action_type,
    --       b.To_Sale as Last_Sale,
    --       LEAD(a.action_datetime, 1, null) over (partition by a.customerid order by a.action_datetime desc) as Last_Activity
    --into staging.STG_JA_Raw_Sales
    --from journey_data_grouped a
    --     left join sales_data b on a.customerid = b.customerid and a.action_datetime > b.From_Sale and a.action_datetime <= b.To_Sale;

    --create index journey_cust on staging.STG_JA_Raw_Sales(customerid);
    --create index journey_salesdate on staging.STG_JA_Raw_Sales(Last_Sale);
    --create index journey_actiondate on staging.STG_JA_Raw_Sales(action_datetime);

    ---- Journey Paths for sales in last 31 days. Actions must be done within 60 days of sale to count
    --SELECT customerid, Last_Sale,
    --       path = STUFF(
    --             (SELECT ', ' + action_type
    --              FROM staging.STG_JA_Raw_Sales t1
    --              WHERE (t1.customerid = t2.customerid and t1.Last_Sale = t2.Last_Sale)
    --              and datediff(dd, t1.action_datetime, t1.Last_Sale) <= 60
    --              and datediff(dd, t1.Last_Sale, getdate()) <= 31
    --             order by t1.action_datetime asc
    --              FOR XML PATH (''))
    --             , 1, 1, '')
    --into staging.STG_JA_Sales_Paths
    --from staging.STG_JA_Raw_Sales t2
    --where datediff(dd, t2.action_datetime, t2.Last_Sale) <= 60
    --      and datediff(dd, t2.Last_Sale, getdate()) <= 31
    --group by customerid, Last_Sale;

    --create index journey_sales_cust on staging.STG_JA_Sales_Paths(customerid);

    ---- Journey Paths for people who have made no sales in last 60 days
    --with customer_sales as (
    --select customerid from staging.STG_JA_Raw_Sales
    --where action_type = 'Ticket Sale' and datediff(dd, Action_datetime, getdate()) <= 60
    --)

    --SELECT customerid, Last_Sale,
    --       path = STUFF(
    --             (SELECT ', ' + action_type
    --              FROM staging.STG_JA_Raw_Sales t1
    --              WHERE (t1.customerid = t2.customerid)
    --              and datediff(dd, t1.action_datetime, getdate()) <= 60
    --              and not exists (select customerid from customer_sales a where a.customerid=t1.customerid)
    --              order by t1.action_datetime asc
    --              FOR XML PATH (''))
    --             , 1, 1, '')
    --into staging.STG_JA_NoSales_Paths
    --from staging.STG_JA_Raw_Sales t2
    --where datediff(dd, t2.action_datetime, getdate()) <= 60
    --      and not exists (select customerid from customer_sales a where a.customerid=t2.customerid)
    --group by customerid, Last_Sale;

    --create index journey_no_sales_cust on staging.STG_JA_NoSales_Paths(customerid);
END