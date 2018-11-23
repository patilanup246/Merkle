CREATE PROC [Webtrends].[SearchesRolling30Days]
AS
BEGIN
    delete Staging.Searches
    where datediff(dd, EventDateTime, getdate()) > 31;
end