CREATE PROC [Webtrends].[CreateWebEngagementSummary]
AS
BEGIN

	TRUNCATE TABLE [Production].[WebEngagementSummary]

	INSERT [Production].[WebEngagementSummary](
		 [CustomerID]
		,[PageViewsLast1Days]
		,[PageViewsLast3Days]
		,[PageViewsLast5Days]
		,[SearchesLast1Days]
		,[SearchesLast3Days]
		,[SearchesLast5Days]
	)
	SELECT 
		 ISNULL(PageViews.CustomerID,Searches.CustomerID) CustomerID
		,PageViews.PageViewsLast1Days
		,PageViews.PageViewsLast3Days
		,PageViews.PageViewsLast5Days
		,Searches.SearchesLast1Days
		,Searches.SearchesLast3Days
		,Searches.SearchesLast5Days
	FROM 
		(
		SELECT
			 CustomerID
			,SUM(CASE WHEN EventDateTime > CAST(GETDATE() -1 AS DATE) THEN 1 END) AS PageViewsLast1Days
			,SUM(CASE WHEN EventDateTime > CAST(GETDATE() -3 AS DATE) THEN 1 END) AS PageViewsLast3Days
			,SUM(CASE WHEN EventDateTime > CAST(GETDATE() -5 AS DATE) THEN 1 END) AS PageViewsLast5Days
		FROM
			[Production].[PageViews]
		GROUP BY
			CustomerID
		) PageViews FULL OUTER JOIN
		(
		SELECT
			 CustomerID
			,SUM(CASE WHEN EventDateTime > CAST(GETDATE() -1 AS DATE) THEN 1 END) AS SearchesLast1Days
			,SUM(CASE WHEN EventDateTime > CAST(GETDATE() -3 AS DATE) THEN 1 END) AS SearchesLast3Days
			,SUM(CASE WHEN EventDateTime > CAST(GETDATE() -5 AS DATE) THEN 1 END) AS SearchesLast5Days
		FROM
			[Production].[Searches]
		GROUP BY
			CustomerID
		) Searches
			ON Searches.CustomerID = PageViews.CustomerID
	WHERE
		ISNULL(PageViews.CustomerID,Searches.CustomerID) IS NOT NULL

END