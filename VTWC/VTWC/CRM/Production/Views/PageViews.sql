CREATE VIEW [Production].[PageViews]
AS
SELECT
	 [PV].[RawVisitorID]
	 ,PV.AmazeID
	,[PV].CustomerID
	,[PV].[SessionID]
	,[PV].[SessionStartDateTime]
	,[PV].[EventDateTime]
	,[PV].[EventSequenceNumber]
	,[PV].[ContentGroup]
	,[PV].[ContentSubGroup]
	,[CG].[ContentGroup] [New_ContentGroup]
	,[CG].[ContentSub-Group] [New_ContentSubGroup]
	,[PV].[PageURL]
	,PV.CampaignID
	,[PV].[PageTitle]
	,[PV].[DeviceType]
	,[PV].[DeviceBrand]
	,[PV].[DeviceMarketingName]
	,[PV].[DeviceModel]
	,[PV].[City]
	,[PV].[Postcode]
	,[PV].[Latitude]
	,[PV].[Longitude]
FROM
	[Staging].[PageViews] PV LEFT JOIN
	[Staging].[ContentGroups] CG ON PV.PageURL = CG.PageURL