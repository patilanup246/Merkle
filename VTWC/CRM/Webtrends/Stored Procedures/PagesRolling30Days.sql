CREATE PROC [Webtrends].[PagesRolling30Days]
AS
BEGIN
    delete Staging.PageViews
    where datediff(dd, EventDateTime, getdate()) > 31;
end