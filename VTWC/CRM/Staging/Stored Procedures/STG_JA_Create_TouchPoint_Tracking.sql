CREATE procedure [Staging].[STG_JA_Create_TouchPoint_Tracking]

as
begin

    --set nocount on;

    --if exists (select * from sys.objects where object_id = OBJECT_ID(N'Staging.STG_JA_TouchPoint_Tracking') AND type in (N'U'))
    --    begin
    --        drop table staging.STG_JA_TouchPoint_Tracking
    --    end

    --create table staging.STG_JA_TouchPoint_Tracking (
    --    customerid      integer,
    --    action_datetime datetime,
    --    action_type     varchar(50),
    --    action_subType  varchar(500),
    --    action_detail    varchar(1000)
    --);


    ---- Load Campaign Sends
    --insert into staging.STG_JA_TouchPoint_Tracking (
    --        customerid,
    --        action_datetime,
    --        action_type,
    --        action_subType,
    --        action_detail)

    --select customerid,
    --       contactdatetime,
    --       'Campaign Send',
    --       Campaign_Code,
    --       a.Channel
    --from emm_sys.dbo.UA_ContactHistory a with(nolock)
    --where IsDeleted = 'N'
    --     and ContactStatusID != 3
    --     and CustomerID > 0
    --     and datediff(dd, ContactDateTime, getdate()) <= 120;

    ---- Load Campaign Clicks
    --insert into staging.STG_JA_TouchPoint_Tracking (
    --        customerid,
    --        action_datetime,
    --        action_type,
    --        action_subType,
    --        action_detail)

    --select customerid,
    --       EventTimeStamp,
    --       'Campaign Click',
    --       null,
    --       URL
    --from emm_sandbox.CEM.SP_Click with(nolock)
    --where CustomerID > 0 and datediff(dd, EventTimeStamp, getdate()) <= 120;

    ---- Load Sales
    --insert into staging.STG_JA_TouchPoint_Tracking (
    --        customerid,
    --        action_datetime,
    --        action_type,
    --        action_subType,
    --        action_detail)

    --select customerid,
    --       SalesTransactionDate,
    --       'Ticket Sale',
    --       null,
    --       null
    --from emm_sandbox.cem.vw_Customer_SalesTransaction with(nolock)
    --where datediff(dd, SalesTransactionDate, getdate()) <= 183
    --group by CustomerID, SalesTransactionDate;

    ---- Load Web Data
    ---- THIS NEEDS OPTIMISATION AS IT TAKES WELL OVER AN HOUR
    --insert into staging.STG_JA_TouchPoint_Tracking (
    --        customerid,
    --        action_datetime,
    --        action_type,
    --        action_subType,
    --        action_detail)

    --select customerid,
    --       EventDateTime,
    --       'Website Page View',
    --       SessionID, --New_ContentGroup,
    --       null --PageURL
    --from (
    --        SELECT distinct
    --             [PV].[RawVisitorID]
    --            ,ISNULL([KM].[CustomerID],[C].[CustomerID]) as customerid
    --            ,[PV].[SessionID]
    --            ,[PV].[SessionStartDateTime]
    --            ,[PV].[EventDateTime]
    --            ,[PV].[EventSequence Number] [EventSequenceNumber]
    --            ,[PV].[ContentGroup]
    --            ,[PV].[ContentSubGroup]
    ----             ,[CG].[ContentGroup] [New_ContentGroup]
    ----             ,[CG].[ContentSub-Group] [New_ContentSubGroup]
    --            ,[PV].[PageURL]
    --            ,[PV].[PageTitle]
    --        FROM
    --            webtrends.[Staging].[PageViews] PV with(nolock)
    --            left JOIN webtrends.[Production].[Visitors] V with(nolock) ON V.RawVisitorID = PV.RawVisitorID
    --            left JOIN [CEM].[Staging].[STG_KeyMapping] KM with(nolock) ON KM.WebTISID = ISNULL([PV].[WebTISID], [V].[WebTISID])
    --            LEFT JOIN [CEM].[Production].[Customer] C with(nolock) ON C.EmailAddress = ISNULL(NULLIF(PV.ContactEmail,''), V.ContactEmail)
    ----             left JOIN webtrends.[Staging].[ContentGroups] CG with(nolock) ON PV.PageURL = CG.PageURL
    --        where datediff(dd, pv.EventDateTime, getdate()) <= 65
    --        ) sub
    --where sub.customerid is not null;

    ---- Added to pick up people from WebTrends Archive temporarily
    --insert into staging.STG_JA_TouchPoint_Tracking (
    --        customerid,
    --        action_datetime,
    --        action_type,
    --        action_subType,
    --        action_detail)

    --select customerid,
    --       EventDateTime,
    --       'Website Page View',
    --       SessionID, --New_ContentGroup,
    --       null --PageURL
    --from (
    --        SELECT distinct
    --             [PV].[RawVisitorID]
    --            ,ISNULL([KM].[CustomerID],[C].[CustomerID]) as customerid
    --            ,[PV].[SessionID]
    --            ,[PV].[SessionStartDateTime]
    --            ,[PV].[EventDateTime]
    --            ,[PV].[EventSequence Number] [EventSequenceNumber]
    --            ,[PV].[ContentGroup]
    --            ,[PV].[ContentSubGroup]
    ----             ,[CG].[ContentGroup] [New_ContentGroup]
    ----             ,[CG].[ContentSub-Group] [New_ContentSubGroup]
    --            ,[PV].[PageURL]
    --            ,[PV].[PageTitle]
    --        FROM
    --            webtrends.[Staging].PageViews_archive PV with(nolock)
    --            left JOIN webtrends.[Production].[Visitors] V with(nolock) ON V.RawVisitorID = PV.RawVisitorID
    --            left JOIN [CEM].[Staging].[STG_KeyMapping] KM with(nolock) ON KM.WebTISID = ISNULL([PV].[WebTISID], [V].[WebTISID])
    --            LEFT JOIN [CEM].[Production].[Customer] C with(nolock) ON C.EmailAddress = ISNULL(NULLIF(PV.ContactEmail,''), V.ContactEmail)
    ----             left JOIN webtrends.[Staging].[ContentGroups] CG with(nolock) ON PV.PageURL = CG.PageURL
    --        where datediff(dd, pv.EventDateTime, getdate()) <= 65
    --        ) sub
    --where sub.customerid is not null;

    --create index touchpoint_customer_id on staging.STG_JA_TouchPoint_Tracking (CustomerID);
    --create index touchpoint_action_type on staging.STG_JA_TouchPoint_Tracking (action_type);
    --create index touchpoint_action_date on staging.STG_JA_TouchPoint_Tracking (action_datetime);
	select 1
end