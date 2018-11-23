CREATE FUNCTION [Security].getUserEndpoints(@UserIdentity NVARCHAR(50))
RETURNS @rtnTable TABLE ( ResourcePath NVARCHAR(1024),
                          HttpMethod NVARCHAR(10) )
BEGIN
    INSERT INTO @rtnTable ( ResourcePath, HttpMethod )
		SELECT e.ResourcePath 
		     , e.HttpMethod
		  FROM [Security].Users u                WITH (NOLOCK) 
		 INNER JOIN [Security].Roles r           WITH (NOLOCK) ON u.RoleID = r.RoleID
		 INNER JOIN [Security].RolesEndpoints re WITH (NOLOCK) ON re.RoleID = r.RoleID
		 INNER JOIN [Security].[Endpoints] e     WITH (NOLOCK) ON e.EndpointID = re.EndpointID
		 WHERE u.UserIdentity = @UserIdentity
	RETURN;
END
GO

