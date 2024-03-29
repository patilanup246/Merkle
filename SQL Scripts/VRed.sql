DECLARE @AddressTypeID INT 

SELECT @AddressTypeID = AddressTypeID
FROM Reference.AddressType
WHERE Name = 'Email'

SELECT c.CustomerID, addt.Name AS AddressType, ea.ParsedAddress    
FROM Staging.STG_ElectronicAddress ea            
INNER JOIN Staging.STG_Customer c 
	ON ea.CustomerID = c.CustomerID    
INNER JOIN Reference.AddressType addt
	  ON ea.AddressTypeID = addt.AddressTypeID
WHERE ea.PrimaryInd = 1         
AND ea.AddressTypeID = @AddressTypeID      
AND ea.ArchivedInd = 0        
-- Valid addresses are those that have purchase something during the last 18 months       
 AND c.DateLastPurchase >= Dateadd(Month, Datediff(Month, 0, DATEADD(m, -18, current_timestamp)), 0) 
