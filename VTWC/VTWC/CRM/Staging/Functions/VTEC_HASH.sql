
    CREATE FUNCTION [Staging].[VT_HASH]
       (@textToHash VARCHAR(MAX))
    RETURNS VARCHAR(MAX)
    AS
    BEGIN

      DECLARE @result       VARCHAR(MAX)
      DECLARE @salt         VARCHAR(80)
      DECLARE @hashBytes    NVARCHAR(MAX)
      DECLARE @Input        VARBINARY(MAX)

      SET @salt = 'WestCOAST';

      -- Convert string to byte array and encode using SHA2-256 algorithm
      SET @hashBytes = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @textToHash+@salt, 0))

      -- Convert encoded result to Base64
      SET @Input = CONVERT(VARBINARY(MAX), CONVERT(NVARCHAR(MAX), @hashBytes))

      -- Return Base64 Encoded Hash
      SET @result = CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:variable("@Input")))','NVARCHAR(MAX)');
      
      RETURN @result;
    END