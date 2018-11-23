CREATE FUNCTION [api_customer].[getServiceMessages] (@DaysAgo INTEGER )
RETURNS @rtnTable TABLE (
	MobileNumber nvarchar(256)
) AS
BEGIN

	INSERT INTO @rtnTable (MobileNumber) 
		SELECT MobileNumber 
		  FROM api_customer.ServiceMessage WITH (NOLOCK) 
		 WHERE OptOutDate >=  DATEADD(DAY,DATEDIFF(DAY,@DaysAgo,GETDATE()),0)
		   AND ISNULL(MobileNumber, '') != ''
	return;
END