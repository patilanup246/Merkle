CREATE PROCEDURE [Production].[customer_rfv_history_production]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

---- FIND THE DIFFERENCES BASED ON THE LATEST RUN
--select a.customerid, a.SegmentTier
--into #tmp_rfv_hist
--from crm.vw_Customer a inner join Production.RFV_History b on a.CustomerID = b.customerid
--where  (a.SegmentTier != b.rfv_segment or a.SegmentTier is not null and b.rfv_segment is null or a.SegmentTier is null and b.rfv_segment is not null)
--      and b.effective_to_date = '3000-12-31';

---- SET THE OLD RECORDS EFFECTIVE_TO_DATE = Today
--update b
--set b.effective_to_date = cast(getdate() as date)
--from #tmp_rfv_hist a inner join crm.Production.RFV_History b on a.customerid = b.customerid and b.effective_to_date = '3000-12-31';

---- INSERT THE NEW RECORDS WITH THE CORRECT HIGH DATES
--insert into crm.Production.RFV_History(
--    customerid,
--    rfv_segment,
--    effective_from_date,
--    effective_to_date
--)
--select customerid,
--       SegmentTier,
--       cast(getdate() as date),
--       '3000-12-31'
--from #tmp_rfv_hist

---- IDENTIFY NEW CUSTOMERS NOT ON RFV HISTORY
--insert into Production.RFV_History(
--    customerid,
--    rfv_segment,
--    effective_from_date,
--    effective_to_date
--)
--select a.customerid,
--       a.SegmentTier,
--       cast(getdate() as date),
--       '3000-12-31'
--from crm.vw_Customer a left join crm.Production.RFV_History b on a.CustomerID = b.customerid
--where b.customerid is null

end