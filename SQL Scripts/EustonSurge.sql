  DECLARE @AddressTypeID INT

  SELECT @AddressTypeID = AddressTypeID
  FROM CRM.Reference.AddressType
  WHERE Name = 'Mobile'

  SELECT B.ParsedAddress, A.[OptOutDate]
  FROM [ibm_system].[dbo].[SP_EustonSurge_CVI] AS A
  INNER JOIN CRM.Staging.STG_ElectronicAddress AS B
	ON A.[CustomerID] = B.CustomerID
	AND B.AddressTypeID = @AddressTypeID
  WHERE [OptOutDate] >= DATEADD(DD,0,DATEDIFF(DD,0,GETDATE()))