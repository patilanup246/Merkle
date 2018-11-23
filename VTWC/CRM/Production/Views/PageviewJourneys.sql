CREATE VIEW [Production].[PageviewJourneys]
AS
SELECT 
	 CustomerID
	,Origin
	,Destination
	,LO.NLCCode OriginNLC
	,LD.NLCCode DestinationNLC
	,EventDateTime
FROM
	(
	SELECT 
		 CustomerID
		,NULLIF(SUBSTRING(New_ContentSubGroup,0,CHARINDEX(' to ',New_ContentSubGroup)),'') Origin
		,CASE
			WHEN CHARINDEX(' to ',New_ContentSubGroup) <> 0 THEN SUBSTRING(New_ContentSubGroup,CHARINDEX(' to ',New_ContentSubGroup) + 4,9999)
			ELSE New_ContentSubGroup
		 END Destination
		,EventDateTime
	FROM
		Production.PageViews
	WHERE
		New_ContentGroup = 'Destination'
		AND
		CustomerID IS NOT NULL
		AND
		New_ContentSubGroup NOT IN('Destinations home', 'Inspiration')
	) J LEFT JOIN
	CRM.Reference.Location LO
		ON LO.Name = REPLACE(J.Origin,'London','LONDON KINGS CROSS') LEFT JOIN
	CRM.Reference.Location LD
		ON LD.Name = REPLACE(J.Destination,'London','LONDON KINGS CROSS')