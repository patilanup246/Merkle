CREATE PROCEDURE [Staging].[STG_Loyalty_BaseCalculator]
  @user int = NULL,
  @CustomerSales [api_manager].[CustomerSales] READONLY,
  @PurchasedProduct [api_manager].[PurchasedProduct] READONLY,
  @RailCard [api_manager].[RailCard] READONLY,
  @AddOn [api_manager].[AddOn] READONLY,
  @PaymentUsed [api_manager].[PaymentUsed] READONLY,
  @BaseCurrencyEarned int OUTPUT,
  @BonusCurrencyEarned int OUTPUT,
  @LoyaltyCardSchemeCode [nvarchar](256) = null OUTPUT,
  @CallingSource varchar(5)

as
begin
    set nocount on;

    declare @NectarPointsPerPound as integer
    declare @VFCMilesPerPound as integer

    declare @informationsourceid as integer

    set @NectarPointsPerPound = 2
    set @VFCMilesPerPound = 2

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'CBE'

  CREATE TABLE #tmp_salesdetail
     (
     customerid                         integer,
     SalesTransactionDate               datetime,
     SalesTransactionNumber             nvarchar(256),
     LoyaltyCardSchemeName              nvarchar(100),
     LoyaltyCardNumber                  nvarchar(256),
     ProductType                        nvarchar(256),
     ProductCode                        nvarchar(256),
     RailcardType                       nvarchar(256),
     IncludesVTECLegInd                 bit,
     NumberOfTravellers                 integer,
     ProductCost                        decimal(14,2),
     AddonCost                          decimal(14,2),
     TotalCost                          decimal(14,2)
     )

    insert into #tmp_salesdetail (
        customerid,
        SalesTransactionDate,
        SalesTransactionNumber,
        LoyaltyCardSchemeName,
        LoyaltyCardNumber,
        ProductType,
        ProductCode,
        RailcardType,
        IncludesVTECLegInd,
        NumberOfTravellers,
        ProductCost,
        AddonCost,
        TotalCost)

   select a.CBECustomerId,
     a.SalesTransactionDate,
     a.SalesTransactionNumber,
     a.LoyaltyCardSchemeCode,
     a.LoyaltyCardNumber,
     b.ProductType,
     b.ProductCode,
     null, -- We need to get that data from the railcard table parameters
     b.IncludesVTECLegInd,
     b.NumberOfTravellers,
     case when @CallingSource = 'batch' then b.ProductCost            -- BATCH CALL USES POUNDS/PENCE
          when @CallingSource = 'API' then b.ProductCost/100.00 end,  -- AMAZE API CALL USES PENCE SO WE CONVERT
     case when @CallingSource = 'batch' then b.AddonCost            -- BATCH CALL USES POUNDS/PENCE
          when @CallingSource = 'API' then b.AddonCost/100.00 end,  -- AMAZE API CALL USES PENCE SO WE CONVERT
     case when @CallingSource = 'batch' then b.TotalCost            -- BATCH CALL USES POUNDS/PENCE
          when @CallingSource = 'API' then b.TotalCost/100.00 end  -- AMAZE API CALL USES PENCE SO WE CONVERT
     from @CustomerSales a inner join @PurchasedProduct b on a.SalesTransactionNumber = b.SalesTransactionNumber


     CREATE TABLE #tmp_salessummary
     (
     customerid                         integer,
     SalesTransactionDate               datetime,
     SalesTransactionNumber             nvarchar(256),
     LoyaltyCardSchemeName              nvarchar(100),
     LoyaltyCardNumber                  nvarchar(256),
     TotalPaid                          decimal(14,2),
     TotalCost                          decimal(14,2),
     LoyaltyCurrency                    integer,
     BonusCurrencyEarned_Input          integer
     )

    insert into #tmp_salessummary (
        customerid,
        SalesTransactionDate,
        SalesTransactionNumber,
        LoyaltyCardSchemeName,
        LoyaltyCardNumber,
        TotalPaid,
        TotalCost,
        LoyaltyCurrency,
        BonusCurrencyEarned_Input)

    select a.CBECustomerId,
     a.SalesTransactionDate,
     a.SalesTransactionNumber,
     a.LoyaltyCardSchemeCode,
     a.LoyaltyCardNumber,
     case when @CallingSource = 'batch' then b.Total_Paid            -- BATCH CALL USES POUNDS/PENCE
          when @CallingSource = 'API' then b.Total_Paid/100.00 end,  -- AMAZE API CALL USES PENCE SO WE CONVERT
     case when @CallingSource = 'batch' then c.Total_Cost            -- BATCH CALL USES POUNDS/PENCE
          when @CallingSource = 'API' then c.Total_Cost/100.00 end,  -- AMAZE API CALL USES PENCE SO WE CONVERT
     null,
     @BonusCurrencyEarned
     from @CustomerSales a left join (
                            select SalesTransactionNumber, sum(Amount) as Total_Paid
                            from @PaymentUsed
                            group by SalesTransactionNumber) b on a.SalesTransactionNumber = b.SalesTransactionNumber
         left join (select SalesTransactionNumber, sum(TotalCost) as Total_Cost
                    from @PurchasedProduct
                    group by SalesTransactionNumber) c on a.SalesTransactionNumber = c.SalesTransactionNumber

     update a
     set a.LoyaltyCurrency = b.Eligible_Spend * case when a.LoyaltyCardSchemeName in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2') then @VFCMilesPerPound
                                                       when a.LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
                                                       else 0 end -- * case when Num_VTEC_Legs > 0 then 1 else 0 end
     from #tmp_salessummary a inner join (
                              select a.customerid, b.SalesTransactionNumber, floor(sum(b.TotalCost)) as Eligible_Spend, sum(cast(IncludesVTECLegInd as int)) as Num_VTEC_Legs
                              from #tmp_salessummary a inner join #tmp_salesdetail b on a.customerid = b.customerid and a.SalesTransactionNumber = b.SalesTransactionNumber
                              group by a.customerid, b.SalesTransactionNumber
     ) b on a.customerid = b.customerid and a.SalesTransactionNumber = b.SalesTransactionNumber

    IF @CallingSource is null or @CallingSource not in ('API', 'batch')
            begin
            raiserror('Bad Calling Source passed', 16, 1);
            end

    IF @CallingSource = 'API'
    BEGIN
        SELECT @LoyaltyCardSchemeCode = LoyaltyCardSchemeCode FROM @CustomerSales
        IF @LoyaltyCardSchemeCode is null or @LoyaltyCardSchemeCode not in ('VAFC 11', 'VAFC 10', 'Nectar')
            begin
            raiserror('Bad Loyalty Card Scheme passed', 16, 1);
            end

        insert into preprocessing.loyalty_calculatoraudit_detail
        select getdate(),
               @user,
               null,
               customerid,
               SalesTransactionDate,
               null as SalesTransactionId,
               SalesTransactionNumber,
               LoyaltyCardSchemeName,
               LoyaltyCardNumber,
               ProductType,
               ProductCode,
               NULL AS RailcardType, -- Martin TBC
               IncludesVTECLegInd,
               NumberOfTravellers,
               ProductCost,
         -- AddonCost
               TotalCost,
               @CallingSource,
               case when LoyaltyCardSchemeName in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2') then @VFCMilesPerPound
                    when LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
                    else 0 end
        from #tmp_salesdetail

        insert into PreProcessing.Loyalty_CalculatorAudit_Summary
        select getdate(),
               @user,
               null,
               customerid,
               SalesTransactionDate,
               null as SalesTransactionId,
               SalesTransactionNumber,
               LoyaltyCardSchemeName,
               LoyaltyCardNumber,
               TotalCost,
               @CallingSource,
               LoyaltyCurrency
        from #tmp_salessummary

        SELECT @BaseCurrencyEarned = SUM(LoyaltyCurrency)
        FROM   #tmp_salessummary

        SELECT @LoyaltyCardSchemeCode = LoyaltyCardSchemeCode
        from @CustomerSales

        select @BonusCurrencyEarned = BonusCurrencyEarned_Input
        from #tmp_salessummary

--     return
    END

    IF @CallingSource = 'batch'
    BEGIN
        insert into preprocessing.loyalty_calculatoraudit_detail
        select getdate(),
               0,
               a.customerid,
               null,
               a.SalesTransactionDate,
               b.SalesTransactionId,
               a.SalesTransactionNumber,
               a.LoyaltyCardSchemeName,
               a.LoyaltyCardNumber,
               a.ProductType,
               a.ProductCode,
               NULL AS RailcardType, -- Martin TBC
               a.IncludesVTECLegInd,
               a.NumberOfTravellers,
               a.ProductCost,
               -- AddonCost
               a.TotalCost,
               @CallingSource,
               case when LoyaltyCardSchemeName in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2') then @VFCMilesPerPound
                    when LoyaltyCardSchemeName = 'Nectar' then @NectarPointsPerPound
                    else 0 end
        from #tmp_salesdetail a left join Staging.STG_SalesTransaction b on a.SalesTransactionNumber = b.SalesTransactionNumber

        insert into PreProcessing.Loyalty_CalculatorAudit_Summary
        select getdate(),
               0,
               a.customerid,
               null,
               a.SalesTransactionDate,
               b.SalesTransactionId,
               a.SalesTransactionNumber,
               a.LoyaltyCardSchemeName,
               a.LoyaltyCardNumber,
               a.TotalCost,
               @CallingSource,
               a.LoyaltyCurrency
        from #tmp_salessummary a left join Staging.STG_SalesTransaction b on a.SalesTransactionNumber = b.SalesTransactionNumber

        insert into Staging.STG_LoyaltyAllocation(
            Name,
            Description,
            CreatedDate,
            CreatedBy,
            LastModifiedDate,
            LastModifiedBy,
            ArchivedInd,
            SourceCreatedDate,
            SourceModifiedDate,
            LoyaltyStatusID,
            LoyaltyAccountID,
            SalesTransactionID,
            SalesTransactionDate,
            SalesDetailID,
            LoyaltyXChangeRateID,
            QualifyingSalesAmount,
            LoyaltyCurrencyAmount,
            InformationSourceID,
            ExtReference)

        select c.LoyaltyCardSchemeCode,
               case when c.LoyaltyCardSchemeCode = 'Nectar' then CONCAT('Collected points ', a.SalesTransactionNumber)
                    when c.LoyaltyCardSchemeCode in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2') then CONCAT('Collected miles ', a.SalesTransactionNumber) end,
               getdate(),
               0,
               getdate(),
               0,
               0,
               b.SalesTransactionDate,
               b.SalesTransactionDate,
               2,
               d.LoyaltyAccountID,
               b.SalesTransactionId,
               a.SalesTransactionDate,
               null,
               case when c.LoyaltyCardSchemeCode in ('VAFC 11', 'VAFC 10', 'Virgin Atlantic Flying Club', 'Virgin Atlantic Flying Club 2') then @VFCMilesPerPound
                    when c.LoyaltyCardSchemeCode = 'Nectar' then @NectarPointsPerPound
                    else 0 end,
               a.TotalCost,
               a.LoyaltyCurrency,
               @informationsourceid,
               b.ExtReference
        from #tmp_salessummary a inner join Staging.STG_SalesTransaction b on a.SalesTransactionNumber = b.SalesTransactionNumber
             inner join @CustomerSales c on a.SalesTransactionNumber = c.SalesTransactionNumber
             inner join Staging.STG_LoyaltyAccount d on a.LoyaltyCardNumber = d.LoyaltyReference /*inner join Reference.InformationSource e on d.InformationSourceID = e.InformationSourceID
        where e.name = 'CBE'*/
    END
end