CREATE PROC [Webtrends].[TakeLatestVisitorInformation]
AS
BEGIN
    delete a
    from Staging.Visitors a
        inner join (
        select *, row_number() over (partition by RawVisitorId order by CreatedDate desc) as Priority
        from Staging.Visitors
        ) b on a.RawVisitorId = b.RawVisitorId and a.CreatedDate = b.CreatedDate
    where b.Priority != 1;
end