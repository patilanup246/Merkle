
create_temp_loyalty_table_query = """IF OBJECT_ID('cem.dbo.Temp_LoyaltyProcessing', 'U') IS NOT NULL 
DROP TABLE cem.dbo.Temp_LoyaltyProcessing;  
select a.LoyaltyAllocationID,
       c.CustomerID,
       a.name as Loyalty_Name,
       b.LoyaltyReference,
       a.SalesTransactionID,
       a.SalesTransactionDate,
       a.QualifyingSalesAmount,
       a.LoyaltyCurrencyAmount,
	   rc.Name as Location_Id
into cem.dbo.Temp_LoyaltyProcessing
from cem.Staging.STG_LoyaltyAllocation a
     left join cem.Staging.STG_LoyaltyAccount b on a.LoyaltyAccountID = b.LoyaltyAccountID
     left join cem.Staging.STG_SalesTransaction c on a.SalesTransactionID = c.SalesTransactionID
	 left join cem.Reference.RetailChannel rc on rc.RetailChannelID = c.RetailChannelID
where (a.name = 'Nectar' or a.name like 'Virgin%')
      and cast(a.CreatedDate as date) >= dateadd(dd, -3, cast(getdate() as date))
      and a.LoyaltyStatusID in (2, 6);"""

create_temp_loyalty_vfc_table_query = """IF OBJECT_ID('cem.dbo.Temp_LoyaltyProcessing', 'U') IS NOT NULL 
DROP TABLE cem.dbo.Temp_LoyaltyProcessing;  
select a.LoyaltyAllocationID,
       c.CustomerID,
       a.name as Loyalty_Name,
       b.LoyaltyReference,
       a.SalesTransactionID,
       a.SalesTransactionDate,
       a.QualifyingSalesAmount,
       a.LoyaltyCurrencyAmount,
	   rc.Name as Location_Id
into cem.dbo.Temp_LoyaltyProcessing
from cem.Staging.STG_LoyaltyAllocation a
     left join cem.Staging.STG_LoyaltyAccount b on a.LoyaltyAccountID = b.LoyaltyAccountID
     left join cem.Staging.STG_SalesTransaction c on a.SalesTransactionID = c.SalesTransactionID
	 left join cem.Reference.RetailChannel rc on rc.RetailChannelID = c.RetailChannelID
where a.name like 'Virgin%'
      and cast(a.CreatedDate as date) >= dateadd(dd, -3, cast(getdate() as date))
      and a.LoyaltyStatusID in (2, 6);"""
	  
update_season_location = """update tlp
set tlp.Location_Id = tlp.Location_Id + ' Season'
from cem.dbo.Temp_LoyaltyProcessing tlp 
inner join cem.Staging.STG_SalesTransaction st on st.SalesTransactionID = tlp.SalesTransactionID
inner join cem.Staging.STG_SalesDetail sd on sd.SalesTransactionID = st.SalesTransactionID
inner join cem.Reference.Product p on p.ProductID = sd.ProductID
where p.IsSeasonTicketInd = 1"""

vfc_records_query = """select LoyaltyReference,
       'VTEC' as PartnerCode,
       'SPEND' as ActivityNumber,
       'S' + right('00' + cast(Trans_Num as varchar(2)), 2) as CategoryCode,
       LoyaltyPoints as ActivityMultiplier,
       ActivityDate
from
    (select LoyaltyReference,
           cast(LoyaltyCurrencyAmount as int) as LoyaltyPoints,
           CONVERT(CHAR(8), SalesTransactionDate, 112) as ActivityDate,
           ROW_NUMBER () OVER (PARTITION BY loyaltyreference,
                                            CONVERT(CHAR(8), SalesTransactionDate, 112) order by SalesTransactionDate desc) as Trans_Num
    from cem.dbo.Temp_LoyaltyProcessing
    where Loyalty_Name like 'Virgin%') sub;

"""

vfc_loyalty_allocation_update = """update a
set a.LoyaltyStatusID = 4
from cem.Staging.STG_LoyaltyAllocation a
     inner join cem.dbo.Temp_LoyaltyProcessing b on a.LoyaltyAllocationID = b.LoyaltyAllocationID
where b.Loyalty_Name like 'Virgin%'"""


nectar_records_query = """select 'D' as Record_Type,
       right(LoyaltyReference, 11) as LoyaltyID,
       CustomerID as Sponsor_Loyalty_ID,
       '66A0000001' as Offer_Code,
       SalesTransactionID as Transaction_Number,
       Location_Id,
       CONVERT(CHAR(8), SalesTransactionDate, 112) + left(REPLACE(CONVERT(CHAR(8), SalesTransactionDate, 108), ':', ''),4) as Transaction_DateTime,
       case when QualifyingSalesAmount >= 0 then '0' + right('00000000' + cast(cast(QualifyingSalesAmount * 100 as int) as varchar(8)), 8)
            when QualifyingSalesAmount < 0 then '1' + right('00000000' + cast(cast(abs(QualifyingSalesAmount) * 100 as int) as varchar(8)), 8) end as Transaction_Amount,
       case when LoyaltyCurrencyAmount >= 0 then '0' + right('00000000' + cast(cast(LoyaltyCurrencyAmount as int) as varchar(8)), 8)
            when LoyaltyCurrencyAmount < 0 then '1' + right('00000000' + cast(cast(abs(LoyaltyCurrencyAmount) as int) as varchar(8)), 8) end as Points,
       null as Payment_Type_EFT,
       null as Payment_Type_Cash,
       null as Payment_Type_Voucher,
       null as Payment_Type_Cheque,
       null as Payment_Type_Saving_Stamps,
       null as Payment_Type_Coupon,
       null as Loyalty_Card_Recording_Method,
       null as Sponsor_Attribute_1,
       null as Sponsor_Attribute_2
from cem.dbo.Temp_LoyaltyProcessing
where Loyalty_Name = 'Nectar'"""

sequence_query = """select SequenceNumber
from cem.Reference.NectarSequenceNumber """

sequence_update_query = """update cem.Reference.NectarSequenceNumber
set SequenceNumber = SequenceNumber + 1"""

nectar_loyalty_allocation_update_sales = """update a
set a.LoyaltyStatusID = 4
from cem.Staging.STG_LoyaltyAllocation a
     inner join cem.dbo.Temp_LoyaltyProcessing b on a.LoyaltyAllocationID = b.LoyaltyAllocationID
where b.Loyalty_Name = 'Nectar' and a.LoyaltyStatusID = 2"""

nectar_loyalty_allocation_update_refunds = """update a
set a.LoyaltyStatusID = 5
from cem.Staging.STG_LoyaltyAllocation a
     inner join cem.dbo.Temp_LoyaltyProcessing b on a.LoyaltyAllocationID = b.LoyaltyAllocationID
where b.Loyalty_Name = 'Nectar' and a.LoyaltyStatusID = 6"""

drop_temp_loyalty_query = """drop table cem.dbo.Temp_LoyaltyProcessing"""