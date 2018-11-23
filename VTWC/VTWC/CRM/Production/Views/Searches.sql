CREATE VIEW [Production].[Searches]
AS
SELECT
	 [S].[RawVisitorID]
	 ,S.AmazeID
	,[S].CustomerID
	,[S].[SessionID]
	,[S].[SessionStartDateTime]
	,[S].[EventDateTime]
	,[S].[EventSequenceNumber]
	,[S].[CBE_ID]
	,[S].[OriginNLC]
	,(SELECT DISTINCT TOP 1 Name FROM [CRM].[Reference].[Location] L WHERE L.[NLCCode] = NULLIF([S].[OriginNLC],'')) OriginStation
	,[S].[DestinationNLC]
	,(SELECT DISTINCT TOP 1 Name FROM [CRM].[Reference].[Location] L WHERE L.[NLCCode] = NULLIF([S].[DestinationNLC],'')) DestinationStation
	,[S].[ViaNLC]
	,(SELECT DISTINCT TOP 1 Name FROM [CRM].[Reference].[Location] L WHERE L.[NLCCode] = NULLIF([S].[ViaNLC],'')) ViaStation
	,[S].[AvoidNLC]
	,(SELECT DISTINCT TOP 1 Name FROM [CRM].[Reference].[Location] L WHERE L.[NLCCode] = NULLIF([S].[AvoidNLC],'')) AvoidStation
	,[S].[Direct]
	,[S].[OutwardDate]
	,[S].[OutwardTime]
	,[S].[OutwardTimePreference]
	,[S].[JourneyType]
	,[S].[OpenReturn]
	,[S].[ReturnDate]
	,[S].[ReturnTime]
	,[S].[ReturnTimePreference]
	,[S].[NoAdults]
	,[S].[NoChildren]
	,case when CHARINDEX(';', Railcards) > 0
            then SUBSTRING(Railcards, 1, CHARINDEX(';', Railcards) -1)
            else Railcards end as RailCard
	,[S].[DeviceType]
	,[S].[DeviceBrand]
	,[S].[DeviceMarketingName]
	,[S].[DeviceModel]
	,[S].[City]
	,[S].[Postcode]
	,[S].[Latitude]
	,[S].[Longitude]
FROM
	[Staging].[Searches] S