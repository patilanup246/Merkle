CREATE FUNCTION [Security].HashPassword(@UserPassword NVARCHAR(256))
RETURNS NVARCHAR(1024)
BEGIN
	RETURN CONVERT(varchar(max),HASHBYTES('MD5', @UserPassword), 2);
END