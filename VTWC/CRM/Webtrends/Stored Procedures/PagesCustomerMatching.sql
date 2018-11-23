CREATE PROC [Webtrends].[PagesCustomerMatching]
AS
BEGIN
    
    update a
    set a.CustomerID = b.CustomerID
    from Staging.PageViews a inner join crm.Staging.STG_KeyMapping b with(nolock) on a.CBE_ID = b.TCSCustomerID
    where a.CustomerID is null;

    update a
    set a.CustomerID = b.CustomerID
    from Staging.PageViews a inner join crm.Production.Customer b on a.ContactEmail = b.EmailAddress
    where a.CustomerID is null;

    -- Cookie to CBE_ID
    update a
    set a.CustomerID = c.CustomerID
    from Staging.PageViews a
         inner join Staging.Visitors b on a.RawVisitorID = b.RawVisitorId
         inner join crm.Staging.STG_KeyMapping c on b.CBE_ID = c.TCSCustomerID      -- b.CBE_ID is varchar,  c.CBECustomer is int
    where a.CustomerID is null
    --and b.CBE_ID != 'WT.z_cbeid';

    -- Cookie to WebTISID     ------ removed until webtrends feed is defined
   -- update a
   -- set a.CustomerID = c.CustomerID
   -- from Staging.PageViews a
   --      inner join Staging.Visitors b on a.RawVisitorID = b.RawVisitorId
   --      inner join crm.Staging.STG_KeyMapping c on CAST(ISNULL(REPLACE(NULLIF(b.ExternalVisitorId,''),'0000-',''),0) AS BIGINT) = c.WebTISID
   -- where a.CustomerID is null
   --     and ISNUMERIC(ISNULL(REPLACE(NULLIF(b.ExternalVisitorId,''),'0000-',''),0)) = 1;

    -- Cookie to Email
    update a
    set a.CustomerID = c.CustomerID
    from Staging.PageViews a
         inner join Staging.Visitors b on a.RawVisitorID = b.RawVisitorId
         inner join crm.Production.Customer c on b.ContactEmail = c.EmailAddress
    where a.CustomerID is null;
end