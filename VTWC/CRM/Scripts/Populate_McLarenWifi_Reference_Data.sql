-- Creating row Information Source for McLaren
INSERT INTO Reference.InformationSource ( 
	  Name
	, Description
	, CreatedDate
	, CreatedBy
	, LastModifiedDate
	, LastModifiedBy
	, ArchivedInd
	, DisplayName
	, TypeCode
	, ProspectInd
	, AdditionalInformation
)
VALUES 
( 
	'McLaren'
	,'McLaren - WiFi data provider'
	,GETDATE()
	,
	0
	,
	GETDATE()
	,0
	,0
	,'McLaren'
	,'External'
	,1
	,NULL
)