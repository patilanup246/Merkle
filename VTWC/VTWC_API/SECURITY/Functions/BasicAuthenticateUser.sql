/*===========================================================================================
Name:			[SECURITY].[BasicAuthenticateUser]
Purpose:		Provide DB authentication mecansism for API Baisc Auth.

Parameters:		@UserIdentity - Name of the users that we want to validate if it has access to the system or not.
                @UserPassword - Password to be compared against the hashed password.
Outputs:		Boolean (BIT), 0 = No access | 1 = Access
Notes:			    
			
Created:		Juanjo Diaz (jdiaz@merkleinc.com)
Modified:		

Peer Review:	
Call script:	e.g, SELECT [SECURITY].[BasicAuthenticateUser]('aUserName', 'aUserPassword')
=================================================================================================*/
CREATE FUNCTION [SECURITY].[BasicAuthenticateUser](@UserIdentity NVARCHAR(50), @UserPassword NVARCHAR(256))
RETURNS BIT AS
BEGIN
	DECLARE @isAuthenticated  NVARCHAR(50) = NULL;

	SELECT @isAuthenticated = COUNT(1)
	  FROM [Security].Users u WITH (NOLOCK) 
	 WHERE u.UserIdentity = @UserIdentity
	   AND u.Password = Security.HashPassword(@UserPassword);
		
	RETURN @isAuthenticated;
END