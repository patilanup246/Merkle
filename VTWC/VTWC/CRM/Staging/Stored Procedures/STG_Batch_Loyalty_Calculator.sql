
CREATE PROCEDURE [Staging].[STG_Batch_Loyalty_Calculator]
  @user int = NULL,
  @CallingSource varchar(5) = 'batch'

as
begin

	declare @NectarPointsPerPound as integer
	declare @VFCMilesPerPound as integer
	declare @informationsourceid as integer
	declare @LoyaltyStatus_Processing as integer
	declare @LoyaltyStatus_Confirmed as integer
	declare @LoyaltyStatus_Refund_Processing as integer
	declare @LoyaltyStatus_Refund_Confirmed as integer

	set @NectarPointsPerPound = 2
	set @VFCMilesPerPound = 2

	select @informationsourceid = InformationSourceID
	from [Reference].[InformationSource]
	where Name = 'CBE'

    select @LoyaltyStatus_Processing = LoyaltyStatusID
    from Reference.LoyaltyStatus
    where Name = 'Processing'

    select @LoyaltyStatus_Confirmed = LoyaltyStatusID
    from Reference.LoyaltyStatus
    where Name = 'Confirmed'

    select @LoyaltyStatus_Refund_Processing = LoyaltyStatusID
    from Reference.LoyaltyStatus
    where Name = 'Refund processing'

    select @LoyaltyStatus_Refund_Confirmed = LoyaltyStatusID
    from Reference.LoyaltyStatus
    where Name = 'Refund confirmed'

/**************************************************************************************************
Batch Records

Get all sales records for last two days (current date - 3)  into #tmp_loyalty_sales
**************************************************************************************************/
if @CallingSource = 'batch'

		select a.SalesTransactionID
            , a.SalesTransactionNumber
            , a.SalesTransactionDate
            , a.CreatedDate
            , a.CustomerID as CRMCustomerID
            , km.TCSCustomerID
            , a.SalesAmountTotal
            , a.LoyaltyReference
            , l.LoyaltyAccountID
            , l.LoyaltyCardSchemeName
            , a.ExtReference
            , numWCLegs = sum(case when d.TOCID = 9 then 1 else 0 end)
            -- There are 42 season products...going to assume anything > 1month is what we are bothered about
            -- There should only be 1 detail record per season purchase so this should resolve to 1/0
            , STInd = sum(case when p.IsSeasonTicketInd = 1
                                    and datediff(month,b.ValidityStartDate, dateadd(day,1,b.ValidityEndDate)) >= 1
                                    --and p.SeasonType = 'B' -- This seems to remove 7-day seasons which can do over datediff
                                then 1
                                else 0 end)
            , DayInd = datediff(dd, convert(date,a.CreatedDate),convert(date,getdate()))

            into #tmp_loyalty_sales
            from Staging.STG_SalesTransaction a with(nolock)
            inner join Staging.STG_SalesDetail b with(nolock) on a.SalesTransactionID = b.SalesTransactionID
            inner join Reference.Product p with(nolock) on b.ProductID = p.ProductID
            inner join Reference.InformationSource e with(nolock) on a.InformationSourceID = e.InformationSourceID and e.Name = 'CBE'
            inner join Staging.STG_KeyMapping km with(nolock) on a.CustomerID = km.CustomerID
            left join Staging.STG_Journey c with(nolock) on b.SalesDetailID = c.SalesDetailID
            left join Staging.STG_JourneyLeg d with(nolock) on c.JourneyID = d.JourneyID
            left join (
                        select
                          la.LoyaltyReference
                        , la.LoyaltyAccountID
                        , lp.Name as LoyaltyCardSchemeName
                        from Staging.STG_LoyaltyAccount la with(nolock)
                        inner join Reference.LoyaltyProgrammeType lp with(nolock) on la.LoyaltyProgrammeTypeID = lp.LoyaltyProgrammeTypeID
                        group by la.LoyaltyReference, la.LoyaltyAccountID, lp.Name
                        ) l on a.LoyaltyReference = l.LoyaltyReference
            left join Staging.STG_LoyaltyAllocation f on a.SalesTransactionID = f.SalesTransactionID

            where
--             Transactions for last 2 days
            convert(date,a.CreatedDate) >= dateadd(day, -3, convert(date,getdate()))
            -- CUT OVER POINT FOR LOYALTY PHASE 2
            and cast(a.CreatedDate as date) >= '2017-06-23'
        --     We're only going to use Nectar for the bulk of this except VFC season tickets
                    and a.LoyaltyReference is not null
            -- Where not already flagged to LoyaltyAllocation
            and f.SalesTransactionID is null
            group by
            a.SalesTransactionID
            , a.SalesTransactionNumber
            , a.SalesTransactionDate
            , a.CreatedDate
            , a.CustomerID
            , km.TCSCustomerID
            , a.SalesAmountTotal
            , a.LoyaltyReference
            , l.LoyaltyAccountID
            , l.LoyaltyCardSchemeName
            , a.ExtReference

/**************************************************************************************************
Get the corresponding Nectar sales detail records                  into #tmp_nectar_detail
***************************************************************************************************/
        select a.*,
               b.SalesDetailID,
               b.SalesAmount
        into #tmp_nectar_detail
        from #tmp_loyalty_sales a inner join Staging.STG_SalesDetail b with(nolock) on a.SalesTransactionID = b.SalesTransactionID
        where
            -- Exclude Season Tickets
            a.STInd = 0
            -- Only transaction with Loyalty Card
            and a.LoyaltyReference is not null and a.LoyaltyCardSchemeName = 'Nectar'
            -- Last few days
            and a.DayInd <= 3
            -- Has VTEC leg - beware, Season Tickets do not have a VTEC leg (no Journey-leg records)
            and a.numWCLegs >= 1

/**************************************************************************************************
Get the VFC sales detail records                  into #tmp_vfc_detail
We don't want Season Tickets here only "normal" tickets.  Unlike for Nectar we are not allocating
the points the day after a ticket is purchased but the after the validity period expires. This
ensures that if a ticket has been refunded we will not be allocating points.
We do it this way because VFC do not have the concept of automated clawing back of points.
In addition - we are checking for existing Loyalty Allocation records at the sales detail level as
it is possible for one sales transaction to contain multiple tickets with different validity periods.
***************************************************************************************************/
        select a.SalesTransactionID
            , a.SalesTransactionNumber
            , b.SalesDetailID
            , b.SalesAmount
            , a.CreatedDate
            , b.ValidityStartDate
            , b.ValidityEndDate
            , a.SalesTransactionDate
            , a.CustomerID as CRMCustomerID
            , km.TCSCustomerID
            , a.SalesAmountTotal
            , a.LoyaltyReference
            , l.LoyaltyAccountID
            , l.LoyaltyCardSchemeName
            , a.ExtReference
            , numWCLegs = sum(case when d.TOCID = 9 then 1 else 0 end)
            -- There are 42 season products...going to assume anything > 1month is what we are bothered about
            -- There should only be 1 detail record per season purchase so this should resolve to 1/0
            , STInd = sum(case when p.IsSeasonTicketInd = 1
                                    and datediff(month,b.ValidityStartDate, dateadd(day,1,b.ValidityEndDate)) >= 1
                                    and p.SeasonType = 'B' -- This seems to remove 7-day seasons which can do over datediff
                                then 1
                                else 0 end)
            , DayInd = datediff(dd, convert(date,b.ValidityEndDate),convert(date,getdate()))

            into #tmp_vfc_detail

            from
            Staging.STG_SalesTransaction a with(nolock)
            inner join Staging.STG_SalesDetail b with(nolock) on a.SalesTransactionID = b.SalesTransactionID
            inner join Reference.Product p on b.ProductID = p.ProductID
            inner join Reference.InformationSource e on a.InformationSourceID = e.InformationSourceID and e.Name = 'CBE'
            inner join Staging.STG_KeyMapping km on a.CustomerID = km.CustomerID
            left join Staging.STG_Journey c with(nolock) on b.SalesDetailID = c.SalesDetailID
            left join Staging.STG_JourneyLeg d with(nolock) on c.JourneyID = d.JourneyID
            left join (
                        select
                          la.LoyaltyReference
                        , la.LoyaltyAccountID
                        , lp.Name as LoyaltyCardSchemeName
                        from Staging.STG_LoyaltyAccount la
                        inner join Reference.LoyaltyProgrammeType lp on la.LoyaltyProgrammeTypeID = lp.LoyaltyProgrammeTypeID
                        group by la.LoyaltyReference, la.LoyaltyAccountID, lp.Name
                        ) l on a.LoyaltyReference = l.LoyaltyReference
            left join Staging.STG_LoyaltyAllocation f on b.SalesDetailID = f.SalesDetailID

            where
            -- Transactions for last few days
            convert(date,b.ValidityEndDate) between dateadd(day, -3, convert(date,getdate())) and dateadd(day, -1, convert(date,getdate()))
            -- CUT OVER POINT FOR PHASE 2
                and cast(a.CreatedDate as date) >= '2017-06-23'
        --     Only transactions with a VFC Loyalty Card
                and a.LoyaltyReference is not null
                and a.LoyaltySchemeName like 'Virgin%'
            -- Where not already flagged to LoyaltyAllocation
            and f.SalesDetailID is null
            group by
              a.SalesTransactionID
            , a.SalesTransactionNumber
            , b.SalesDetailID
            , b.SalesAmount
            , a.CreatedDate
            , b.ValidityStartDate
            , b.ValidityEndDate
            , a.SalesTransactionDate
            , a.CustomerID
            , km.TCSCustomerID
            , a.SalesAmountTotal
            , a.LoyaltyReference
            , l.LoyaltyAccountID
            , l.LoyaltyCardSchemeName
            , a.ExtReference
            having sum(case when p.IsSeasonTicketInd = 1
                                    and datediff(month,b.ValidityStartDate, dateadd(day,1,b.ValidityEndDate)) >= 1
                                    and p.SeasonType = 'B' -- This seems to remove 7-day seasons which can do over datediff
                                then 1
                                else 0 end) = 0

/**************************************************************************************************
Use the sales details record to work out the 'missing' money due to rounding of each sales
    detail transaction                                          into #tmp_nectar_missing_spend

To ensure if everything gets refunded if all tickets are cancelled we will assign these points with
the lowest salesdetailid from the transaction.  This might mean cancelling one ticket only loses a handful
of points more but if all tickets are cancelled it will get picked up.
***************************************************************************************************/
		select a.CRMCustomerID,
		       a.SalesTransactionId,
               floor(a.SalesAmountTotal) as Total_Eligible_Spend,
               a.LoyaltyCardSchemeName,
               a.LoyaltyAccountId,
               sum(floor(b.SalesAmount)) as Total_Eligible_Sales_Detail_Spend,
               floor(a.SalesAmountTotal) - sum(floor(b.SalesAmount)) as Missing_Spend,
               min(b.SalesDetailID) as SalesDetailID
        into #tmp_nectar_missing_spend
        from #tmp_loyalty_sales a inner join #tmp_nectar_detail b on a.SalesTransactionID = b.SalesTransactionID and b.LoyaltyCardSchemeName = 'Nectar'
        where a.numWCLegs >= 1
        group by a.CRMCustomerID,
                 a.SalesTransactionId,
                 floor(a.SalesAmountTotal),
                 a.LoyaltyCardSchemeName,
                 a.LoyaltyAccountId
        having floor(a.SalesAmountTotal) - sum(floor(b.SalesAmount)) != 0

/**************************************************************************************************
Write non-season ticket loyalty allocations from
        Sales Detail Info
        Missing Spend Table

* Exclude Season Tickets - we do those later
* Insert 1 record per SalesDetail record to make tracking refunds easier
* Apply a VTEC-leg check
**************************************************************************************************/
        -- LOYALTY POINTS FROM SALES DETAIL TRANSACTIONS
        insert into Staging.STG_LoyaltyAllocation(
            Name
            ,Description
            ,CreatedDate
            ,CreatedBy
            ,LastModifiedDate
            ,LastModifiedBy
            ,ArchivedInd
            ,SourceCreatedDate
            ,SourceModifiedDate
            ,LoyaltyStatusID
            ,LoyaltyAccountID
            ,SalesTransactionID
            ,SalesTransactionDate
            ,SalesDetailID
            ,LoyaltyXChangeRateID
            ,QualifyingSalesAmount
            ,LoyaltyCurrencyAmount
            ,InformationSourceID
            ,ExtReference)

        select a.LoyaltyCardSchemeName
               ,case when a.LoyaltyCardSchemeName = 'Nectar' then CONCAT('Collected points ', a.SalesTransactionNumber)
                    when a.LoyaltyCardSchemeName in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2', 'Virgin Flying Club') then CONCAT('Collected miles ', a.SalesTransactionNumber) end
               ,getdate()
               ,0
               ,getdate()
               ,0
               ,0
               ,a.SalesTransactionDate
               ,a.SalesTransactionDate
               ,@LoyaltyStatus_Processing -- Status = Processing - We pay immediately and clawback if canx/refunded
               ,a.LoyaltyAccountID
               ,a.SalesTransactionId
               ,a.SalesTransactionDate
               ,b.SalesDetailID
               ,case when a.LoyaltyCardSchemeName = 'Virgin Flying Club' then @VFCMilesPerPound
                    when a.LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
                    else 0 end
               ,b.SalesAmount
               ,floor(b.SalesAmount) * (case
									when a.LoyaltyCardSchemeName = 'Virgin Flying Club' then @VFCMilesPerPound
									when a.LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
									else 0 end)
               ,@informationsourceid
               ,a.ExtReference
        from #tmp_loyalty_sales a
		inner join #tmp_nectar_detail b on a.SalesTransactionID = b.SalesTransactionID
		where
		-- Exclude Season Tickets
		a.STInd = 0
		-- Only transaction with Nectar Card
		and a.LoyaltyReference is not null and a.LoyaltyCardSchemeName = 'Nectar'
		-- Last few days
-- 		and a.DayInd <= 3
		-- Has VTEC leg - beware, Season Tickets do not have a VTEC leg (no Journey-leg records)
		and a.numWCLegs >= 1

        -- LOYALTY POINTS FROM ROUNDED SPEND CORRECTION
        insert into Staging.STG_LoyaltyAllocation(
             Name
            ,Description
            ,CreatedDate
            ,CreatedBy
            ,LastModifiedDate
            ,LastModifiedBy
            ,ArchivedInd
            ,SourceCreatedDate
            ,SourceModifiedDate
            ,LoyaltyStatusID
            ,LoyaltyAccountID
            ,SalesTransactionID
            ,SalesTransactionDate
            ,SalesDetailID
            ,LoyaltyXChangeRateID
            ,QualifyingSalesAmount
            ,LoyaltyCurrencyAmount
            ,InformationSourceID
            ,ExtReference)

        select a.LoyaltyCardSchemeName
               ,case when a.LoyaltyCardSchemeName = 'Nectar' then CONCAT('Collected points ', a.SalesTransactionNumber)
                    when a.LoyaltyCardSchemeName in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2', 'Virgin Flying Club') then CONCAT('Collected miles ', a.SalesTransactionNumber) end
               ,getdate()
               ,0
               ,getdate()
               ,0
               ,0
               ,a.SalesTransactionDate
               ,a.SalesTransactionDate
               ,@LoyaltyStatus_Processing -- Status = Processing - We pay immediately and clawback if canx/refunded
               ,a.LoyaltyAccountID
               ,a.SalesTransactionId
               ,a.SalesTransactionDate
               ,b.SalesDetailID
               ,case when a.LoyaltyCardSchemeName = 'Virgin Flying Club' then @VFCMilesPerPound
                    when a.LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
                    else 0 end
               ,b.Missing_Spend
               ,floor(b.Missing_Spend) * (case
									when a.LoyaltyCardSchemeName = 'Virgin Flying Club' then @VFCMilesPerPound
									when a.LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
									else 0 end)
               ,@informationsourceid
               ,a.ExtReference
        from #tmp_loyalty_sales a inner join #tmp_nectar_missing_spend b on a.SalesTransactionID = b.SalesTransactionId
		where
		-- Exclude Season Tickets
		a.STInd = 0
		-- Only transaction with Loyalty Card
		and a.LoyaltyReference is not null and a.LoyaltyCardSchemeName = 'Nectar'
		-- Last Few Days
-- 		and a.DayInd <= 3
		-- Has VTEC leg - beware, Season Tickets do not have a VTEC leg (no Journey-leg records)
		and a.numWCLegs >= 1

/**************************************************************************************************
		FLAG ANY REFUNDS AT SALES DETAIL LEVEL SO WE KNOW WHAT WE WANT TO CLAW BACK
		IN THE CASE OF VFC WE ONLY PAY WHERE NO REFUND IS THERE
**************************************************************************************************/
        select a.RefundID,
               b.RefundDetailID,
               a.RefundDate,
               a.SalesTransactionID,
               b.SalesDetailID
        into #tmp_refunds_to_check
        from Staging.STG_Refund a inner join Staging.STG_RefundDetail b on a.RefundID = b.RefundID
        where (b.RefundReason != 'MTicket reissue' or b.RefundReason is null)
             and convert(date, a.RefundDate) >= dateadd(day, -30, convert(date,getdate()))  -- We could tighten this up in the final release
             and cast(a.RefundDate as date) >= '2017-06-23'
        group by a.RefundID,        -- This ensures we strip out any duplicates
                 b.RefundDetailID,
                 a.RefundDate,
                 a.SalesTransactionID,
                 b.SalesDetailID

        --- PULL OUT ANY NECTAR TRANSACTIONS FROM LOYALTY THAT WILL NEED TO BE REFUNDED
        -- NEED TO LIMIT THIS TO PHASE 2 PEOPLE I THINK
        select a.*
        into #tmp_nectar_refunds
        from Staging.STG_LoyaltyAllocation a inner join Reference.InformationSource b on a.InformationSourceID = b.InformationSourceID and b.Name = 'CBE'
        inner join #tmp_refunds_to_check c on a.SalesDetailID = c.SalesDetailID
        left join Staging.STG_LoyaltyAllocation d on a.SalesDetailID = d.SalesDetailID and d.LoyaltyStatusID in (@LoyaltyStatus_Refund_Confirmed, @LoyaltyStatus_Refund_Processing)
        where a.LoyaltyStatusID = @LoyaltyStatus_Confirmed
              and a.SalesDetailID is not null
              and a.Name = 'Nectar'
              and d.SalesDetailID is null

/**************************************************************************************************
		Insert Nectar refunds into the data to be clawed back
**************************************************************************************************/
        insert into Staging.STG_LoyaltyAllocation(
                    Name
                    ,Description
                    ,CreatedDate
                    ,CreatedBy
                    ,LastModifiedDate
                    ,LastModifiedBy
                    ,ArchivedInd
                    ,SourceCreatedDate
                    ,SourceModifiedDate
                    ,LoyaltyStatusID
                    ,LoyaltyAccountID
                    ,SalesTransactionID
                    ,SalesTransactionDate
                    ,SalesDetailID
                    ,LoyaltyXChangeRateID
                    ,QualifyingSalesAmount
                    ,LoyaltyCurrencyAmount
                    ,InformationSourceID
                    ,ExtReference)

                select a.Name
                       ,a.Description
                       ,getdate()
                       ,0
                       ,getdate()
                       ,0
                       ,0
                       ,a.SalesTransactionDate
                       ,a.SalesTransactionDate
                       ,@LoyaltyStatus_Refund_Processing -- Status = RefundProcessing
                       ,a.LoyaltyAccountID
                       ,a.SalesTransactionId
                       ,a.SalesTransactionDate
                       ,a.SalesDetailID
                       ,a.LoyaltyXChangeRateID
                       ,-1 * a.QualifyingSalesAmount
                       ,-1 * a.LoyaltyCurrencyAmount
                       ,@informationsourceid
                       ,a.ExtReference
                from #tmp_nectar_refunds a
                where a.LoyaltyAccountID is not null and a.Name = 'Nectar'

/**************************************************************************************************
        Insert VFC qualifying transactions but only where they have not been refunded
**************************************************************************************************/
        insert into Staging.STG_LoyaltyAllocation(
                    Name
                    ,Description
                    ,CreatedDate
                    ,CreatedBy
                    ,LastModifiedDate
                    ,LastModifiedBy
                    ,ArchivedInd
                    ,SourceCreatedDate
                    ,SourceModifiedDate
                    ,LoyaltyStatusID
                    ,LoyaltyAccountID
                    ,SalesTransactionID
                    ,SalesTransactionDate
                    ,SalesDetailID
                    ,LoyaltyXChangeRateID
                    ,QualifyingSalesAmount
                    ,LoyaltyCurrencyAmount
                    ,InformationSourceID
                    ,ExtReference)

                select a.LoyaltyCardSchemeName
                       ,case when a.LoyaltyCardSchemeName = 'Nectar' then CONCAT('Collected points ', a.SalesTransactionNumber)
                            when a.LoyaltyCardSchemeName in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2', 'Virgin Flying Club') then CONCAT('Collected miles ', a.SalesTransactionNumber) end
                       ,getdate()
                       ,0
                       ,getdate()
                       ,0
                       ,0
                       ,a.SalesTransactionDate
                       ,a.SalesTransactionDate
                       ,@LoyaltyStatus_Processing -- Status = Earned - We pay as the validity period has now passed
                       ,a.LoyaltyAccountID
                       ,a.SalesTransactionId
                       ,a.SalesTransactionDate
                       ,a.SalesDetailID
                       ,case when a.LoyaltyCardSchemeName = 'Virgin Flying Club' then @VFCMilesPerPound
                            when a.LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
                            else 0 end
                       ,a.SalesAmount
                       ,ceiling(a.SalesAmount) * (case
                                            when a.LoyaltyCardSchemeName = 'Virgin Flying Club' then @VFCMilesPerPound
                                            when a.LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
                                            else 0 end)
                       ,@informationsourceid
                       ,a.ExtReference
                from #tmp_vfc_detail a left join #tmp_refunds_to_check b on a.SalesDetailID = b.SalesDetailID

                where
                -- Exclude Season Tickets
                a.STInd = 0
                -- Only transaction with VFC Card
                and a.LoyaltyReference is not null and a.LoyaltyCardSchemeName in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2', 'Virgin Flying Club')
                -- Last few days
--         		and a.DayInd <= 3
                -- Has VTEC leg - beware, Season Tickets do not have a VTEC leg (no Journey-leg records)
                and a.numWCLegs >= 1
                -- And ticket has not been refunded
                and b.SalesDetailID is null

/**************************************************************************************************
Pull out season ticket sales from the sales record table    into #tmp_season
**************************************************************************************************/
        select a.SalesTransactionID
             , a.SalesTransactionNumber
             , a.SalesTransactionDate
             , b.SalesDetailID
             , a.CRMCustomerID
             , a.CBECustomerID
             , a.SalesAmountTotal
             , a.LoyaltyAccountID
             , a.LoyaltyCardSchemeName
             , a.LoyaltyReference
             , cast(b.ValidityStartDate as date) as TicketStartDate
             , cast(b.ValidityEndDate as date) as TicketEndDate
             , a.ExtReference
        into #tmp_season
        from #tmp_loyalty_sales a
        -- There should only ever be 1 detail record for a season ticket               VALIDATED WITH THE DATA WE HAVE MC
        inner join Staging.STG_SalesDetail b on a.SalesTransactionID = b.SalesTransactionID
        left join Staging.STG_LoyaltySeason_Summary c on a.SalesTransactionID = c.SalesTransactionID
        -- Season Tickets
        where a.STInd = 1
        -- With Loyalty
         and a.LoyaltyReference is not null
        -- Last few days
        and a.DayInd <= 3
        -- And not already processed
        and c.SalesTransactionID is null

/**************************************************************************************************
Calculate installments for season ticket sales              into #tmp_SeasonTicketSummary
**************************************************************************************************/
        select CRMCustomerID
             , CBECustomerID
             , CreatedDate = getdate()
             , SalesTransactionID
             , SalesTransactionNumber
             , SalesTransactionDate
             , SalesAmountTotal
             , LoyaltyPoints
             , LoyaltyCardSchemeName
             , LoyaltyAccountID
             , Term
             , First_Month_Days_Valid
             , First_Inst_Due
             , First_Inst = case when floor(First_Month_Days_Valid / Days_In_First_Month * RegInst) > RegInst then RegInst else floor(First_Month_Days_Valid / Days_In_First_Month * RegInst) end
             , RegInst
             , FinalInst = LoyaltyPoints
                   - (case when floor(First_Month_Days_Valid / Days_In_First_Month * RegInst) > RegInst then RegInst else floor(First_Month_Days_Valid / Days_In_First_Month * RegInst) end)
                   - (floor(LoyaltyPoints / Term) * (Term - 1))
             , FinalInst_Due = dateadd(month, Term, First_Inst_Due)
             , ChkSum = case when floor(First_Month_Days_Valid / Days_In_First_Month * RegInst) + RegInst * (Term - 1) +
                                  LoyaltyPoints - floor(First_Month_Days_Valid / Days_In_First_Month * RegInst) -
                                  (floor(LoyaltyPoints / Term) * (Term - 1)) -
                                  LoyaltyPoints = 0 then 1 else 0 end
             , ExtReference
             into #tmp_SeasonTicketSummary
             from (
             select s1.*
                    ,RegInst = floor(LoyaltyPoints / Term)
                    ,Last_Inst_Due = dateadd(month, term, First_Inst_Due)

                 from
                 (
                    select CRMCustomerID
                    , CBECustomerID
                    , SalesTransactionID
                    , SalesTransactionNumber
                    , SalesTransactionDate
                    , SalesAmountTotal
                    , LoyaltyPoints = floor(SalesAmountTotal) * (case
                                when LoyaltyCardSchemeName = 'Nectar' then 2
                                when LoyaltyCardSchemeName = 'Virgin Flying Club' then 2
                                else 2 end)
                    , Term = CASE datediff(day, TicketStartDate, TicketEndDate)
							 WHEN 6 THEN round(datediff(day, TicketStartDate, TicketEndDate) / 7.0, 0) -- 7-day season tickets
							 ELSE round(datediff(day, TicketStartDate, TicketEndDate) / 30.0, 0)
							 END
                    , TicketStartDate
                    , TicketEndDate
                    , First_Month_Days_Valid = cast(datediff(day, cast(TicketStartDate as date), EOMONTH(TicketStartDate)) + 1 as float)
                    , Days_In_First_Month = datediff(day, DATEFROMPARTS(YEAR(TicketStartDate), MONTH(TicketStartDate), 1), EOMONTH(TicketStartDate))
                    , First_Inst_Due = DATEADD(day, 1, EOMONTH(TicketStartDate))
                    , LoyaltyCardSchemeName
                    , LoyaltyAccountID
                    , ExtReference
                    from #tmp_season
                 ) s1
             ) s2

/**************************************************************************************************
Insert Season Ticket summary into table                     into Staging.STG_LoyaltySeason_Summary
**************************************************************************************************/
        insert into Staging.STG_LoyaltySeason_Summary (
                    Name
                    , CreatedDate
                    , CreatedBy
                    , LastModifiedDate
                    , LastModifiedBy
                    , ArchivedInd
                    , SourceCreatedDate
                    , SourceModifiedDate
                    , CustomerID
                    , CBECustomerID
                    , SalesTransactionID
                    , SalesTransactionNumber
                    , SalesDetailID
                    , LoyaltyAccountID
                    , SalesTransactionDate
                    , OriginalSalesAmount
                    , LoyaltyPoints
                    , LoyaltyCardSchemeName
                    , ExtReference
                    , LoyaltyStatusID
                    , Term
                    , FirstInstDate
                    , LastInstDate
                    , FirstInstAmount
                    , RegularInstAmount
                    , FinalInstAmount
                    )

                select a.LoyaltyCardSchemeName
                    , getdate()
                    , 0
                    , getdate()
                    , 0
                    , 0
                    , a.SalesTransactionDate
                    , a.SalesTransactionDate
                    , a.CRMCustomerID
                    , a.CBECustomerID
                    , a.SalesTransactionID
                    , a.SalesTransactionNumber
                    , b.SalesDetailID
                    , a.LoyaltyAccountID
                    , a.SalesTransactionDate
                    , b.SalesAmount
                    , a.LoyaltyPoints
                    , a.LoyaltyCardSchemeName
                    , a.ExtReference
                    , 1 -- status = pending (set to 2 once all insts paid)
                    , a.Term
                    , a.First_Inst_Due
                    , a.FinalInst_Due
                    , a.First_Inst
                    , a.RegInst
                    , a.FinalInst

                from #tmp_SeasonTicketSummary a
                -- Only 1 SalesDetail record created for a Season Ticket
                inner join Staging.STG_SalesDetail b on a.SalesTransactionID = b.SalesTransactionID


/**************************************************************************************************
Create N installment records for season tickets             into #tmp_SeasonInsts
**************************************************************************************************/
        ;
    -- Semi-colon above required before a CTE
    -- Recursive CTE to generate instalment records
        with summCTE as (
            select CRMCustomerID
            , CBECustomerID
            , SalesTransactionID
            , SalesTransactionDate
            , LoyaltyCardSchemeName
            , LoyaltyAccountID
            , Term
            , First_Inst_Due as InstDate
            , InstAmount = cast(First_Inst as int)
            , InstNum = cast(1 as int)
            from
            #tmp_SeasonTicketSummary
            union all
            select s2.CRMCustomerID
            , s2.CBECustomerID
            , s2.SalesTransactionID
            , s2.SalesTransactionDate
            , s2.LoyaltyCardSchemeName
            , s2.LoyaltyAccountID
            , s.Term
            , InstDate = dateadd(month,1,s.InstDate)
            , InstAmount = cast(case when s.InstNum < s.Term then s2.RegInst else s2.FinalInst end as int)
            , InstNum = s.InstNum + 1
            from
            #tmp_SeasonTicketSummary s2
            inner join summCTE s on s.CRMCustomerID = s2.CRMCustomerID
                                    and InstNum < s.Term + 1
                                    and s.SalesTransactionID = s2.SalesTransactionID
            )
            -- Park the instalment records into #tmp_SeasonInsts
            select su.LoyaltySeasonTicketID
            , cte.SalesTransactionID
            , cte.SalesTransactionDate
            , cte.CRMCustomerID
            , cte.CBECustomerID
            , cte.LoyaltyCardSchemeName
            , cte.LoyaltyAccountID
            , cte.Term
            , cte.InstDate
            , cte.InstAmount
            , cte.InstNum
            , ProcessedInd = cast(0 as bit)
            , ProcessedDate = cast(null as date)
            into #tmp_SeasonInsts
            from summCTE cte
            -- Join out to get the FK
            inner join Staging.STG_LoyaltySeason_Summary su on cte.CRMCustomerID = su.CustomerID
                                                      and cte.SalesTransactionID = su.SalesTransactionID
                                                      and cte.CBECustomerID = su.CBECustomerID

/**************************************************************************************************
Insert Season Ticket installments into table                into Staging.STG_LoyaltySeason_Installments
**************************************************************************************************/
        insert into Staging.STG_LoyaltySeason_Instalments (
                CreatedDate
                , CreatedBy
                , LastModifiedDate
                , LastModifiedBy
                , ArchivedInd
                , SourceCreatedDate
                , SourceModifiedDate
                , LoyaltySeasonTicketID
                , CustomerID
                , CBECustomerID
                , InstalmentDate
                , InstalmentAmount
                , ProcessedInd
                , ProcessedDate
                , LoyaltyStatusID
                )

            select getdate()
                , 0
                , getdate()
                , 0
                , 0
                , SalesTransactionDate
                , SalesTransactionDate
                , LoyaltySeasonTicketID
                , CRMCustomerID
                , CBECustomerID
                , InstDate
                , InstAmount
                , 0
                , cast(null as date)
                , 1 -- Status = Pending
            from #tmp_SeasonInsts

/**************************************************************************************************
    Check for season ticket installments to process
        First check if transaction refunded. If so update Summary & Installment tables
**************************************************************************************************/
            -- Update Summary
         update a
         set
         LoyaltyStatusID = 5 -- status = Cancelled/Refunded
         , LastModifiedDate = getdate()
         , LastModifiedBy = 0
         from
         Staging.STG_LoyaltySeason_Summary a
         -- Join to refunded transactions
         inner join #tmp_refunds_to_check b on a.SalesTransactionID = b.SalesTransactionID
                                             and a.SalesDetailID = b.SalesDetailID
         where
         -- pending
         a.LoyaltyStatusID = 1

    --         Then update instalments
         update a
         set ProcessedInd = 1
         , ProcessedDate = convert(date,getdate())
         , LastModifiedDate = getdate()
         , LoyaltyStatusID = 5 -- status = Cancelled/Refunded
         from
         Staging.STG_LoyaltySeason_Instalments a
         inner join Staging.STG_LoyaltySeason_Summary b on a.LoyaltySeasonTicketID = b.LoyaltySeasonTicketID
                                                         and b.LoyaltyStatusID = 5
         where a.ProcessedInd = 0
         and a.LoyaltyStatusID = 1 -- pending

/**************************************************************************************************
        Write today's season ticket allocations
**************************************************************************************************/
        insert into Staging.STG_LoyaltyAllocation(
                Name
                ,Description
                ,CreatedDate
                ,CreatedBy
                ,LastModifiedDate
                ,LastModifiedBy
                ,ArchivedInd
                ,SourceCreatedDate
                ,SourceModifiedDate
                ,LoyaltyStatusID
                ,LoyaltyAccountID
                ,SalesTransactionID
                ,SalesTransactionDate
                ,SalesDetailID
                ,LoyaltyXChangeRateID
                ,QualifyingSalesAmount
                ,LoyaltyCurrencyAmount
                ,InformationSourceID
                ,ExtReference)

                select b.LoyaltyCardSchemeName
                       ,case when b.name = 'Nectar' then CONCAT('Season Ticket points instalment ', b.SalesTransactionNumber)
                             when b.name in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2', 'Virgin Flying Club') then CONCAT('Season Ticket miles instalment ', b.SalesTransactionNumber) end
                       ,getdate()
                       ,0
                       ,getdate()
                       ,0
                       ,0
                       ,getdate()
                       ,getdate()
                       ,2 -- Status = Earned
                       ,b.LoyaltyAccountID
                       ,b.SalesTransactionId
                       ,b.SalesTransactionDate
                       ,b.SalesDetailID
                       ,case when b.LoyaltyCardSchemeName = 'Virgin Flying Club' then @VFCMilesPerPound
                             when b.LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
                            else 0 end
                       ,b.OriginalSalesAmount
                       ,a.InstalmentAmount
                       ,@informationsourceid
                       ,b.ExtReference
                from
                Staging.STG_LoyaltySeason_Instalments a
                inner join Staging.STG_LoyaltySeason_Summary b on a.LoyaltySeasonTicketID = b.LoyaltySeasonTicketID
                where a.InstalmentDate = convert(date, getdate())
                and ProcessedInd = 0
                and ProcessedDate is null
                and a.InstalmentAmount > 0  -- This gets rid of the odd rogue record where there's a 0 amount for final payment

/**************************************************************************************************
Now we update today's instalment records as paid & Summary when all insts paid

We will mark installments as "PAID" rather than "Processing" simply to make the calculations easier and remove the need
for our Python fulfilment script to perform significant extra processing.
***************************************************************************************************/
        update a
            set
            a.ProcessedInd = 1
            , a.ProcessedDate = convert(date,getdate())
            , a.LastModifiedDate = getdate()
            , a.LoyaltyStatusID = 4 -- Paid
            from
            Staging.STG_LoyaltySeason_Instalments a
            where
            a.InstalmentDate = convert(date, getdate())
            and ProcessedInd = 0
            and ProcessedDate is null
            and LoyaltyStatusID = 1

        -- Now update parent records if all instalments paid/cancelled
        update a
            set
            a.LoyaltyStatusID = 2 -- Processing
            , a.LastModifiedDate = getdate()
            from
            Staging.STG_LoyaltySeason_Summary a
            inner join (
                        select
                        LoyaltySeasonTicketID
                        , CompInsts = sum(cast(ProcessedInd as int))
                        from
                        Staging.STG_LoyaltySeason_Instalments
                        group by
                        LoyaltySeasonTicketID
                        ) b on a.LoyaltySeasonTicketID = b.LoyaltySeasonTicketID
            where
            b.CompInsts = a.Term + 1
            -- The parent records we want to update should all show as Pending
            and a.LoyaltyStatusID = 1

        -- Now update parent records if all instalments confirmed
        -- This will update the day after the final instalment is paid by Python
        update a
            set
            a.LoyaltyStatusID = 4 -- Confirmed
            ,a.LastModifiedDate = getdate()
            from
            Staging.STG_LoyaltySeason_Summary a
            inner join (
                        select
                        LoyaltySeasonTicketID
                        , CompInsts = sum(cast(ProcessedInd as int))
                        from
                        Staging.STG_LoyaltySeason_Instalments
                        where LoyaltyStatusID = 4 -- confirmed
                        group by
                        LoyaltySeasonTicketID
                        ) b on a.LoyaltySeasonTicketID = b.LoyaltySeasonTicketID
            where
            b.CompInsts = a.Term + 1
            -- The parent records we want to update should all show as Pending
            and a.LoyaltyStatusID = 2


/**************************************************************************************************
Now we find Bonus awards linked to batch transactions.  These are recorded by Interact.
These could be Fare Augmentation or outbound-lead Loyalty Bonus awards

* This Bonus won't be tied to a specific SalesDetail record - all we'll have is a transaction reference
so we need to create a separate row in LoyaltyAllocation.  Only if all parts of the transaction are
refunded do we clawback points.

ASSUMPTION - we don't care whether VTEC-leg or not...that rule will be applied via Interact insofar
as the incentive will be based on booking a VTEC journey.

UPDATED for v5 2017-09-14

**************************************************************************************************
EXPLANATION

First we create a tmp table containing candidate entries from across the various Interact CH & RH tables.
The reason we have to do this is down to the sequence of API calls & the way in which the
customer can interact with the website.

If a customer browses without logging in we may present an offer as a visitor.  When they login to purchase
unless another getOffers call is made the treatment code still relates to the visitor audience & will
create an entry in Visitor CH/RH because that is where the original contact is recorded.  This will happen
where multiple offers are presented during the purchase flow &, for example, it is the earlier (visitor) offer that
is persisted through.

If a customer logs in before being presented with an offer all is well & CH/RH entries will be at the
customer-level.

Then there is the hybrid scenario where a CBE DCH record is created for the ConfirmationPage but everything else
exists in Visitor.

Luckily the SalesTransactionNumber is passed over (at least for Loyalty Bonuses).

The only way of handling these 3 scenarios is to look in all 3 places where a response might be lurking.
Note - you can't just join CBE DCH to Visitor using the sessionid as this risks losing records that only appear in Visitor,
plus a join across 2 varchar(3000) attributes doesn't feel like a good idea for production volumes.

So, first we go and grab all the candidate records and park them some where safe...this makes sense because 
we then need to join to SalesTransactions & I don't recommend doing that at the same time as querying
3 potentially large contact & response history tables.

***************************************************************************************************/

/**************************************************************************************************
select
CBE_CustomerID
, SalesTransactionNumber
, Src 
, ResponseDateTime
, Loyalty_Points_Inbound
, Loyalty_Points_Outbound
, Loyalty_Type_Outbound
, Loyalty_Type_Inbound

into #tmp_loyalty_chrh 

from ( 
	select
	rh.CBE_CustomerID
	, rh.Sales_Transaction_Number as SalesTransactionNumber
	, rh.Src 
	, rh.CHRHEntryDate as ResponseDateTime
	, isnull(rh.Loyalty_Points_Inbound,0) as Loyalty_Points_Inbound
	, isnull(rh.Loyalty_Points_Outbound,0) as Loyalty_Points_Outbound
	, rh.Loyalty_Type_Outbound
	, rh.Loyalty_Type_Inbound
	, row_number()over(partition by rh.Sales_Transaction_Number order by rh.CHRHEntryDate desc) as rownum
	from (		  
		  -- First we get properly recorded responses
		  select 
		  crh.CBE_CustomerID
		  , crh.Sales_Transaction_Number
		  , 'CRH' as Src
		  , CHRHEntryDate = crh.ResponseDateTime
		  , crh.Loyalty_Points_Inbound
		  , crh.Loyalty_Points_Outbound
		  , crh.Loyalty_Type_Outbound
		  , crh.Loyalty_Type_Inbound
		  from [emm_sys].[dbo].[UA_CBECustomer_ResponseHistory] crh
		  where (Loyalty_Points_Inbound > 0 or Loyalty_Points_Outbound > 0)
		  and crh.Sales_Transaction_Number IS NOT NULL
		  -- Lets put some date boundaries on this to help the optimizer
		  and crh.ResponseDateTime >= dateadd(dd, -180, getdate())

		  -- Now we look at DCH for ConfirmationPage entries
	union all

		  select 
		  dch.CBE_CustomerID
		  , dch.Sales_Transaction_Number
		  , 'DCH' as Src 
		  , CHRHEntryDate = dch.ContactDateTime
		  , dch.Loyalty_Points_Inbound
		  , dch.Loyalty_Points_Outbound
		  , dch.Loyalty_Type_Outbound
		  , dch.Loyalty_Type_Inbound
		  from [emm_sys].[dbo].[UA_CBECustomer_DtlContactHist] dch
		  where 
		  dch.uaciinteractionpointname = 'ConfirmationPage_IP1'
		  and (dch.Loyalty_Points_Inbound > 0 or dch.Loyalty_Points_Outbound > 0)
		  and dch.Sales_Transaction_Number IS NOT NULL
		  and dch.ContactDateTime >= dateadd(dd, -180, getdate())

	union all

		  -- Now get Visitor responses (they are not really Visitors!)
		  -- No CBE ID but we can get that later
		  select 
		  NULL as CBE_CustomerID
		  , vrh.Sales_Transaction_Number
		  , 'VRH' as Src
		  , CHRHEntryDate = vrh.ResponseDateTime
		  , vrh.Loyalty_Points_Inbound
		  , vrh.Loyalty_Points_Outbound
		  , vrh.Loyalty_Type_Outbound
		  , vrh.Loyalty_Type_Inbound
		  from [emm_sys].[dbo].[UA_Visitor_ResponseHistory] vrh
		  where (Loyalty_Points_Inbound > 0 or Loyalty_Points_Outbound > 0)
		  and vrh.Sales_Transaction_Number IS NOT NULL
		  and vrh.ResponseDateTime >=dateadd(dd, -180, getdate())
	
		  ) rh
	) rnkd
where rownum = 1;

***************************************************************************************************/

/****************************************************************************************************
Lets add an index to our temp table - it seems to help
****************************************************************************************************/

CREATE CLUSTERED INDEX cx_chrh ON #tmp_loyalty_chrh (SalesTransactionNumber, CBE_CustomerID);

/****************************************************************************************************
Now we have those we can join to SalesTransactions and proceed with Bonus allocations.  The query is
virtually identical to what was in place before but rather than querying CBE Response History it uses
the temp table created above.

Some of the criteria have been pulled up into the temp table creation above & removed from the query below.
***************************************************************************************************/
        select sub.CustomerID,
               sub.LoyaltyReference,
               sub.LoyaltyCardSchemeName,
               sub.LoyaltyAccountID,
               sub.CBE_CustomerID,
               sub.ResponseDateTime,
               sub.SalesTransactionDate,
               sub.SalesTransactionNumber,
               sub.SalesTransactionID,
               sub.Loyalty_Points_Inbound,
               sub.Loyalty_Type_Inbound,
               sub.Loyalty_Points_Outbound,
               sub.Loyalty_Type_Outbound,
               sub.ExtReference,
               cast(sub.Loyalty_Points_Inbound as int) + cast(sub.Loyalty_Points_Outbound as int) as Points_Awarded
        into #tmp_bonus_loyalty
        from (

				select 
					b.CustomerID
                       , b.LoyaltyReference
                       , l.LoyaltyCardSchemeName
                       , l.LoyaltyAccountID
                       , coalesce(a.CBE_CustomerID,km.TCSCustomerID) as CBE_CustomerID
                       , a.ResponseDateTime
                       , b.SalesTransactionDate
                       , b.SalesTransactionNumber
                       , b.SalesTransactionID
                       , a.Loyalty_Points_Inbound
                       , a.Loyalty_Type_Inbound
                       , a.Loyalty_Points_Outbound
                       , a.Loyalty_Type_Outbound
                       , b.ExtReference

                from #tmp_loyalty_chrh a
					 -- Inner join so we only get "real" transactions & hence a CustomerID
                     inner join cem.Staging.STG_SalesTransaction b on a.SalesTransactionNumber = b.SalesTransactionNumber
					 inner join cem.staging.STG_KeyMapping km on b.CustomerID = km.CustomerID
                     left join (
                                select
                                  la.LoyaltyReference
                                , la.LoyaltyAccountID
                                , lp.Name as LoyaltyCardSchemeName
                                from Staging.STG_LoyaltyAccount la with(nolock)
                                inner join Reference.LoyaltyProgrammeType lp with(nolock) on la.LoyaltyProgrammeTypeID = lp.LoyaltyProgrammeTypeID
                                group by la.LoyaltyReference, la.LoyaltyAccountID, lp.Name
                                ) l on b.LoyaltyReference = l.LoyaltyReference
            ) sub
            -- We need to make sure we've already given points for the transaction itself before we give points for the bonus
			-- NB - a simple join does not correctly handle records with > 1 entry (i.e. where N SalesDetail records exist for same transaction)
            left join (
						select distinct
						SalesTransactionID
						, Description
						from
						cem.Staging.STG_LoyaltyAllocation 
						where
						[Description] like 'Collected%'

					  ) c on sub.SalesTransactionID = c.SalesTransactionID
            -- But we don't want to include people where we have already given them bonus points
 			-- NB - a simple join does not correctly handle records with > 1 entry (i.e. where N SalesDetail records exist for same transaction)
           left join (
						select distinct
						SalesTransactionID
						, Description
						from
						cem.Staging.STG_LoyaltyAllocation 
						where
						[Description] like 'Bonus%'

					  ) d on sub.SalesTransactionID = d.SalesTransactionID
			
        where 
		c.SalesTransactionID is not null
        and d.SalesTransactionID is null;

        -- INSERT THE BONUS POINTS INTO LOYALTY ALLOCATION
        insert into Staging.STG_LoyaltyAllocation(
                    Name
                    ,Description
                    ,CreatedDate
                    ,CreatedBy
                    ,LastModifiedDate
                    ,LastModifiedBy
                    ,ArchivedInd
                    ,SourceCreatedDate
                    ,SourceModifiedDate
                    ,LoyaltyStatusID
                    ,LoyaltyAccountID
                    ,SalesTransactionID
                    ,SalesTransactionDate
                    ,SalesDetailID
                    ,LoyaltyXChangeRateID
                    ,QualifyingSalesAmount
                    ,LoyaltyCurrencyAmount
                    ,InformationSourceID
                    ,ExtReference)

                select a.LoyaltyCardSchemeName
                       ,case when a.LoyaltyCardSchemeName = 'Nectar' then CONCAT('Bonus points ', a.SalesTransactionNumber)
                            when a.LoyaltyCardSchemeName in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2', 'Virgin Flying Club') then CONCAT('Bonus miles ', a.SalesTransactionNumber) end
                       ,getdate()
                       ,0
                       ,getdate()
                       ,0
                       ,0
                       ,a.SalesTransactionDate
                       ,a.SalesTransactionDate
                       ,@LoyaltyStatus_Processing -- Status = Processing - We pay immediately and clawback if canx/refunded
                       ,a.LoyaltyAccountID
                       ,a.SalesTransactionId
                       ,a.SalesTransactionDate
                       ,null
                       ,null
                       ,null
                       ,a.Points_Awarded
                       ,@informationsourceid
                       ,a.ExtReference
                from #tmp_bonus_loyalty a
                where a.LoyaltyReference is not null

/**************************************************************************************************
THE END
**************************************************************************************************/
end