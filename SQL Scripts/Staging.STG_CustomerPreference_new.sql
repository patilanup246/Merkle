DECLARE @GeneralMarketingOptinId INT
DECLARE @RetailerMarketingOptinId INT
DECLARE @DftOptInFlagId INT
DECLARE @ThirdPartyMarketingOptinId INT
DECLARE @ThirdPartyOptoutId INT
DECLARE @NoneChannelId INT
DECLARE @EmailChannelId INT
DECLARE @SMSChannelId INT
DECLARE @MailChannelId INT

SELECT @GeneralMarketingOptinId = PreferenceID
FROM Reference.Preference
WHERE [Name] = 'General Marketing Opt-In'

SELECT @RetailerMarketingOptinId = PreferenceID
FROM Reference.Preference
WHERE [Name] = 'Retailer Marketing Opt-In'

SELECT @DftOptInFlagId = PreferenceID
FROM Reference.Preference
WHERE [Name] = 'DFT Opt-In'

SELECT @ThirdPartyMarketingOptinId = PreferenceID
FROM Reference.Preference
WHERE [Name] = 'Third party marketing Opt-In'

SELECT @ThirdPartyOptoutId = PreferenceID
FROM Reference.Preference
WHERE [Name] = 'Third party Opt-Out'

SELECT @NoneChannelId = ChannelID
FROM Reference.Channel
WHERE [Name] = 'None'

SELECT @EmailChannelId = ChannelID
FROM Reference.Channel
WHERE [Name] = 'Email'

SELECT @SMSChannelId = ChannelID
FROM Reference.Channel
WHERE [Name] = 'SMS'

SELECT @MailChannelId = ChannelID
FROM Reference.Channel
WHERE [Name] = 'Mail'

SELECT TCScustomerID
       ,CASE WHEN ScbscriptionType = 'donotemail'				THEN @GeneralMarketingOptinId
			 WHEN ScbscriptionType = 'donotmail'				THEN @GeneralMarketingOptinId
			 WHEN ScbscriptionType = 'donotsms'					THEN @GeneralMarketingOptinId
			 WHEN ScbscriptionType = 'thirdpartyoptout'			THEN @ThirdPartyOptoutId
			 WHEN ScbscriptionType = 'retailermarketingoptin'   THEN @RetailerMarketingOptinId
			 WHEN ScbscriptionType = 'thirdpartymarketingoptin' THEN @ThirdPartyMarketingOptinId
			 WHEN ScbscriptionType = 'DftOptInFlag'				THEN @DftOptInFlagId
		END AS PrefereceID
	   ,CASE WHEN ScbscriptionType = 'donotemail'				THEN @EmailChannelId
			 WHEN ScbscriptionType = 'donotmail'				THEN @MailChannelId
			 WHEN ScbscriptionType = 'donotsms'					THEN @SMSChannelId
			 WHEN ScbscriptionType = 'thirdpartyoptout'			THEN @NoneChannelId
			 WHEN ScbscriptionType = 'retailermarketingoptin'   THEN @NoneChannelId
			 WHEN ScbscriptionType = 'thirdpartymarketingoptin' THEN @NoneChannelId
			 WHEN ScbscriptionType = 'DftOptInFlag'				THEN @NoneChannelId
		END AS PrefereceID
		,CASE WHEN Subscription = 'Y' THEN 1 WHEN Subscription = 'N' THEN 0 END AS [value]
FROM (
SELECT unpvt.TCScustomerID, Subscription, ScbscriptionType
FROM (
SELECT TCScustomerID, donotemail, donotmail, donotsms, thirdpartyoptout
	   ,CAST(retailermarketingoptin AS nchar(1)) AS retailermarketingoptin
	   ,CAST(thirdpartymarketingoptin AS nchar(1)) AS thirdpartymarketingoptin
	   ,CAST(DftOptInFlag AS nchar(1)) AS DftOptInFlag
FROM PreProcessing.TOCPLUS_Customer
WHERE TCScustomerID = 61818545
AND DataImportDetailID = 272) AS S
UNPIVOT
(Subscription
 FOR ScbscriptionType IN (donotemail, donotmail, donotsms, thirdpartyoptout
						,retailermarketingoptin, thirdpartymarketingoptin, dftoptinflag)
) as unpvt) AS SQ