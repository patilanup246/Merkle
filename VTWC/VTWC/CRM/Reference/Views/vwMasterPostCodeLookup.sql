


CREATE VIEW [Reference].[vwMasterPostCodeLookup]
AS
SELECT
	 NS.PostCodeDistrict
	,NS.KMtoNeaarestStation
	,L.Name NearestStation
	--,LG.Name Region
FROM
	Reference.LocationPostCodeLookup NS 
	JOIN [Reference].[Location] L with(nolock)			ON L.LocationID = NS.LocationID 
	--JOIN Reference.LocationMapping LGM with(nolock)		ON LGM.LocationID = L.LocationID
	--														AND LGM.ArchivedInd = 0 
	--JOIN Reference.LocationGroup LG with(nolock)
	--	ON LG.LocationGroupID = LGM.LocationGroupID
	--	AND LG.ArchivedInd = 0
	--JOIN Reference.LocationMappingType LMT with(nolock)
	--	ON LMT.TypeID = LGM.TypeID
	--	AND LMT.Name = 'Region'
	--	AND LMT.ArchivedInd = 0
WHERE
	NS.ArchivedInd = 0
