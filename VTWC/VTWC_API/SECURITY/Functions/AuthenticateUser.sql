CREATE FUNCTION [Security].AuthenticateUser(@UserIdentity NVARCHAR(50), @UserPassword NVARCHAR(256), @UserSecret NVARCHAR(256))
RETURNS BIT AS
BEGIN
	DECLARE @isAuthenticated  NVARCHAR(50) = NULL;

	SELECT @isAuthenticated = COUNT(1)
	  FROM [Security].Users u WITH (NOLOCK) 
	 INNER JOIN [Security].Roles r WITH (NOLOCK) ON u.RoleID = r.RoleID
	 WHERE u.UserIdentity = @UserIdentity
	   AND u.Password = Security.HashPassword(@UserPassword)
	   AND r.Name = @UserSecret;
		
	RETURN @isAuthenticated;
END
GO

