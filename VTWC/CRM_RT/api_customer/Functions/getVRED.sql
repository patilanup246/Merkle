
CREATE FUNCTION api_customer.getVRED(@TVP shared.ArrayString READONLY )
RETURNS @rtnTable TABLE (
	ParsedAddress nvarchar(256),
	isVTCustomer bit
) AS
BEGIN

	INSERT INTO @rtnTable (ParsedAddress,isVTCustomer) 
		SELECT t.StringValue, 
               CASE 
			      WHEN ea.ParsedAddress IS NULL THEN 
					0 
				  ELSE 
					1 
				END IsVTCustomer
		  FROM @TVP t
		  LEFT OUTER JOIN api_customer.API_ElectronicAddress ea WITH (NOLOCK) ON ea.ParsedAddress = t.StringValue
	return;
END;