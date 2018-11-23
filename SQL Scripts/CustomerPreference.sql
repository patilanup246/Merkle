DECLARE @ChannelID INT, @AddressTypeID INT 

SELECT @ChannelID = ChannelID
FROM Reference.Channel
WHERE Name = 'Email' 

SELECT @AddressTypeID = AddressTypeID
FROM Reference.AddressType
WHERE Name = 'Email'

--113166
SELECT KM.TCSCustomerID AS CustomerID, EA.ParsedAddress AS Email
       ,P.Name AS [Type]
FROM Staging.STG_CustomerPreference AS CP
INNER JOIN Staging.STG_KeyMapping AS KM
	ON CP.CustomerID = KM.CustomerID 
	AND KM.IsParentInd = 1
INNER JOIN  Staging.STG_ElectronicAddress AS EA
	ON CP.CustomerID = EA.CustomerID
	AND EA.AddressTypeID = @AddressTypeID
INNER JOIN Reference.Preference AS P
	ON CP.PreferenceID = P.PreferenceID 
WHERE CP.[Value] = 0
AND CP.ChannelID = @ChannelID


